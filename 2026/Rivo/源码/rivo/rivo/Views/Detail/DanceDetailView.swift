import SwiftUI

struct DanceDetailView: View {
    let move: DanceMove
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Large Image
                Image(move.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: UIScreen.main.bounds.width)
                    .frame(height: 400)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text(move.category.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(move.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(move.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("Technical Tips")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ForEach(move.technicalTips, id: \.self) { tip in
                        HStack(alignment: .top) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                                .padding(.top, 6)
                            Text(tip)
                                .font(.system(size: 16))
                                .foregroundColor(.primary.opacity(0.8))
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
}
