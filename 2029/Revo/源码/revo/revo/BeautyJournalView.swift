import SwiftUI
import Combine

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var rating: Int // 1 to 5
}

class JournalManager: ObservableObject {
    @Published var entries: [JournalEntry] = [] {
        didSet {
            save()
        }
    }
    
    init() {
        load()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "revo_journal_entries")
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: "revo_journal_entries"),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = decoded
        }
    }
    
    func addEntry(_ entry: JournalEntry) {
        entries.insert(entry, at: 0)
    }
    
    func deleteEntry(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
    }
}

struct BeautyJournalView: View {
    @ObservedObject private var manager = JournalManager()
    @State private var showingAddEntry = false
    
    var body: some View {
        NavigationView {
        ZStack {
            if manager.entries.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 80))
                        .foregroundColor(RevoDesign.primary.opacity(0.3))
                    
                    Text("Your Beauty Journey")
                        .font(.headline)
                        .foregroundColor(RevoDesign.text)
                    
                    Text("Document your makeup experiments and daily looks.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .foregroundColor(RevoDesign.textSecondary)
                    
                    Button(action: { showingAddEntry = true }) {
                        Text("Create First Entry")
                    }
                    .buttonStyle(GlassyButtonStyle())
                    .padding(.horizontal, 60)
                    .padding(.top, 20)
                }
            } else {
                List {
                    ForEach(manager.entries) { entry in
                        NavigationLink(destination: EntryDetailView(entry: entry)) {
                            PremiumCard {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(entry.title)
                                        .font(.headline)
                                        .foregroundColor(RevoDesign.text)
                                    
                                    HStack {
                                        Text("\(entry.date)") // Simpler date for iOS 13
                                        Spacer()
                                        HStack(spacing: 2) {
                                            ForEach(1...5, id: \.self) { star in
                                                Image(systemName: star <= entry.rating ? "star.fill" : "star")
                                                    .font(.caption)
                                                    .foregroundColor(RevoDesign.primary)
                                            }
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(RevoDesign.textSecondary)
                                }
                            }
                        }
                    }
                    .onDelete(perform: manager.deleteEntry)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationBarTitle("Beauty Journal")
        .navigationBarItems(trailing: Button(action: { showingAddEntry = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.title)
                .foregroundColor(RevoDesign.primary)
        })
        .sheet(isPresented: $showingAddEntry) {
            AddEntryView(manager: manager)
        }
        }
        .forceLightMode()
    }
}

struct AddEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var manager: JournalManager
    
    @State private var title = ""
    @State private var content = ""
    @State private var rating = 5
    
    var body: some View {
        NavigationView {
                Form {
                    Section(header: Text("Inspiration Details")) {
                        TextField("Entry Title (e.g. Wedding Practice)", text: $title)
                        Picker("Success Rating", selection: $rating) {
                            ForEach(1...5, id: \.self) {
                                Text("\($0) Stars")
                            }
                        }
                    }
                    
                    Section(header: Text("Technique & Product Notes")) {
                        TextField("Enter notes here...", text: $content)
                            .frame(height: 100)
                    }
                    
                    Section {
                        Button(action: {
                            let newEntry = JournalEntry(id: UUID(), title: title, content: content, date: Date(), rating: rating)
                            manager.addEntry(newEntry)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Save Entry")
                        }
                        .buttonStyle(GlassyButtonStyle())
                        .disabled(title.isEmpty)
                    }
                    .listRowBackground(Color.clear)
                }
                .navigationBarTitle("New Entry", displayMode: .inline)
                .navigationBarItems(leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
        .forceLightMode()
    }
}

struct EntryDetailView: View {
    let entry: JournalEntry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(entry.date)")
                            .font(.subheadline)
                            .foregroundColor(RevoDesign.textSecondary)
                        
                        Text(entry.title)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(RevoDesign.text)
                    }
                    Spacer()
                }
                
                HStack(spacing: 5) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= entry.rating ? "star.fill" : "star")
                            .foregroundColor(RevoDesign.primary)
                    }
                }
                
                Divider()
                
                Text("Notes & Observations")
                    .font(.headline)
                    .foregroundColor(RevoDesign.text)
                
                Text(entry.content)
                    .font(.body)
                    .foregroundColor(RevoDesign.textSecondary)
                    .lineSpacing(6)
            }
            .padding()
        }
        .navigationBarTitle(Text(entry.title), displayMode: .inline)
    }
}
