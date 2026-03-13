import SwiftUI

struct RootView: View {
    @ObservedObject var appState: AppState = AppState()
    
    var body: some View {
        Group {
            if !appState.hasAgreed {
                AgreementView(appState: appState)
            } else if !appState.hasCompletedQuiz {
                QuizView(appState: appState)
            } else {
                MainTabView(appState: appState)
            }
        }
        .environmentObject(appState)
        .preferredColorScheme(.dark)
    }
}
