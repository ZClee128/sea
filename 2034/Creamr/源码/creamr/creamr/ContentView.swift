//
//  ContentView.swift
//  creamr
//
//  Created by zclee on 2026/3/27.
//

import SwiftUI

@available(iOS 15.0, *)
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    if #available(iOS 15.0, *) {
        ContentView()
    } else {
        // Fallback on earlier versions
    }
}
