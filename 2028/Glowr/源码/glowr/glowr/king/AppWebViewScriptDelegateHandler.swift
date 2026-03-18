//
//  AppWebViewScriptDelegateHandler.swift

//

import UIKit
import Foundation
import WebKit

class AppWebViewScriptDelegateHandler: NSObject, WKScriptMessageHandler {
    weak var scriptDelegate: WKScriptMessageHandler?
    
    init(_ scriptDelegate: WKScriptMessageHandler) {
        super.init()
        self.scriptDelegate = scriptDelegate
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("js call method name = \(message.name), message = \(message.body)")
        DispatchQueue.main.async {
            self.scriptDelegate?.userContentController(userContentController, didReceive: message)
        }
    }
}
