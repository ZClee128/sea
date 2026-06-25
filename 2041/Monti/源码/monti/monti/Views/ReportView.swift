import SwiftUI

enum ReportTarget {
    case post
    case comment
    case im
    case video
    
    var title: String {
        switch self {
        case .post: return "Report Post"
        case .comment: return "Report Comment"
        case .im: return "Report User"
        case .video: return "Report Video"
        }
    }
    
    var targetLabel: String {
        switch self {
        case .post: return "REPORTING POST"
        case .comment: return "REPORTING COMMENT"
        case .im: return "REPORTING USER"
        case .video: return "REPORTING VIDEO"
        }
    }
}

struct ReportView: View {
    let targetType: ReportTarget
    let targetName: String
    let targetContent: String
    
    var onSubmit: (String) -> Void
    var onCancel: () -> Void
    
    @State private var selectedReason: String? = nil
    @State private var isSubmitting: Bool = false
    
    let reasons = [
        "Spam or Advertising",
        "Pornography or Vulgarity",
        "Harassment or Abuse",
        "Scam or Fraud",
        "Politically Sensitive Content",
        "Illegal or Criminal Activity",
        "Intellectual Property Violation",
        "Other Violations"
    ]
    
    var body: some View {
        ZStack {
            // Dark Background matching the app theme
            Color(red: 0.08, green: 0.08, blue: 0.10)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header Row
                HStack {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .foregroundColor(.gray)
                            .font(.system(size: 16, weight: .medium))
                    }
                    Spacer()
                    Text(targetType.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    // Spacer helper to balance
                    Button(action: {}) {
                        Text("Cancel")
                            .font(.system(size: 16))
                            .opacity(0)
                    }
                    .disabled(true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Section 1: Target Preview Card (Glassmorphism look)
                        VStack(alignment: .leading, spacing: 10) {
                            Text(targetType.targetLabel)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Text("👤")
                                        .font(.system(size: 16))
                                    Text(targetName)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Text(targetContent)
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(3)
                                    .padding(.top, 4)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Section 2: Custom Reasons List (Without any Input fields!)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SELECT VIOLATION REASON")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1)
                                .padding(.horizontal, 16)
                            
                            ForEach(reasons, id: \.self) { reason in
                                Button(action: {
                                    if !isSubmitting {
                                        selectedReason = reason
                                    }
                                }) {
                                    HStack {
                                        Text(reason)
                                            .font(.system(size: 14, weight: selectedReason == reason ? .semibold : .regular))
                                            .foregroundColor(selectedReason == reason ? .white : .white.opacity(0.7))
                                        
                                        Spacer()
                                        
                                        if selectedReason == reason {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50))
                                                .font(.system(size: 18))
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray.opacity(0.5))
                                                .font(.system(size: 18))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(
                                        selectedReason == reason ?
                                        Color(red: 1.00, green: 0.00, blue: 0.50).opacity(0.12) :
                                        Color.white.opacity(0.03)
                                    )
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedReason == reason ?
                                                Color(red: 1.00, green: 0.00, blue: 0.50).opacity(0.5) :
                                                Color.clear,
                                                lineWidth: 1
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
                
                // Submit Button at Bottom
                Button(action: {
                    guard selectedReason != nil else { return }
                    submitReport()
                }) {
                    HStack(spacing: 8) {
                        if isSubmitting {
                            ReportActivityIndicator()
                        }
                        Text(isSubmitting ? "Submitting Report..." : "Submit Report")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        selectedReason != nil ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 1.00, green: 0.00, blue: 0.50), Color(red: 0.50, green: 0.00, blue: 1.00)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.3)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .padding(.top, 8)
                }
                .disabled(selectedReason == nil || isSubmitting)
                .background(Color(red: 0.08, green: 0.08, blue: 0.10))
            }
        }
    }
    
    private func submitReport() {
        isSubmitting = true
        // Simulate premium processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isSubmitting = false
            if let reason = selectedReason {
                onSubmit(reason)
            }
        }
    }
}

// iOS 13 compatible small activity indicator for report submissions
struct ReportActivityIndicator: View {
    @State private var isAnimating = false
    var body: some View {
        Image(systemName: "arrow.2.circlepath")
            .font(.system(size: 16))
            .foregroundColor(.white)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false))
            .onAppear {
                self.isAnimating = true
            }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(
            targetType: .post,
            targetName: "Sarah Connor",
            targetContent: "Successfully mapped a 14-move shield duel sequence today! Rehearsing with a 2.5kg wooden replica really demands high wrist precision.",
            onSubmit: { _ in },
            onCancel: {}
        )
    }
}
