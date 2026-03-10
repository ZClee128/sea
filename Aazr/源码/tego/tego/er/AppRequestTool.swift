import UIKit
import Alamofire
import CoreMedia
import HandyJSON
 
typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: AppErrorResponse?) -> Void
 
@objc class AppRequestTool: NSObject {
    class func p_r3a1(model: AppRequestModel, completion: @escaping FinishBlock) {
        let serverUrl = self.p_t9c7(model: model)
        let headers = self.p_u2d0(model: model)
        AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
            switch responseData.result {
            case .success:
                p_s6b4(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)
                
            case .failure:
                completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "Net Error, Try again later"))
            }
        }
    }
    
    class func p_s6b4(model: AppRequestModel, response: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
        var responseJson = String(data: responseData, encoding: .utf8)
        responseJson = responseJson?.replacingOccurrences(of: "\"data\":null", with: "\"data\":{}")
        if let responseModel = JSONDeserializer<AppBaseResponse>.deserializeFrom(json: responseJson) {
            if responseModel.errno == RequestResultCode.Normal.rawValue {
                completion(true, responseModel.data, nil)
            } else {
                completion(false, responseModel.data, AppErrorResponse.init(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                switch responseModel.errno {
                default:
                    break
                }
            }
        } else {
            completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "json error"))
        }
    }
    
    class func p_t9c7(model: AppRequestModel) -> String {
        var serverUrl: String = model.requestServer
        let otherParams = "platform=iphone&version=\(AppNetVersion)&packageId=\(PackageID)&bundleId=\(AppBundle)&lang=\(UIDevice.interfaceLang)"
        if !model.requestPath.isEmpty {
            serverUrl.append("/\(model.requestPath)")
        }
        serverUrl.append("?\(otherParams)")
        return serverUrl
    }
    
    class func p_u2d0(model: AppRequestModel) -> HTTPHeaders {
        let userAgent = "\(AppName)/\(AppVersion) (\(AppBundle); build:\(AppBuildNumber); iOS \(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        let headers = [HTTPHeader.userAgent(userAgent)]
        return HTTPHeaders(headers)
    }
}
 
