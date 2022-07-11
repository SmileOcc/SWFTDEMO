//
//  YXRealLogger.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2019/7/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import SSZipArchive
import MMKV

public struct RealLog: Codable {
    let occr_time: String
    let lang_type: Int32
    let platform: String
    let platform_version: String
    let net_type: String
    let version: String
    let uuid: String
    let type: String?
    let name: String?
    let url: String?
    let code: String?
    let desc: String?
    let extend_msg: String?
    
}

let RealLogKey = "RealLogKey"

let RealLogReqTimeKey = "RealLogReqTimeKey"

// 用于处理log数据
let logQueue = DispatchQueue(label: "\(YXConstant.bundleId ?? "com.yxzq.stock").logQueue")

@objcMembers public class YXRealLogger: NSObject {
    @objc public static let shareInstance = YXRealLogger()
    
    private static let maxLogs = 200
    
    private static let triggerCount = 20
    
    private static let uploadGapTime = 300
    
    public var logList: [RealLog]
    
    
//        * 0: 接口响应成功
//        * 800000: 无小黄条
//        * 800002：无弹窗消息
//        * 806901：自选股版本号不一致
//        * 806916：自选股版本号一致
//        * 102127: 国家地区区号无更新
//        * 818007: 价值掘金无数据
//        * 810503: 推荐资讯无数据
//        * 300101: 非法TOKEN
//        * 300302: 验证码已发送，请稍等1分钟后重新获取
//        * 406451: 证券可用數量不足
//        * 410202: 當前時間段不可操作
//        * 301003: 交易密码错误，请重新输入，您还可以尝试n次
//        * 409984: Please enter transaction password
//        * 409978: 該新股不存在或不在認購中
    private static let ignoreCode = [
        "0",
        "800000",
        "800002",
        "806901",
        "806916",
        "102127",
        "818007",
        "810503",
        "300101",
        "300302",
        "406451",
        "410202",
        "301003",
        "409984",
        "409978"
    ]
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formatter
    }()
    
    override public init() {
        let jsonData = MMKV.default().object(of: NSData.self, forKey: RealLogKey) as? Data
        logList = (try? JSONDecoder().decode([RealLog].self, from: jsonData ?? Data())) ?? [RealLog]()
    }
    
    /// 在logQueue中操作logList，同时JSON解析也是在logQueue中进行
    ///
    /// - Parameter realLog: 需要添加到logList的log
    fileprivate func appendLogAndPost(_ realLog: RealLog) {
        logQueue.async {
            self.logList.append(realLog)
            
            if self.logList.count > YXRealLogger.maxLogs {
                self.logList.removeFirst();
            }
            
            let jsonData = (try? JSONEncoder().encode(self.logList)) ?? Data()
            MMKV.default().set(jsonData, forKey: RealLogKey)
            
            self.postRealLogs()
        }
    }
    
    /// 指定的URL或者code不进行上报
    /// - Parameters:
    ///   - url: 指定的URL
    ///   - code: 指定的code
    /// - Returns: 返回true则不上报，返回false则上报
    private func ignore(url: String?, code: String?) -> Bool {
        let logApi = YXLogAPI.realLog([RealLog]())
        
        if let url = url, url.contains(logApi.path) {
            return true
        }
        
        if let code = code, YXRealLogger.ignoreCode.contains(code) {
            return true
        }
        
        return false
    }
    
    @objc public func realLog(type: String?,
                              name: String?,
                              url: String?,
                              code: String?,
                              desc: String?,
                              extend_msg: String?) {
        guard !self.ignore(url: url, code: code) else {
            return
        }
    
        let occr_time = formatter.string(from: Date())
        let lang_type = YXUserHelper.currentLanguage()
        let platform = YXConstant.systemName
        let platform_version = YXConstant.systemVersion
        let net_type = YXNetworkUtil.sharedInstance().networkType()
        guard let version = YXConstant.appVersion else { return }
        let uuid = YXUserHelper.currentUUID()
        
        let realLog = RealLog(occr_time: occr_time, lang_type: lang_type, platform: platform, platform_version: platform_version, net_type: net_type, version: version, uuid: "\(uuid)", type: type, name: name, url: url, code: code, desc: desc, extend_msg: extend_msg)
        
        appendLogAndPost(realLog)
    }
    
    public func realH5Log(_ params: [String: Any]?) {
        guard let h5Log = params else { return }
        let occr_time = (h5Log["occr_time"] as? String) ?? ""
        let type = (h5Log["app_type"] as? String) ?? ""
        let name = (h5Log["name"] as? String) ?? ""
        let url = (h5Log["url"] as? String) ?? ""
        let code = (h5Log["code"] as? String) ?? ""
        let platform = (h5Log["platform"] as? String) ?? ""
        let version = (h5Log["version"] as? String) ?? ""
        let desc = (h5Log["desc"] as? String) ?? ""
        let extend_msg = (h5Log["extend_msg"] as? String) ?? ""
        
        let lang_type = YXUserHelper.currentLanguage()
        let platform_version = YXConstant.systemVersion
        let net_type = YXNetworkUtil.sharedInstance().networkType()
        let uuid = YXUserHelper.currentUUID()
        
        let realLog = RealLog(occr_time: occr_time, lang_type: lang_type, platform: platform, platform_version: platform_version, net_type: net_type, version: version, uuid: "\(uuid)", type: type, name: name, url: url, code: code, desc: desc, extend_msg: extend_msg)
        
        appendLogAndPost(realLog)
    }
    
    /// 是否可以发起上报，上报需要满足的条件：
    /// - Returns: 返回true则允许，返回false则不允许
    private func requestable() -> Bool {
        var timeFlag = false
        let currentTime = Date()
        if let lastTime = MMKV.default().date(forKey: RealLogReqTimeKey) {
            if abs(lastTime.secondsBetweenDate(toDate: currentTime)) >= YXRealLogger.uploadGapTime {
                timeFlag = true
            }
        } else {
            timeFlag = true
        }
        
        return self.logList.count >= YXRealLogger.triggerCount && timeFlag
    }
    
    public func postRealLogs() {
        logQueue.async {
            guard self.requestable() else { return }
            
            MMKV.default().set(Date(), forKey: RealLogReqTimeKey)
            #if PRD || PRD_HK
            _ = YXLogProvider.rx.request(.realLog(self.logList)).map(YXResult<JSONAny>.self).subscribe(onSuccess: { [weak self] (result) in
                if result.code == 0 {
                    self?.logList = []
                    MMKV.default().removeValue(forKey: RealLogKey)
                }
            })
            #endif
        }
    }
    
    @objc public func logZipFilePath() -> String? {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return nil }
        let directoryPath = documentPath + YXConstant.logPath
        
        guard let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return nil }
        let date = Date();
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let dateStr = formatter.string(from: date)
        let fileName = "\(YXConstant.logPath)_" + dateStr + ".zip"
        let zipPath = cachesPath + fileName
        
        // 1.将mmap3中的文件同步写入到xlog文件中
        flushSync()
        
        // 2.压缩文件
        if SSZipArchive.createZipFile(atPath: zipPath, withContentsOfDirectory: directoryPath) == true {
            return zipPath
        }
        
        return nil
    }
    
    @objc public func postPathLog(path: String, zipPath: String) {
        _ = YXLogProvider.rx.request(.pathLog(path)).map(YXResult<JSONAny>.self).subscribe(onSuccess: { (result) in
            if result.code == 0 {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: zipPath))
            }
        }, onError: { (error) in
            log(.warning, tag: kNetwork, content: "upload file log failed \(error)")
        })
     }

//    @objc public func postFileLog() {
//
//        DispatchQueue.global().async {
//
//            flushSync()
//
//            // 3.上传文件
//            if success == true {
//                _ = YXLogProvider.rx.request(.fileLog(zipPath, fileName)).map(YXResult<JSONAny>.self).subscribe(onSuccess: { (result) in
//                    if result.code == 0 {
//                        try? FileManager.default.removeItem(at: URL(fileURLWithPath: directoryPath))
//                        try? FileManager.default.removeItem(at: URL(fileURLWithPath: zipPath))
//                    }
//                }, onError: { (error) in
//                    log(.warning, tag: kNetwork, content: "upload file log failed \(error)")
//                })
//            }
//        }
//    }
}

extension Date {
    func secondsBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.second], from: self, to: toDate)
        return components.second ?? 0
    }
}
