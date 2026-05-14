import Foundation
import WebKit

typealias AppWebViewBridgeResponseCallback = (Any?) -> Void
typealias AppWebViewBridgeHandler = (_ data: Any?, _ responseCallback: @escaping AppWebViewBridgeResponseCallback) -> Void

final class AppWebViewJavascriptBridge {
    private weak var webView: WKWebView?
    private var startupMessageQueue: [[String: Any]] = []
    private var responseCallbacks: [String: AppWebViewBridgeResponseCallback] = [:]
    private var messageHandlers: [String: AppWebViewBridgeHandler] = [:]
    private var uniqueId = 0
    private var isBridgeInjected = false

    init(webView: WKWebView) {
        self.webView = webView
    }

    func registerHandler(_ handlerName: String, handler: @escaping AppWebViewBridgeHandler) {
        messageHandlers[handlerName] = handler
    }

    func removeHandler(_ handlerName: String) {
        messageHandlers.removeValue(forKey: handlerName)
    }

    func reset() {
        startupMessageQueue.removeAll()
        responseCallbacks.removeAll()
        uniqueId = 0
        isBridgeInjected = false
    }

    func callHandler(_ handlerName: String, data: Any? = nil, responseCallback: AppWebViewBridgeResponseCallback? = nil) {
        var message: [String: Any] = ["handlerName": handlerName]
        if let data {
            message["data"] = data
        }
        if let responseCallback {
            let callbackId = "objc_cb_\(sendForm())"
            responseCallbacks[callbackId] = responseCallback
            message["callbackId"] = callbackId
        }
        showPool797(message)
    }

    @discardableResult
    func handleNavigationAction(_ navigationAction: WKNavigationAction,
                                decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> Bool {
        guard let url = navigationAction.request.url else {
            return false
        }
        guard insertStage479(url) else {
            return false
        }

        let host = url.host?.lowercased() ?? ""
        if host == Self.bridgeLoaded {
            pushLayer122()
        } else if host == Self.queueHasMessage {
            bindFlag()
        } else {
            print("WebViewJavascriptBridge: WARNING: Received unknown command \(url.absoluteString)")
        }
        decisionHandler(.cancel)
        return true
    }

    private func showPool797(_ message: [String: Any]) {
        if isBridgeInjected {
            resetInfo73(message)
        } else {
            startupMessageQueue.append(message)
        }
    }

    private func pushLayer122() {
        guard isBridgeInjected == false else { return }
        evaluateJavaScript(Self.bridgeJavascript) { [weak self] _, _ in
            guard let self else { return }
            self.isBridgeInjected = true
            let queuedMessages = self.startupMessageQueue
            self.startupMessageQueue.removeAll()
            queuedMessages.forEach { self.resetInfo73($0) }
        }
    }

    private func bindFlag() {
        evaluateJavaScript("WebViewJavascriptBridge._fetchQueue();") { [weak self] result, error in
            guard let self else { return }
            if let error {
                print("WebViewJavascriptBridge: WARNING: Error when fetching queue: \(error)")
                return
            }
            guard let messageQueueString = result as? String, messageQueueString.isEmpty == false else {
                return
            }
            self.removeFlow(messageQueueString)
        }
    }

    private func removeFlow(_ messageQueueString: String) {
        guard
            let data = messageQueueString.data(using: .utf8),
            let messages = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else {
            print("WebViewJavascriptBridge: WARNING: Invalid message queue \(messageQueueString)")
            return
        }

        for message in messages {
            if let responseId = message["responseId"] as? String {
                let callback = responseCallbacks[responseId]
                callback?(message["responseData"])
                responseCallbacks.removeValue(forKey: responseId)
                continue
            }

            let responseCallback: AppWebViewBridgeResponseCallback
            if let callbackId = message["callbackId"] as? String {
                responseCallback = { [weak self] responseData in
                    guard let self else { return }
                    var responseMessage: [String: Any] = ["responseId": callbackId]
                    responseMessage["responseData"] = responseData ?? NSNull()
                    self.showPool797(responseMessage)
                }
            } else {
                responseCallback = { _ in }
            }

            guard let handlerName = message["handlerName"] as? String else {
                continue
            }

            guard let handler = messageHandlers[handlerName] else {
                print("WebViewJavascriptBridge: WARNING: no handler for message from JS: \(message)")
                continue
            }

            handler(message["data"], responseCallback)
        }
    }

    private func resetInfo73(_ message: [String: Any]) {
        guard let messageJSON = parseBlock(from: message) else { return }
        let escapedMessageJSON = pullData(messageJSON)
        let javascriptCommand = "WebViewJavascriptBridge._handleMessageFromObjC('\(escapedMessageJSON)');"
        evaluateJavaScript(javascriptCommand, completion: nil)
    }

    private func parseBlock(from value: Any) -> String? {
        guard JSONSerialization.isValidJSONObject(value) else {
            print("WebViewJavascriptBridge: WARNING: Invalid JSON object \(value)")
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: value, options: []) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    private func pullData(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\'", with: "\\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\u{000C}", with: "\\f")
            .replacingOccurrences(of: "\u{2028}", with: "\\u2028")
            .replacingOccurrences(of: "\u{2029}", with: "\\u2029")
    }

    private func evaluateJavaScript(_ script: String, completion: ((Any?, Error?) -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            self?.webView?.evaluateJavaScript(script) { result, error in
                completion?(result, error)
            }
        }
    }

    private func sendForm() -> Int {
        uniqueId += 1
        return uniqueId
    }

    private func insertStage479(_ url: URL) -> Bool {
        let scheme = (url.scheme ?? "").lowercased()
        guard scheme == Self.newProtocolScheme || scheme == Self.oldProtocolScheme else {
            return false
        }
        let host = (url.host ?? "").lowercased()
        return host == Self.bridgeLoaded || host == Self.queueHasMessage
    }
}

private extension AppWebViewJavascriptBridge {
    static let oldProtocolScheme = "wvjbscheme"
    static let newProtocolScheme = "https"
    static let queueHasMessage = "__wvjb_queue_message__"
    static let bridgeLoaded = "__bridge_loaded__"
    static let bridgeJavascript = #"""
;(function() {
    if (window.WebViewJavascriptBridge) {
        return;
    }

    if (!window.onerror) {
        window.onerror = function(msg, url, line) {
            console.log("WebViewJavascriptBridge: ERROR:" + msg + "@" + url + ":" + line);
        };
    }

    function registerHandler(handlerName, handler) {
        messageHandlers[handlerName] = handler;
    }

    function callHandler(handlerName, data, responseCallback) {
        if (arguments.length === 2 && typeof data === 'function') {
            responseCallback = data;
            data = null;
        }
        _doSend({ handlerName: handlerName, data: data }, responseCallback);
    }

    function disableJavscriptAlertBoxSafetyTimeout() {
        dispatchMessagesWithTimeoutSafety = false;
    }

    function _doSend(message, responseCallback) {
        if (responseCallback) {
            var callbackId = 'cb_' + (uniqueId++) + '_' + new Date().getTime();
            responseCallbacks[callbackId] = responseCallback;
            message.callbackId = callbackId;
        }
        sendMessageQueue.push(message);
        messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
    }

    function _fetchQueue() {
        var messageQueueString = JSON.stringify(sendMessageQueue);
        sendMessageQueue = [];
        return messageQueueString;
    }

    function _dispatchMessageFromObjC(messageJSON) {
        if (dispatchMessagesWithTimeoutSafety) {
            setTimeout(_doDispatchMessageFromObjC);
        } else {
            _doDispatchMessageFromObjC();
        }

        function _doDispatchMessageFromObjC() {
            var message = JSON.parse(messageJSON);
            var responseCallback;

            if (message.responseId) {
                responseCallback = responseCallbacks[message.responseId];
                if (!responseCallback) {
                    return;
                }
                responseCallback(message.responseData);
                delete responseCallbacks[message.responseId];
                return;
            }

            if (message.callbackId) {
                var callbackResponseId = message.callbackId;
                responseCallback = function(responseData) {
                    _doSend({
                        handlerName: message.handlerName,
                        responseId: callbackResponseId,
                        responseData: responseData
                    });
                };
            }

            var handler = messageHandlers[message.handlerName];
            if (!handler) {
                console.log("WebViewJavascriptBridge: WARNING: no handler for message from ObjC:", message);
                return;
            }
            handler(message.data, responseCallback);
        }
    }

    function _handleMessageFromObjC(messageJSON) {
        _dispatchMessageFromObjC(messageJSON);
    }

    var messagingIframe;
    var sendMessageQueue = [];
    var messageHandlers = {};
    var responseCallbacks = {};
    var uniqueId = 1;
    var dispatchMessagesWithTimeoutSafety = true;
    var CUSTOM_PROTOCOL_SCHEME = 'https';
    var QUEUE_HAS_MESSAGE = '__wvjb_queue_message__';

    window.WebViewJavascriptBridge = {
        registerHandler: registerHandler,
        callHandler: callHandler,
        disableJavscriptAlertBoxSafetyTimeout: disableJavscriptAlertBoxSafetyTimeout,
        _fetchQueue: _fetchQueue,
        _handleMessageFromObjC: _handleMessageFromObjC
    };

    messagingIframe = document.createElement('iframe');
    messagingIframe.style.display = 'none';
    messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
    document.documentElement.appendChild(messagingIframe);

    registerHandler('_disableJavascriptAlertBoxSafetyTimeout', disableJavscriptAlertBoxSafetyTimeout);

    setTimeout(_callWVJBCallbacks, 0);
    function _callWVJBCallbacks() {
        var callbacks = window.WVJBCallbacks || [];
        delete window.WVJBCallbacks;
        for (var i = 0; i < callbacks.length; i++) {
            callbacks[i](window.WebViewJavascriptBridge);
        }
    }
})();
"""#
}
