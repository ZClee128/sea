import SwiftUI

// MARK: - Pro Tips View
@available(iOS 14.0, *)
struct ProTipsView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Pro Multi-Media Tips")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    Text("Expert advice for elevated aesthetics")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        ForEach(LabDataStore.tips) { tip in
                            HStack(spacing: 20) {
                                Image(systemName: tip.icon)
                                    .font(.title)
                                    .foregroundColor(.orange)
                                    .frame(width: 40)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text(tip.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text(tip.subtitle)
                                            .font(.caption.bold())
                                            .foregroundColor(.orange.opacity(0.8))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.orange.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                    
                                    Text(tip.content)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(3)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
        }
        .navigationTitle("Pro Tips")
    }
}
