//
//  AppWebViewScriptDelegateHandler.swift
//  OverseaH5
//
//  Created by young on 2025/9/24.
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
        DispatchQueue.main.async {
            self.scriptDelegate?.userContentController(userContentController, didReceive: message)
        }
    }
}
