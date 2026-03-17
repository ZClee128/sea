//
//  ContentView.swift
//  mexo
//
//  Created by zclee on 2026/3/17.
//

import SwiftUI

struct ContentView: View {
    @State private var hasAgreed: Bool = UserDefaults.standard.bool(forKey: "hasAgreedToTerms")
    
    var body: some View {
        if hasAgreed {
            MainTabView()
        } else {
            AgreementView(isAgreed: $hasAgreed)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
