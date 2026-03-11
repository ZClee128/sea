import UIKit
import StoreKit
 
// 最大失败重试次数
let APPLE_IAP_MAX_RETRY_COUNT = 9

/// 支付类型
enum ApplePayType {
    case Pay        // 支付
    case Subscribe  // 订阅
}
/// 支付状态
enum AppleIAPStatus: String {
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

typealias IAPcompletionHandle = (AppleIAPStatus, Double, ApplePayType) -> Void

class AppleIAPManager: NSObject {
    
    var completionHandle: IAPcompletionHandle?
    private var productInfoReq: SKProductsRequest?
    private var reqRetryCountDict = [String: Int]()         // 记录每个交易请求重试次数
    private var payCacheList = [[String: String]]()         // 【购买】缓存数据
    private var subscribeCacheList = [[String: String]]()   // 【订阅】缓存数据
    private var createOrderId: String?                      // 当前支付服务端创建的订单id
    private var currentPayType: ApplePayType = .Pay         // 当前支付类型
    
    // singleton
    static let shared = AppleIAPManager()
    override func copy() -> Any { return self }
    override func mutableCopy() -> Any { return self }
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        // 监听应用将要销毁
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }

    // MARK: - NotificationCenter
    @objc func appWillTerminate() {
        SKPaymentQueue.default().remove(self as SKPaymentTransactionObserver)
    }
}

// MARK: - 【苹果购买】业务接口
extension AppleIAPManager {
    /// 【购买】创建业务订单
    /// - Parameters:
    ///   - productId: 产品Id
    ///   - block: 回调
    fileprivate func al_7206(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
        let reqModel = AppRequestModel.init()
        reqModel.requestPath = "mf/recharge/createApplePay"
        var dict = Dictionary<String, Any>()
        dict["productId"] = productId
        dict["source"] = source
        reqModel.params = dict
        AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
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
    
    /// 【购买】上传支付信息到服务器验证
    /// - Parameters:
    ///   - transaction: 交易信息
    ///   - params: 接口参数
    fileprivate func fv_12ef(_ transactionId: String, params: [String: String]) {
        let reqModel = AppRequestModel.init()
        reqModel.requestPath = "mf/recharge/applePayNotify"
        reqModel.params = params
        AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
            guard succeed == true || errorModel?.errorCode == 405 else { // 验证接口失败，重试接口
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.ek_67e4(transactionId, .Pay)
                }
                return
            }

            let dict = result as? [String: Any]
            let reportMoney: Double = {
                if let d = dict?["reportMoney"] as? Double { return d }
                return 0
            }()
            
            // 过滤已验证成功的订单数据
            let newPayCacheList = self.payCacheList.filter({$0["transactionId"] != transactionId})
            let diskPath = self.gb_1a8e()
            NSKeyedArchiver.archiveRootObject(newPayCacheList, toFile: diskPath)
                        
            // 成功回调
            self.completionHandle?(.veritySucceed, reportMoney, .Pay)
        }
    }
}

// MARK: - 【苹果订阅】业务接口
extension AppleIAPManager {
    /// 【订阅】创建业务订单
    /// - Parameters:
    ///   - productId: 产品Id
    ///   - block: 回调
    fileprivate func vh_28a7(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
        let reqModel = AppRequestModel.init()
        reqModel.requestPath = "mf/AutoSub/AppleCreateOrder"
        var dict = Dictionary<String, Any>()
        dict["productId"] = productId
        dict["source"] = source
        reqModel.params = dict
        AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
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
    
    /// 【订阅】上传支付信息到服务器验证
    /// - Parameters:
    ///   - transaction: 交易信息
    ///   - params: 接口参数
    fileprivate func qd_4928(_ transactionId: String, params: [String: String]) {
        let reqModel = AppRequestModel.init()
        reqModel.requestPath = "mf/AutoSub/ApplePaySuccess"
        reqModel.params = params
        AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
            guard succeed == true || errorModel?.errorCode == 405 else { // 验证接口失败，重试接口
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    self.ek_67e4(transactionId, .Subscribe)
                }
                return
            }

            let dict = result as? [String: Any]
            let reportMoney: Double = {
                if let d = dict?["reportMoney"] as? Double { return d }
                return 0
            }()

            // 过滤已验证成功的订单数据
            let newSubscribeCacheList = self.subscribeCacheList.filter({$0["transactionId"] != transactionId})
            let diskPath = self.ex_627b()
            NSKeyedArchiver.archiveRootObject(newSubscribeCacheList, toFile: diskPath)
 
            // 成功回调
            self.completionHandle?(.veritySucceed, reportMoney, .Subscribe)
        }
    }
}

// MARK: - Event
extension AppleIAPManager {
    /// 初始化数据
    private func jr_63a0() {
        self.payCacheList = vd_157d(payType: .Pay)
        self.subscribeCacheList = vd_157d(payType: .Subscribe)
        self.createOrderId = nil
    }
    
    /// 获取缓存列表
    /// - Parameter payType: 支付类型
    /// - Returns: 缓存列表
    private func vd_157d(payType: ApplePayType) -> [[String: String]] {
        var list: [[String: String]]?
        var diskPath = ""
        if payType == .Pay {
            diskPath = gb_1a8e()
        } else {
            diskPath = ex_627b()
        }
        
        if FileManager.default.fileExists(atPath: diskPath) {
            list = NSKeyedUnarchiver.unarchiveObject(withFile: diskPath) as? [[String: String]]
            if list == nil {
               try? FileManager.default.removeItem(atPath: diskPath)
            }
        }
        if list == nil {
            list = [[String: String]]()
        }
        return list!
    }
    
    /// 获取【购买】缓存路径【和uid关联】
    /// - Returns: 缓存路径
    private func gb_1a8e() -> String {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent("App")
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: appDirectoryPath) == false {
           try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
        }
    
        let filePath = (appDirectoryPath as NSString).appendingPathComponent("OrderTransactionInfo_Cache")
        return filePath
    }
    
    /// 获取【订阅】缓存路径【和uid关联】
    /// - Returns: 缓存路径
    private func ex_627b() -> String {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent("App")
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: appDirectoryPath) == false {
           try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
        }
    
        let filePath = (appDirectoryPath as NSString).appendingPathComponent("OrderTransactionInfo_Subscribe_Cache")
        return filePath
    }
 
    /// 获取本地收据数据
    /// - Parameters:
    ///   - transactionId: 收据标识符
    ///   - payType: 支付类型
    /// - Returns: 收据数据
    fileprivate func aa_54c1(_ transactionId: String, _ payType: ApplePayType) -> String? {
        // 有未完成的订单，先取缓存
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

        // 取本地
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return nil }
        let data = NSData(contentsOf: receiptUrl)
        let receiptStr = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        return receiptStr
    }
}

// MARK: - 失败重试流程
extension AppleIAPManager {
    /// 检测未完成的苹果支付【只会重试当前登录用户】
    func rr_66e0() {
        jr_63a0()

        // 【购买】失败重试
        for dict in self.payCacheList {
            cq_2683(dict["transactionId"], .Pay)
        }
        
        // 【订阅】失败重试
        for dict in self.subscribeCacheList {
            cq_2683(dict["transactionId"], .Subscribe)
        }
    }
    
    /// 失败重试
    /// - Parameters:
    ///   - transactionId: Id
    ///   - payType: 支付类型
    private func cq_2683(_ transactionId: String?, _ payType: ApplePayType) {
        guard let transactionId = transactionId else { return }
        // 初始化每个交易请求次数
        reqRetryCountDict[transactionId] = 0
        // 3. 服务端校验流程
        ek_67e4(transactionId, payType)
    }
}

// MARK: - 苹果正常支付流程
extension AppleIAPManager {
    /// 发起苹果支付【1.创建订单； 2.发起苹果支付； 3.服务端校验】
    /// - Parameters:
    ///   - purchID: 产品ID
    ///   - payType: 支付类型
    ///   - handle: 回调
    ///   - source: 0 常规充值 1 观看视频后充值或订阅
    func wz_5be6(productId: String, payType: ApplePayType, source: Int = 0, handle: @escaping IAPcompletionHandle) {
        jr_63a0()
        self.completionHandle = handle
        self.currentPayType = payType
        
        // 1. 根据类型创建订单
        switch(payType) {
        case .Pay:
            al_7206(productId: productId, source: source) { [weak self] orderId, succeed in
                guard let self = self else { return }
                guard succeed == true && orderId != nil else { // 订单创建失败
                    self.completionHandle?(.createOrderFail, 0, .Pay)
                    return
                }
                
                self.createOrderId = orderId
                self.requestProductInfo(productId)
            }
        
        case .Subscribe:
            vh_28a7(productId: productId, source: source) { [weak self] orderId, succeed in
                guard let self = self else { return }
                guard succeed == true && orderId != nil else { // 订单创建失败
                    self.completionHandle?(.createOrderFail, 0, .Subscribe)
                    return
                }
                
                self.createOrderId = orderId
                self.requestProductInfo(productId)
            }
        }
    }
        
    // 2 发起苹果支付，查询apple内购商品
    fileprivate func requestProductInfo(_ productId: String) {
        guard SKPaymentQueue.canMakePayments() else {
            self.completionHandle?(.notArrow, 0, currentPayType)
            return
        }
        
        // 销毁当前请求
        self.vg_7463()
        // 查询apple内购商品
        let identifiers: Set<String> = [productId]
        productInfoReq = SKProductsRequest(productIdentifiers: identifiers)
        productInfoReq?.delegate = self
        productInfoReq?.start()
    }
    
    // 销毁当前请求
    fileprivate func vg_7463() {
        guard productInfoReq != nil else { return }
        productInfoReq?.delegate = nil
        productInfoReq?.cancel()
        productInfoReq = nil
    }
}

// MARK: - SKProductsRequestDelegate【商品查询】
extension AppleIAPManager: SKProductsRequestDelegate {
    // 查询apple内购商品成功回调
     func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
         guard response.products.count > 0 else {
             self.completionHandle?( .noProductId, 0, currentPayType)
             return
         }
         
         let payment = SKPayment(product: response.products.first!)
         SKPaymentQueue.default().add(payment)
     }
    
    // 查询apple内购商品失败
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.completionHandle?( .noProductId, 0, currentPayType)
    }
    
    // 查询apple内购商品完成
    func requestDidFinish(_ request: SKRequest) {
        
    }
}

// MARK: - SKPaymentTransactionObserver【支付回调】
extension AppleIAPManager: SKPaymentTransactionObserver {
    /// 2.2 apple内购完成回调
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:  // 交易中
                break
                
            case .purchased:   // 交易成功
                /**
                 original.transactionIdentifier 首次订阅时为nil，transaction.transactionIdentifier有值；
                 后续自动订阅、续订时，original.transactionIdentifier为首次订阅时生成的transaction.transactionIdentifier，值固定不变；
                 每次订阅transaction.transactionIdentifier都不一样，为当前交易的标识；
                 */
                if transaction.original != nil && createOrderId == nil { // 启动自动续订时，不需要调用服务端验证接口
                    self.completionHandle?(.renewSucceed, 0, currentPayType)
                } else { // 普通购买和订阅
                    // 初始化每个交易请求次数
                    reqRetryCountDict[transaction.transactionIdentifier!] = 0
                    // 3. 服务端校验流程
                    ek_67e4(transaction.transactionIdentifier!, self.currentPayType)
                }
                // 移除苹果支付系统缓存
                SKPaymentQueue.default().finishTransaction(transaction)
                createOrderId = nil
                
            case .failed:      // 交易失败/取消
                SKPaymentQueue.default().finishTransaction(transaction)
                self.completionHandle?(.failed, 0, currentPayType)
                createOrderId = nil

            case .restored:    // 已购买过该商品
                SKPaymentQueue.default().finishTransaction(transaction)
                self.completionHandle?(.restored, 0, currentPayType)
                createOrderId = nil
                
            case .deferred:    // 交易延期
                SKPaymentQueue.default().finishTransaction(transaction)
                self.completionHandle?(.deferred, 0, currentPayType)
                createOrderId = nil
                
            @unknown default:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.completionHandle?(.unknow, 0, currentPayType)
                createOrderId = nil
                fatalError(" 未知的交易类型")
            }
        }
    }
 
    /// 3. 服务端校验流程
    /// - Parameters:
    ///   - transactionId: 交易唯一标识符
    ///   - payType: 支付类型
    fileprivate func ek_67e4(_ transactionId: String, _ payType: ApplePayType) {
        guard let receiptStr = aa_54c1(transactionId, payType) else {
            self.completionHandle?(.verityFail, 0, payType)
            return
        }

        // 缓存支付成功信息，防止接口校验失败
        if createOrderId != nil { // 正常支付流程
            switch(payType) {
            case .Pay:
                if self.payCacheList.filter({$0["transactionId"] == transactionId || $0["orderId"] == createOrderId}).count == 0 {  // 防止重复添加缓存数据
                    let cacheDict = ["transactionId": transactionId,
                                     "orderId": createOrderId!,
                                     "verifyData": receiptStr]
                    self.payCacheList.append(cacheDict)
                    let diskPath = self.gb_1a8e()
                    NSKeyedArchiver.archiveRootObject(self.payCacheList, toFile: diskPath)
                }
                
            case .Subscribe:
                if self.subscribeCacheList.filter({$0["transactionId"] == transactionId || $0["orderId"] == createOrderId}).count == 0 { // 防止重复添加缓存数据
                    let cacheDict = ["transactionId": transactionId,
                                     "orderId": createOrderId!,
                                     "verifyData": receiptStr]
                    self.subscribeCacheList.append(cacheDict)
                    let diskPath = self.ex_627b()
                    NSKeyedArchiver.archiveRootObject(self.subscribeCacheList, toFile: diskPath)
                }
            }
        }
        
        // 限制交易重试最大次数
        var reqCount = reqRetryCountDict[transactionId] ?? 0
        reqCount += 1
        reqRetryCountDict[transactionId] = reqCount
        if reqCount > APPLE_IAP_MAX_RETRY_COUNT {
            self.completionHandle?(.verityFail, 0, payType)
            return
        }
        
        // 3.服务端校验，根据transactionId从缓存中取
        switch(payType) {
        case .Pay:
            let paramsArr = self.payCacheList.filter({$0["transactionId"] == transactionId})
            guard paramsArr.count > 0 else { return }
            fv_12ef(transactionId, params: paramsArr.first!)
            
        case .Subscribe:
            let paramsArr = self.subscribeCacheList.filter({$0["transactionId"] == transactionId})
            guard paramsArr.count > 0 else { return }
            qd_4928(transactionId, params: paramsArr.first!)
        }
    }
}
