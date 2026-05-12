import Foundation
 
class AppRequestModel: NSObject {
    
    @objc var requestPath: String = ""
    var requestServer: String = ""
    var params: Dictionary<String, Any> = [:]
    
    override init() {
        self.requestServer = "http://app.\(_mb3hezxv2).com"
    }
}

/// 通用Model
struct AppBaseResponse {
    var errno: Int   // 服务端返回码
    var msg: String? // 服务端返回码
    var data: Any?   // 具体的data的格式和业务相关，故用泛型定义
    
    init?(dictionary: [String: Any]) {
        guard let errno = dictionary["errno"] as? Int else { return nil }
        self.errno = errno
        self.msg = dictionary["msg"] as? String
        if let data = dictionary["data"] {
            self.data = data is NSNull ? [:] : data
        } else {
            self.data = nil
        }
    }
}

/// 通用Model
public struct AppErrorResponse {
    let errorCode: Int
    let errorMsg: String
    init(errorCode: Int, errorMsg: String) {
        self.errorCode = errorCode
        self.errorMsg = errorMsg
    }
}

enum RequestResultCode: Int {
    case Normal         = 0
    case NetError       = -10000      // w
    case NeedReLogin    = -100        // 需要重新登录
}

