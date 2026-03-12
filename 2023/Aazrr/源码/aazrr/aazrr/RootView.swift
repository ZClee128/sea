import SwiftUI

struct RootView: View {
    @State var hasAgreed: Bool
    
    init(hasAgreed: Bool) {
        self._hasAgreed = State(initialValue: hasAgreed)
    }
    
    var body: some View {
        Group {
            if hasAgreed {
                MainTabView()
            } else {
                AgreementView(hasAgreed: $hasAgreed)
            }
        }
    }
}
