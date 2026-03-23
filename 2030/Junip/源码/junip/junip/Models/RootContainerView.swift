import SwiftUI

@available(iOS 14.0, *)
struct RootContainerView: View {
    @State private var hasAcceptedAgreement: Bool = UserDefaults.standard.bool(forKey: "hasAcceptedAgreement")
    
    var body: some View {
        Group {
            if hasAcceptedAgreement {
                JunipScaffold()
            } else {
                ServiceAgreementView(onAccept: {
                    UserDefaults.standard.set(true, forKey: "hasAcceptedAgreement")
                    withAnimation {
                        hasAcceptedAgreement = true
                    }
                })
            }
        }
    }
}

struct RootContainerView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            RootContainerView()
        } else {
            // Fallback on earlier versions
        }
    }
}
