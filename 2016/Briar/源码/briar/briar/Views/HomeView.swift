import SwiftUI

struct HomeView: View {
    @State private var selectedCategory: Post.Category? = nil
    
    var filteredPosts: [Post] {
        if let category = selectedCategory {
            return mockPosts.filter { $0.category == category }
        }
        return mockPosts
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryButton(title: "Latest", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(Post.Category.allCases, id: \.self) { category in
                            CategoryButton(title: category.rawValue, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 2)
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(filteredPosts) { post in
                            PostCard(post: post)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitle("Briar Beauty", displayMode: .inline)
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(isSelected ? Color.black : Color(UIColor.systemGray6))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(20)
        }
    }
}

struct PostCard: View {
    let post: Post
    
    var body: some View {
        NavigationLink(destination: PostDetailView(post: post)) {
            VStack(alignment: .leading, spacing: 0) {
                // Placeholder image styling
                Rectangle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(post.category.rawValue.uppercased())
                            .font(.system(size: 10))
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Spacer()
                        if post.videoURLString != nil {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.black)
                        }
                    }
                    
                    Text(post.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(post.content)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(post.author)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(post.date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                }
                .padding()
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
