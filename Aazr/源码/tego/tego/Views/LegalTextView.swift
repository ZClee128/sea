//
//  LegalTextView.swift
//  tego
//

import SwiftUI

enum LegalTextType {
    case terms
    case privacy
    
    var title: String {
        switch self {
        case .terms: return "Terms of Use"
        case .privacy: return "Privacy Policy"
        }
    }
    
    var content: String {
        switch self {
        case .terms:
            return """
            Welcome to Tego. By using our application, you agree to these Terms of Use.
            
            1. App Purpose
            Tego provides fashion trend information and photography pose suggestions. No user data is collected or uploaded to our servers.
            
            2. Content
            The aesthetic guides and fashion tips are for educational purposes.
            
            3. User Responsibility
            You are responsible for the photos you take using the mock studio feature. All processing happens locally on your device.
            
            4. Changes to Terms
            We may update these terms occasionally. Continued use constitutes acceptance.
            """
            
        case .privacy:
            return """
            Tego Privacy Policy
            
            1. Data Collection
            Tego does NOT collect, store, or transmit any personal data, photos, or usage metrics. All features, including the pose studio and favorites, save data strictly locally on your device via UserDefaults.
            
            2. Camera Access
            The app requests camera access solely for the real-time Pose Studio feature. The video feed is processed on-device, and photos are saved directly to your local photo library (if permitted). We do not have access to your camera feed.
            
            3. Third Parties
            We do not share any data with third parties since we do not collect any data.
            
            4. Contact
            For privacy inquiries, please refer to the support URL on our App Store page.
            """
        }
    }
}

struct LegalTextView: View {
    let type: LegalTextType
    
    var body: some View {
        ScrollView {
            Text(type.content)
                .padding()
                .font(.body)
                .lineSpacing(6)
        }
        .navigationBarTitle(Text(type.title), displayMode: .inline)
    }
}
