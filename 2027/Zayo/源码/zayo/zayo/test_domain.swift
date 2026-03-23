import Foundation
let app_lowerData:String = "codemast"
let user_imageRemotePath:String = "ralax"
let ReplaceUrlDomain = (app_lowerData.replacingOccurrences(of: "mast", with: "") + user_imageRemotePath.replacingOccurrences(of: "ra", with: "ga").replacingOccurrences(of: "ax", with: "x"))

let b: [UInt8] = [0x63, 0x6f, 0x64, 0x65, 0x67, 0x61, 0x6c, 0x78]
let oldReplaceUrlDomain = String(bytes: b, encoding: .utf8) ?? ""

print("New: \(ReplaceUrlDomain)")
print("Old: \(oldReplaceUrlDomain)")
print("Equal: \(ReplaceUrlDomain == oldReplaceUrlDomain)")
