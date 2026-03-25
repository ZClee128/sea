import SwiftUI

struct HomeView: View {
    let items: [FashionItem] = FashionData.sampleItems
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    // 瀑布流 - 左右两列
                    HStack(alignment: .top, spacing: 12) {
                        // 左列
                        ColumnView(items: leftItems)
                        // 右列
                        ColumnView(items: rightItems)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            .navigationBarTitle("Sunny", displayMode: .large)
        }
    }
    
    var leftItems: [FashionItem] {
        items.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }
    }
    
    var rightItems: [FashionItem] {
        items.enumerated().filter { $0.offset % 2 == 1 }.map { $0.element }
    }
}

struct ColumnView: View {
    let items: [FashionItem]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                NavigationLink(destination: DetailView(item: item)) {
                    CompactItemCard(item: item)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct CompactItemCard: View {
    let item: FashionItem
    @ObservedObject var favoritesManager = FavoritesManager.shared

    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 图片 - 固定高度，不撑开
            GeometryReader { geo in
                ZStack(alignment: .topTrailing) {
                    if let uiImage = UIImage(named: item.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: 180)
                            .clipped()
                    } else {
                        Color.gray.opacity(0.2)
                            .frame(width: geo.size.width, height: 180)
                    }
                    
                    // 收藏按钮
                    Button(action: { favoritesManager.toggle(id: item.id) }) {
                        let isLiked = favoritesManager.isFavorite(id: item.id)
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(isLiked ? .red : .white)
                            .padding(6)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(6)

                }
            }
            .frame(height: 180)
            .cornerRadius(12)
            
            // 标题和标签
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Text(item.category)
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct DetailView: View {
    let item: FashionItem
    @ObservedObject var favoritesManager = FavoritesManager.shared

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 图片
                GeometryReader { geo in
                    if let uiImage = UIImage(named: item.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: 350)
                            .clipped()
                    } else {
                        Color.gray.opacity(0.2)
                            .frame(width: geo.size.width, height: 350)
                    }
                }
                .frame(height: 350)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(item.title)
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Button(action: { favoritesManager.toggle(id: item.id) }) {
                            let isLiked = favoritesManager.isFavorite(id: item.id)
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 22))
                                .foregroundColor(isLiked ? .red : .gray)
                        }

                    }
                    
                    HStack(spacing: 10) {
                        Text(item.category)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.1))
                            .cornerRadius(8)
                        
                        Text("\(item.views) views")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Text(item.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineSpacing(3)
                    
                    // 设计师信息
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            if let avatar = UIImage(named: item.designer.avatarName) {
                                Image(uiImage: avatar)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.designer.name)
                                    .font(.system(size: 16, weight: .bold))
                                Text(item.designer.specialty)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if #available(iOS 14.0, *) {
                                NavigationLink(destination: ChatView(designer: item.designer)) {
                                    Text("Chat")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color(red: 1.0, green: 0.6, blue: 0.2))
                                        .cornerRadius(20)
                                }
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 8)
                    
                    Text("More Like This")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.top, 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(FashionData.sampleItems.prefix(5)) { relatedItem in
                                NavigationLink(destination: DetailView(item: relatedItem)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        GeometryReader { geo in
                                            if let img = UIImage(named: relatedItem.imageName) {
                                                Image(uiImage: img)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: geo.size.width, height: 130)
                                                    .clipped()
                                            } else {
                                                Color.gray.opacity(0.2)
                                                    .frame(width: geo.size.width, height: 130)
                                            }
                                        }
                                        .frame(width: 100, height: 130)
                                        .cornerRadius(8)
                                        
                                        Text(relatedItem.title)
                                            .font(.system(size: 11))
                                            .foregroundColor(.primary)
                                            .lineLimit(2)
                                    }
                                    .frame(width: 100)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .background(Color(red: 0.99, green: 0.98, blue: 0.96))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
