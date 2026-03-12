import Foundation

struct Portrait: Identifiable, Hashable {
    let id: UUID
    let imageName: String
    let personName: String
    let defaultQuote: String
    let category: String
    let shortBio: String
    
    init(id: UUID = UUID(), imageName: String, personName: String, defaultQuote: String, category: String, shortBio: String) {
        self.id = id
        self.imageName = imageName
        self.personName = personName
        self.defaultQuote = defaultQuote
        self.category = category
        self.shortBio = shortBio
    }
}
