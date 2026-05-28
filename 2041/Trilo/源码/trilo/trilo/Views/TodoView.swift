import SwiftUI

@available(iOS 15.0, *)
struct TodoView: View {
    @ObservedObject var todoManager = TodoManager.shared
    @State private var newTodoTitle = ""
    @State private var selectedCategory = "Work"
    @State private var filterCategory: String? = nil
    @State private var showingAddSheet = false
    
    var filteredTodos: [TodoItem] {
        if let filter = filterCategory {
            return todoManager.todos.filter { $0.category == filter }
        }
        return todoManager.todos
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Category Filter Segment/Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button(action: {
                                withAnimation(.spring()) {
                                    filterCategory = nil
                                }
                            }) {
                                Text("All")
                                    .font(.system(size: 13, weight: .bold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(filterCategory == nil ? Color.blue : Color.white)
                                    .foregroundColor(filterCategory == nil ? .white : .primary)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.03), radius: 2)
                            }
                            
                            ForEach(todoManager.categories, id: \.self) { category in
                                Button(action: {
                                    withAnimation(.spring()) {
                                        filterCategory = category
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(categoryColor(category))
                                            .frame(width: 6, height: 6)
                                        Text(category)
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(filterCategory == category ? Color.blue : Color.white)
                                    .foregroundColor(filterCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.03), radius: 2)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(Color.white)
                    
                    if filteredTodos.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("No tasks found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Add a task to outline your goals.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            // Focus Task Highlight
                            if let activeTodo = todoManager.activeFocusTodo, filterCategory == nil || activeTodo.category == filterCategory {
                                Section(header: Text("Currently Focusing")) {
                                    TodoRowView(todo: activeTodo, isActiveFocus: true)
                                }
                            }
                            
                            // Normal Tasks
                            Section(header: Text("Tasks")) {
                                ForEach(filteredTodos.filter { $0.id != todoManager.activeFocusTodoID }) { todo in
                                    TodoRowView(todo: todo, isActiveFocus: false)
                                }
                                .onDelete(perform: deleteItems)
                            }
                            
                            if !todoManager.todos.filter({ $0.isCompleted }).isEmpty {
                                Section {
                                    Button(action: {
                                        withAnimation {
                                            todoManager.clearCompleted()
                                        }
                                    }) {
                                        HStack {
                                            Spacer()
                                            Text("Clear Completed Tasks")
                                                .foregroundColor(.red)
                                                .font(.subheadline.bold())
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
                
                // Floating Action Button to Add Task
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddSheet = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .clipShape(Circle())
                                .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 25)
                    }
                }
            }
            .navigationTitle("Focus Tasks")
            .sheet(isPresented: $showingAddSheet) {
                AddTaskSheetView(isPresented: $showingAddSheet, title: $newTodoTitle, selectedCategory: $selectedCategory)
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredTodos.filter { $0.id != todoManager.activeFocusTodoID }[$0] }
        for item in itemsToDelete {
            todoManager.deleteTodo(id: item.id)
        }
    }
    
    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "Work": return .blue
        case "Study": return .orange
        case "Design": return .purple
        case "Life": return .green
        default: return .gray
        }
    }
}

@available(iOS 15.0, *)
struct TodoRowView: View {
    let todo: TodoItem
    let isActiveFocus: Bool
    @ObservedObject var todoManager = TodoManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkmark button
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring()) {
                    todoManager.toggleTodo(id: todo.id)
                }
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(todo.isCompleted ? .green : .gray.opacity(0.6))
                    .scaleEffect(todo.isCompleted ? 1.05 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(size: 15, weight: isActiveFocus ? .bold : .medium))
                    .strikethrough(todo.isCompleted, color: .gray)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    // Category pill
                    Text(todo.category)
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(categoryColor(todo.category).opacity(0.12))
                        .foregroundColor(categoryColor(todo.category))
                        .cornerRadius(4)
                    
                    if isActiveFocus {
                        Text("Active Focus Target")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Focus select button
            if !todo.isCompleted {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation {
                        if isActiveFocus {
                            todoManager.selectForFocus(id: nil)
                        } else {
                            todoManager.selectForFocus(id: todo.id)
                        }
                    }
                }) {
                    Image(systemName: isActiveFocus ? "star.fill" : "star")
                        .font(.system(size: 18))
                        .foregroundColor(isActiveFocus ? .orange : .gray.opacity(0.4))
                        .padding(8)
                        .background(isActiveFocus ? Color.orange.opacity(0.1) : Color.clear)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
        .overlay(
            isActiveFocus ?
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(0.15), lineWidth: 1)
                .padding(.horizontal, -8)
                .padding(.vertical, -4)
            : nil
        )
    }
    
    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "Work": return .blue
        case "Study": return .orange
        case "Design": return .purple
        case "Life": return .green
        default: return .gray
        }
    }
}

@available(iOS 15.0, *)
struct AddTaskSheetView: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var selectedCategory: String
    @ObservedObject var todoManager = TodoManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("What are you working on?", text: $title)
                        .disableAutocorrection(true)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(todoManager.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle("New Focus Task")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    todoManager.addTodo(title: title, category: selectedCategory)
                    title = ""
                    isPresented = false
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
}
