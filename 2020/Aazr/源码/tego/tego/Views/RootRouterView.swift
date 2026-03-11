//
//  RootRouterView.swift
//  tego
//

import SwiftUI

@available(iOS 14.0, *)
struct RootRouterView: View {
    @ObservedObject var viewModel = AppViewModel()
    
    var body: some View {
        if viewModel.hasAgreedToTerms {
            MainTabView()
        } else {
            AgreementView(viewModel: viewModel)
        }
    }
}

