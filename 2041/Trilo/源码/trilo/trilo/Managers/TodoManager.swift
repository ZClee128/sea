import Foundation
import Combine
import SwiftUI

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var category: String
    let createdAt: Date
}

class TodoManager: ObservableObject {
    static let shared = TodoManager()
    
    @Published var todos: [TodoItem] = []
    @Published var activeFocusTodoID: UUID? {
        didSet {
            UserDefaults.standard.set(activeFocusTodoID?.uuidString, forKey: "active_focus_todo_id")
        }
    }
    
    private let storageKey = "trilo_todos_storage"
    
    var activeFocusTodo: TodoItem? {
        todos.first(where: { $0.id == activeFocusTodoID })
    }
    
    let categories = ["Work", "Study", "Design", "Life", "Other"]
    
    init() {
        loadTodos()
        if let savedID = UserDefaults.standard.string(forKey: "active_focus_todo_id"),
           let uuid = UUID(uuidString: savedID) {
            self.activeFocusTodoID = uuid
        }
    }
    
    func addTodo(title: String, category: String) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newTodo = TodoItem(
            id: UUID(),
            title: title,
            isCompleted: false,
            category: category,
            createdAt: Date()
        )
        DispatchQueue.main.async {
            self.todos.insert(newTodo, at: 0)
            self.saveTodos()
            
            // Auto-select for focus if no task is currently selected
            if self.activeFocusTodoID == nil {
                self.activeFocusTodoID = newTodo.id
            }
        }
    }
    
    func toggleTodo(id: UUID) {
        DispatchQueue.main.async {
            if let index = self.todos.firstIndex(where: { $0.id == id }) {
                self.todos[index].isCompleted.toggle()
                self.saveTodos()
                
                // If the active focus task was marked completed, clear the active focus selection
                if id == self.activeFocusTodoID && self.todos[index].isCompleted {
                    self.activeFocusTodoID = self.todos.first(where: { !$0.isCompleted })?.id
                }
            }
        }
    }
    
    func deleteTodo(id: UUID) {
        DispatchQueue.main.async {
            self.todos.removeAll(where: { $0.id == id })
            self.saveTodos()
            
            if id == self.activeFocusTodoID {
                self.activeFocusTodoID = self.todos.first(where: { !$0.isCompleted })?.id
            }
        }
    }
    
    func selectForFocus(id: UUID?) {
        DispatchQueue.main.async {
            self.activeFocusTodoID = id
        }
    }
    
    func clearCompleted() {
        DispatchQueue.main.async {
            self.todos.removeAll(where: { $0.isCompleted })
            self.saveTodos()
            
            if self.activeFocusTodo == nil {
                self.activeFocusTodoID = self.todos.first(where: { !$0.isCompleted })?.id
            }
        }
    }
    
    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todos = decoded
        } else {
            // Seed some beautiful placeholder/onboarding todos on first run
            todos = [
                TodoItem(id: UUID(), title: "Explore visual inspiration themes", isCompleted: false, category: "Design", createdAt: Date()),
                TodoItem(id: UUID(), title: "Set a 25-minute Pomodoro timer", isCompleted: false, category: "Study", createdAt: Date()),
                TodoItem(id: UUID(), title: "Start a deep work ambient focus session", isCompleted: false, category: "Work", createdAt: Date())
            ]
            saveTodos()
        }
    }
}
