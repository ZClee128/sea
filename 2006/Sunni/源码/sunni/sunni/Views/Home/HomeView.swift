//
//  HomeView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 15.0, *)
struct HomeView: View {
    @State private var posts: [Post] = MockDataService.shared.mockPosts
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(posts) { post in
                        PostCardView(post: post)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "person.circle")
                            .foregroundColor(Color(hex: "2ECC71"))
                    }
                }
            }
            .refreshable {
                await refreshPosts()
            }
        }
    }
    
    private func refreshPosts() async {
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        // In real app, fetch new posts from API
        posts = MockDataService.shared.mockPosts
        isRefreshing = false
    }
}

@available(iOS 15.0, *)
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
