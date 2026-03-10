import UIKit
import StoreKit
 
let APPLE_IAP_MAX_RETRY_COUNT = 9

enum AZPaymentType {
    case Pay
    case Subscribe
}

enum AZPaymentStatus: String {
    case unknow            = "未知类型"
    case createOrderFail   = "创建订单失败"
    case notArrow          = "设备不允许"
    case noProductId       = "缺少产品Id"
    case failed            = "交易失败/取消"
    case restored          = "已购买过该商品"
    case deferred          = "交易延期"
    case verityFail        = "服务器验证失败"
    case veritySucceed     = "服务器验证成功"
    case renewSucceed      = "自动续订成功"
}

typealias AZPurchaseCompletion = (AZPaymentStatus, Double, AZPaymentType) -> Void

class AZPurchaseSession: NSObject {
    
    var completionHandle: AZPurchaseCompletion?
    private var productInfoReq: SKProductsRequest?
    private var reqRetryCountDict = [String: Int]()
    private var payCacheList = [[String: String]]()
    private var subscribeCacheList = [[String: String]]()
    private var createOrderId: String?
    private var currentPayType: AZPaymentType = .Pay
    
    static let shared = AZPurchaseSession()
    override func copy() -> Any { return self }
    override func mutableCopy() -> Any { return self }
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        NotificationCenter.default.addObserver(self, selector: #selector(p_ba7f2),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }

    @objc private func p_ba7f2() {
        SKPaymentQueue.default().remove(self as SKPaymentTransactionObserver)
    }
}

// MARK: - 【苹果购买】业务接口
extension AZPurchaseSession {
    fileprivate func p_ah1e9(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
        let reqModel = AZRequestPayload.init()
        reqModel.requestPath = ["mf","recharge","createApplePay"].joined(separator: "/")
        var dict = Dictionary<String, Any>()
        dict["productId"] = productId
        dict["source"] = source
        reqModel.params = dict
        AZNetworkClient.p_r3a1(model: reqModel) { succeed, result, errorModel in
            guard succeed == true else {
                handle(nil, succeed)
                return
            }
            var orderId: String?
            let dict = result as? [String: Any]
            if let value = dict?["orderNum"] as? String {
                orderId = value
            }
            handle(orderId, succeed)
        }
    }
    
    fileprivate func p_ai4f2(_ transactionId: String, params: [String: String]) {
        let reqModel = AZRequestPayload.init()
        reqModel.requestPath = ["mf","recharge","applePayNotify"].joined(separator: "/")
        reqModel.params = params
        AZNetworkClient.p_r3a1(model: reqModel) { succeed, result, errorModel in
            guard succeed == true || errorModel?.errorCode == 405 else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.p_ag8d6(transactionId, .Pay)
                }
                return
            }
            let dict = result as? [String: Any]
            let reportMoney: Double = {
                if let d = dict?["reportMoney"] as? Double { return d }
                return 0
            }()
            let newPayCacheList = self.payCacheList.filter({$0["transactionId"] != transactionId})
            let diskPath = self.p_y4b2()
            NSKeyedArchiver.archiveRootObject(newPayCacheList, toFile: diskPath)
            self.completionHandle?(.veritySucceed, reportMoney, .Pay)
        }
    }
}

// MARK: - 【苹果订阅】业务接口
extension AZPurchaseSession {
    fileprivate func p_aj7a5(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
        let reqModel = AZRequestPayload.init()
        reqModel.requestPath = ["mf","AutoSub","AppleCreateOrder"].joined(separator: "/")
        var dict = Dictionary<String, Any>()
        dict["productId"] = productId
        dict["source"] = source
        reqModel.params = dict
        AZNetworkClient.p_r3a1(model: reqModel) { succeed, result, errorModel in
            guard succeed == true else {
                handle(nil, succeed)
                return
            }
            var orderId: String? = nil
            let dict = result as? [String: Any]
            if let value = dict?["orderId"] as? String {
                orderId = value
            }
            handle(orderId, succeed)
        }
    }
    
    fileprivate func p_ak0b8(_ transactionId: String, params: [String: String]) {
        let reqModel = AZRequestPayload.init()
        reqModel.requestPath = ["mf","AutoSub","ApplePaySuccess"].joined(separator: "/")
        reqModel.params = params
        AZNetworkClient.p_r3a1(model: reqModel) { succeed, result, errorModel in
            guard succeed == true || errorModel?.errorCode == 405 else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    self.p_ag8d6(transactionId, .Subscribe)
                }
                return
            }
            let dict = result as? [String: Any]
            let reportMoney: Double = {
                if let d = dict?["reportMoney"] as? Double { return d }
                return 0
            }()
            let newSubscribeCacheList = self.subscribeCacheList.filter({$0["transactionId"] != transactionId})
            let diskPath = self.p_z7c5()
            NSKeyedArchiver.archiveRootObject(newSubscribeCacheList, toFile: diskPath)
            self.completionHandle?(.veritySucceed, reportMoney, .Subscribe)
        }
    }
}

// MARK: - Event
extension AZPurchaseSession {
    private func p_w8f6() {
        self.payCacheList = p_x1a9(payType: .Pay)
        self.subscribeCacheList = p_x1a9(payType: .Subscribe)
        self.createOrderId = nil
    }
    
    private func p_x1a9(payType: AZPaymentType) -> [[String: String]] {
        var list: [[String: String]]?
        var diskPath = ""
        if payType == .Pay {
            diskPath = p_y4b2()
        } else {
            diskPath = p_z7c5()
        }
        if FileManager.default.fileExists(atPath: diskPath) {
            list = NSKeyedUnarchiver.unarchiveObject(withFile: diskPath) as? [[String: String]]
            if list == nil {
               try? FileManager.default.removeItem(atPath: diskPath)
            }
        }
        if list == nil { list = [[String: String]]() }
        return list!
    }
    
    private func p_y4b2() -> String {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent("App")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: appDirectoryPath) == false {
           try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
        }
        let filePath = (appDirectoryPath as NSString).appendingPathComponent("azsc_pay")
        return filePath
    }
    
    private func p_z7c5() -> String {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent("App")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: appDirectoryPath) == false {
           try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
        }
        let filePath = (appDirectoryPath as NSString).appendingPathComponent("azsc_sub")
        return filePath
    }
 
    fileprivate func p_aa0d8(_ transactionId: String, _ payType: AZPaymentType) -> String? {
        var paramsArr = [[String: String]]()
        switch(payType) {
        case .Pay:
            paramsArr = self.payCacheList.filter({$0["transactionId"] == transactionId})
        case .Subscribe:
            paramsArr = self.subscribeCacheList.filter({$0["transactionId"] == transactionId})
        }
        if paramsArr.count > 0 && paramsArr.first!["verifyData"] != nil {
            return paramsArr.first!["verifyData"]
        }
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return nil }
        let data = NSData(contentsOf: receiptUrl)
        let receiptStr = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        return receiptStr
    }
}

// MARK: - 失败重试流程
extension AZPurchaseSession {
    func p_ab3e1() {
        p_w8f6()
        for dict in self.payCacheList {
            p_ac6f4(dict["transactionId"], .Pay)
        }
        for dict in self.subscribeCacheList {
            p_ac6f4(dict["transactionId"], .Subscribe)
        }
    }
    
    private func p_ac6f4(_ transactionId: String?, _ payType: AZPaymentType) {
        guard let transactionId = transactionId else { return }
        reqRetryCountDict[transactionId] = 0
        p_ag8d6(transactionId, payType)
    }
}

// MARK: - 苹果正常支付流程
extension AZPurchaseSession {
    func p_ad9a7(productId: String, payType: AZPaymentType, source: Int = 0, handle: @escaping AZPurchaseCompletion) {
        p_w8f6()
        self.completionHandle = handle
        self.currentPayType = payType
        
        switch(payType) {
        case .Pay:
            p_ah1e9(productId: productId, source: source) { [weak self] orderId, succeed in
                guard let self = self else { return }
                guard succeed == true && orderId != nil else {
                    self.completionHandle?(.createOrderFail, 0, .Pay)
                    return
                }
                self.createOrderId = orderId
                self.p_ae2b0(productId)
            }
        
        case .Subscribe:
            p_aj7a5(productId: productId, source: source) { [weak self] orderId, succeed in
                guard let self = self else { return }
                guard succeed == true && orderId != nil else {
                    self.completionHandle?(.createOrderFail, 0, .Subscribe)
                    return
                }
                self.createOrderId = orderId
                self.p_ae2b0(productId)
            }
        }
    }
        
    fileprivate func p_ae2b0(_ productId: String) {
        guard SKPaymentQueue.canMakePayments() else {
            self.completionHandle?(.notArrow, 0, currentPayType)
            return
        }
        self.p_af5c3()
        let identifiers: Set<String> = [productId]
        productInfoReq = SKProductsRequest(productIdentifiers: identifiers)
        productInfoReq?.delegate = self
        productInfoReq?.start()
    }
    
    fileprivate func p_af5c3() {
        guard productInfoReq != nil else { return }
        productInfoReq?.delegate = nil
        productInfoReq?.cancel()
        productInfoReq = nil
    }
}

// MARK: - SKProductsRequestDelegate
extension AZPurchaseSession: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard response.products.count > 0 else {
            self.completionHandle?(.noProductId, 0, currentPayType)
            return
        }
        let payment = SKPayment(product: response.products.first!)
        SKPaymentQueue.default().add(payment)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.completionHandle?(.noProductId, 0, currentPayType)
    }
    
    func requestDidFinish(_ request: SKRequest) { }
}

// MARK: - SKPaymentTransactionObserver
extension AZPurchaseSession: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
                
            case .purchased:
                if transaction.original != nil && createOrderId == nil {
                    self.completionHandle?(.renewSucceed, 0, currentPayType)
                } else {
                    reqRetryCountDict[transaction.transactionIdentifier!] = 0
                    p_ag8d6(transaction.transactionIdentifier!, self.currentPayType)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                createOrderId = nil
                
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.completionHandle?(.failed, 0, currentPayType)
                createOrderId = nil

            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.completionHandle?(.restored, 0, currentPayType)
                createOrderId = nil
                
            case .deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.completionHandle?(.deferred, 0, currentPayType)
                createOrderId = nil
                
            @unknown default:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.completionHandle?(.unknow, 0, currentPayType)
                createOrderId = nil
                fatalError("未知的交易类型")
            }
        }
    }
 
    fileprivate func p_ag8d6(_ transactionId: String, _ payType: AZPaymentType) {
        guard let receiptStr = p_aa0d8(transactionId, payType) else {
            self.completionHandle?(.verityFail, 0, payType)
            return
        }

        if createOrderId != nil {
            switch(payType) {
            case .Pay:
                if self.payCacheList.filter({$0["transactionId"] == transactionId || $0["orderId"] == createOrderId}).count == 0 {
                    let cacheDict = ["transactionId": transactionId,
                                     "orderId": createOrderId!,
                                     "verifyData": receiptStr]
                    self.payCacheList.append(cacheDict)
                    let diskPath = self.p_y4b2()
                    NSKeyedArchiver.archiveRootObject(self.payCacheList, toFile: diskPath)
                }
                
            case .Subscribe:
                if self.subscribeCacheList.filter({$0["transactionId"] == transactionId || $0["orderId"] == createOrderId}).count == 0 {
                    let cacheDict = ["transactionId": transactionId,
                                     "orderId": createOrderId!,
                                     "verifyData": receiptStr]
                    self.subscribeCacheList.append(cacheDict)
                    let diskPath = self.p_z7c5()
                    NSKeyedArchiver.archiveRootObject(self.subscribeCacheList, toFile: diskPath)
                }
            }
        }
        
        var reqCount = reqRetryCountDict[transactionId] ?? 0
        reqCount += 1
        reqRetryCountDict[transactionId] = reqCount
        if reqCount > APPLE_IAP_MAX_RETRY_COUNT {
            self.completionHandle?(.verityFail, 0, payType)
            return
        }
        
        switch(payType) {
        case .Pay:
            let paramsArr = self.payCacheList.filter({$0["transactionId"] == transactionId})
            guard paramsArr.count > 0 else { return }
            p_ai4f2(transactionId, params: paramsArr.first!)
            
        case .Subscribe:
            let paramsArr = self.subscribeCacheList.filter({$0["transactionId"] == transactionId})
            guard paramsArr.count > 0 else { return }
            p_ak0b8(transactionId, params: paramsArr.first!)
        }
    }
}
