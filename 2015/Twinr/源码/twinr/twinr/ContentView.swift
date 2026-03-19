//
//  ContentView.swift
//  twinr
//
//  Created by zclee on 2026/3/19.
//

import SwiftUI

struct ContentView: View {
    @State private var hasAgreed = UserDefaults.standard.bool(forKey: "hasAgreed")
    
    var body: some View {
        if hasAgreed {
            if #available(iOS 14.0, *) {
                MainTabView()
                    .preferredColorScheme(.light)
            } else {
                // Fallback on earlier versions
            }
        } else {
            AgreementView(isAgreed: $hasAgreed)
                .preferredColorScheme(.light)
        }
    }
}

#Preview {
    ContentView()
}
