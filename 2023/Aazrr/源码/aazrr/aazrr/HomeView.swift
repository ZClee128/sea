import SwiftUI

struct HomeView: View {
    let allPortraits = AppContent.portraits
    @State private var selectedCategory: String = "All"
    
    var categories: [String] {
        var cats = ["All"]
        cats.append(contentsOf: Array(Set(allPortraits.map { $0.category })).sorted())
        return cats
    }
    
    var filteredPortraits: [Portrait] {
        if selectedCategory == "All" {
            return allPortraits
        }
        return allPortraits.filter { $0.category == selectedCategory }
    }
    
    @State private var selectedPortrait: Portrait?
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .fontWeight(selectedCategory == category ? .bold : .regular)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
                
                ScrollView {
                    if selectedCategory == "All" {
                        VStack(alignment: .leading) {
                            Text("Daily Highlight")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.horizontal, 24)
                            
                            PortraitCard(portrait: allPortraits.first!)
                                .padding(.horizontal, 24)
                                .onTapGesture {
                                    self.selectedPortrait = allPortraits.first!
                                }
                        }
                        .padding(.bottom, 10)
                        
                        Text("Discover")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    VStack(spacing: 20) {
                        let listData = selectedCategory == "All" ? Array(filteredPortraits.dropFirst()) : filteredPortraits
                        ForEach(listData) { portrait in
                            PortraitCard(portrait: portrait)
                                .padding(.horizontal, 24)
                                .onTapGesture {
                                    self.selectedPortrait = portrait
                                }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationBarTitle("Aazrr", displayMode: .inline)
            .sheet(item: $selectedPortrait) { portrait in
                PosterEditorView(portrait: portrait)
            }
        }
    }
}

struct PortraitCard: View {
    let portrait: Portrait
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Color.gray.opacity(0.2)
                Image(portrait.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: UIScreen.main.bounds.width - 20, maxHeight: 250)
                    .clipped() // Prevent the image from bleeding out of its frame
            }
            .frame(height: 250)
            .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(portrait.personName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(portrait.shortBio)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(portrait.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
            .padding()
            .background(Color.white)
        }
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
