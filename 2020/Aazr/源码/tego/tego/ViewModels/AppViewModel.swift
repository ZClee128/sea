//
//  AppViewModel.swift
//  tego
//

import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var hasAgreedToTerms: Bool = UserDefaults.standard.bool(forKey: "hasAgreedToTerms") {
        didSet {
            UserDefaults.standard.set(hasAgreedToTerms, forKey: "hasAgreedToTerms")
        }
    }
}
