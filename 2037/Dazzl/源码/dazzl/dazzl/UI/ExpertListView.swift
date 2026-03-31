import SwiftUI

@available(iOS 15.0, *)
struct ExpertListView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var expertStore = ExpertDataStore()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Professional Square")
                                .font(.system(size: 34, weight: .black))
                                .foregroundColor(.white)
                            Text("1v1 consultations with photography masters")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Expert Cards
                        LazyVStack(spacing: 20) {
                            ForEach(expertStore.experts) { expert in
                                NavigationLink(destination: ChatView(expert: expert)) {
                                    ExpertCard(expert: expert)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

@available(iOS 14.0, *)
struct ExpertCard: View {
    let expert: Expert
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar with specialty icon
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Text(String(expert.name.prefix(1)))
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.blue)
                    )
                
                Image(systemName: expert.avatar)
                    .font(.caption2.bold())
                    .padding(5)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .foregroundColor(.white)
                    .offset(x: 5, y: 5)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(expert.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                        Text(String(format: "%.1f", expert.rating))
                            .font(.caption2.bold())
                            .foregroundColor(.gray)
                    }
                }
                
                Text(expert.specialty)
                    .font(.caption.bold())
                    .foregroundColor(.blue)
                
                Text(expert.bio)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
