import SwiftUI

struct PrivacyPolicyView: View {
    @Binding var hasAgreedPrivacy: Bool
    @State private var policyText: String = ""
    @State private var hasScrolledToBottom = false
    @State private var showAgreeBtnPulse = false

    var body: some View {
        ZStack {
            // Background gradient
            if #available(iOS 14.0, *) {
                LinearGradient(
                    colors: [Color(hex: "#FCE4EC"), Color(hex: "#FFF8F9"), Color.white],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                // Fallback on earlier versions
            }

            VStack(spacing: 0) {
                // Header
                headerSection

                // Policy scroll content
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(policyText.isEmpty ? "Loading privacy policy…" : policyText)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.zText.opacity(0.85))
                            .lineSpacing(5)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)

                        // Bottom sentinel
                        GeometryReader { geo -> Color in
                            let frame = geo.frame(in: .global)
                            DispatchQueue.main.async {
                                if frame.minY < UIScreen.main.bounds.height {
                                    withAnimation { hasScrolledToBottom = true }
                                }
                            }
                            return Color.clear
                        }
                        .frame(height: 1)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.zPrimary.opacity(0.08), radius: 16, x: 0, y: 4)
                )
                .padding(.horizontal, 16)

                // Agree button
                agreeButton
            }
            .padding(.top, 16)
        }
        .onAppear { loadPolicy() }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 44, weight: .light))
                .foregroundColor(Color.zPrimary)
                .padding(.top, 8)

            Text("Privacy Policy")
                .font(.zTitle(28))
                .foregroundColor(Color.zText)

            Text("Please read and agree to continue")
                .font(.zBody(14))
                .foregroundColor(Color.zTextSub)
        }
        .padding(.bottom, 20)
    }

    // MARK: - Agree Button
    private var agreeButton: some View {
        VStack(spacing: 8) {
            Text("Scroll to the bottom to enable the button")
                .font(.zCaption(11))
                .foregroundColor(Color.zTextSub)
                .opacity(hasScrolledToBottom ? 0 : 1)
                .animation(.easeInOut, value: hasScrolledToBottom)

            Button(action: {
                guard hasScrolledToBottom else { return }
                withAnimation(.spring()) {
                    hasAgreedPrivacy = true
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                    Text("I Agree & Continue")
                        .font(.zHeadline(17))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    hasScrolledToBottom
                    ? LinearGradient(colors: [Color.zPrimary, Color.zAccent],
                                     startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.4)],
                                     startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
                .shadow(color: hasScrolledToBottom ? Color.zPrimary.opacity(0.35) : .clear,
                        radius: 10, x: 0, y: 5)
                .scaleEffect(showAgreeBtnPulse ? 1.02 : 1.0)
            }
            .disabled(!hasScrolledToBottom)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        showAgreeBtnPulse = true
                    }
                }
            }
        }
        .padding(.top, 12)
        .background(Color.zBackground)
    }

    // MARK: - Load from file
    private func loadPolicy() {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            policyText = "Privacy policy not available."
            return
        }
        policyText = text
    }
}
