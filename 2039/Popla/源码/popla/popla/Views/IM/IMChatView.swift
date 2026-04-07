import SwiftUI

@available(iOS 14.0, *)
struct IMChatView: View {
    @ObservedObject var viewModel: IMViewModel
    @State private var newMessageText: String = ""
    @State private var isShowingReport = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(viewModel.curatorName)
                        .font(.system(size: 16, weight: .black))
                    Text("Online")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                // Safety Report Button
                Button(action: { isShowingReport = true }) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray.opacity(0.4))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(Color.white.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5))
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(25)
                }
                .onTapGesture {
                    // Tap to dismiss keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let last = viewModel.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            
            // Input Area (Will be pushed by keyboard automatically)
            HStack(spacing: 15) {
                TextField("Ask the curator...", text: $newMessageText)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(25)
                
                Button(action: {
                    viewModel.sendMessage(newMessageText)
                    newMessageText = ""
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10) // Fixed padding
            .padding(.top, 15)
            .background(Color.white.shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5))
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isShowingReport) {
            ReportView()
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            
            Text(message.content)
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(message.isFromUser ? Color.black : Color.gray.opacity(0.07))
                .foregroundColor(message.isFromUser ? .white : .black)
                .cornerRadius(20, corners: message.isFromUser ? [.topLeft, .bottomLeft, .topRight] : [.topLeft, .bottomRight, .topRight])
            
            if !message.isFromUser { Spacer() }
        }
    }
}

// Helper for specific corner rounding
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
