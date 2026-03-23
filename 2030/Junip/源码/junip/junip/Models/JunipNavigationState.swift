import SwiftUI
internal import Combine

@available(iOS 14.0, *)
class JunipNavigationState: ObservableObject {
    @Published var selectedTab: Int = 0
}
