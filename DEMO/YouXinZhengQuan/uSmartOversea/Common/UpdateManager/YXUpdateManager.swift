//
//  YXUpdateManager.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import MMKV
import YXKit

class YXUpdateManager: NSObject {
    static let shared = YXUpdateManager()
    
    private let updateUrlKey = "updateUrlKey"
    private let latestVersionKey = "latestVersionKey"
    private let showedTimesKey = "showedTimesKey"
    private let latestShowTimeKey = "latestShowTimeKey"
    private let storeUrlKey = "storeUrlKey"
    
    @objc static let certFileName = YXMoyaConfig.certFileName
    
    @objc var updateUrlString: String {
        set {
            MMKV.default().set(newValue, forKey: updateUrlKey)
        }
        get {
            let string = MMKV.default().object(of: NSString.self, forKey: updateUrlKey) as? String
            return (string != nil) ? string! : ""
        }
    }
    
    @objc var updated: Bool = false
    
    // 用于记录是否关闭了升级窗口，或者确定无须升级
    @objc dynamic var finishedUpdatePop = false
    
    var latestVersion: String {
        set {
            MMKV.default().set(newValue, forKey: latestVersionKey)
        }
        get {
            let string = MMKV.default().object(of: NSString.self, forKey: latestVersionKey) as? String
            return (string != nil) ? string! : ""
        }
    }
    
    var showedTimes: Int32 {
        set {
            MMKV.default().set(newValue, forKey: showedTimesKey)
        }
        get {
            MMKV.default().int32(forKey: showedTimesKey)
        }
    }
    
    var latestShowTime: Int64 {
        set {
            MMKV.default().set(newValue, forKey: latestShowTimeKey)
        }
        get {
            MMKV.default().int64(forKey: latestShowTimeKey)
        }
    }
    
    var storeUrl: String {
        set {
            MMKV.default().set(newValue, forKey: storeUrlKey)
        }
        get {
            MMKV.default().object(of: NSString.self, forKey: storeUrlKey) as? String ?? ""
        }
    }
    
    @objc var needUpdate: Bool {
        get {
            self.latestVersion > (YXConstant.appVersion ?? "")
        }
    }
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNetWorkChangeNotification), name: Notification.Name.init(rawValue: "kReachabilityChangedNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func copy() -> Any {
        self
    }
    
    override func mutableCopy() -> Any {
        self
    }
    
    @objc func handleNetWorkChangeNotification(ntf: Notification) {
        if let reachability = ntf.object as? HLNetWorkReachability {
            let netWorkStatus = reachability.currentReachabilityStatus()

            if self.updated == false, netWorkStatus != .notReachable {
                checkUpdate()
            }
        }
    }
    
    func checkUpdate() {
        updateRequest()
    }
    
    func certificateCached() -> Bool {
        guard
            let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return false
        }
        
        let file = document.appendingPathComponent(YXUpdateManager.certFileName)
        return FileManager.default.fileExists(atPath: file.path)
    }
    
    func certificateFile() -> URL? {
        guard
            let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return nil
        }
        
        let file = document.appendingPathComponent(YXUpdateManager.certFileName)
        return file
    }
    
    func cachedCertificateMD5String() -> String {
        if
            certificateCached(),
            let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let file = document.appendingPathComponent(YXUpdateManager.certFileName)
            if let certData = try? Data.init(contentsOf: file) {
                return (certData as NSData).md5String()
            }
        }
        return ""
    }
    
    func certificateFileMd5() -> String {
        // 1. 是否有缓存文件，如果有则先读取缓存文件
        if certificateCached() {
            return cachedCertificateMD5String()
        } else {
            // 2. 如果没有缓存文件，则读取内置文件
            if let url = Bundle.main.url(forResource: "certificate", withExtension: "cer"), let certData = try? Data.init(contentsOf: url) {
                return (certData as NSData).md5String()
            }
        }
        return ""
    }
    
    func startDownloadCertificate(url: String, md5: String) {
        if let url = URL(string: url) {
            let semaphore = DispatchSemaphore (value: 0)
            
            var request = URLRequest(url: url,timeoutInterval: 3000)
            request.httpMethod = "GET"

            let task = URLSession.shared.downloadTask(with: request) { (url, response, error) in
                guard
                    let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                    let url = url
                else {
                    semaphore.signal()
                    return
                }

                do {
                    if let tmpCertData = try? Data.init(contentsOf: url),
                        (tmpCertData as NSData).md5String() == md5 {
                        
                        let file = document.appendingPathComponent(YXUpdateManager.certFileName)
                        
                        // 如果文件已经存在，则先尝试移除文件
                        if FileManager.default.fileExists(atPath: file.path) {
                            try FileManager.default.removeItem(at: file)
                        }
                        try FileManager.default.moveItem(atPath: url.path,
                                                         toPath: file.path)
                        
                        // 提醒用户重新启动App
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            let message = YXLanguageUtility.kLang(key: "cert_renewal_tip")
                            let confirm = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "cert_reboot"), style: .default) { (alertController, action) in
                                exit(0)
                            }
                            let alertController = QMUIAlertController(title: YXLanguageUtility.kLang(key: "cert_update"), message: message, preferredStyle: .alert)
                            alertController.addAction(confirm)
                            alertController.showWith(animated: true)
                        }
                    } else {
                        try FileManager.default.removeItem(at: url)
                        
                        // 如果下载的文件MD5与服务器下发的MD5不一样，证明文件下载不完整
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            // 提醒用户重新启动App
                            let message = YXLanguageUtility.kLang(key: "cert_invalid_tip")
                            let confirm = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "cert_reboot"), style: .default) { (alertController, action) in
                                exit(0)
                            }
                            let alertController = QMUIAlertController(title: YXLanguageUtility.kLang(key: "cert_update"), message: message, preferredStyle: .alert)
                            alertController.addAction(confirm)
                            alertController.showWith(animated: true)
                        }
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
                
                semaphore.signal()
            }

            task.resume()
            semaphore.wait()
        }
    }
    
    func updateRequest() {
        let requestModel = YXUpdateRequestModel()
        requestModel.yhc = self.certificateFileMd5()
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { [weak self] (model)  in
            guard let strongSelf = self else { return }
            if let responeModel = model as? YXUpdateResponseModel, responeModel.code == .success  {
                // 如果后台有返回新的证书，则下载新的https证书，并在下载完毕后提醒用户重新启动App
                if !responeModel.fileUrl.isEmpty {
                    // 如果后台返回了证书下载地址，则证明有新证书了，应该下载新证书
                    strongSelf.startDownloadCertificate(url: responeModel.fileUrl, md5: responeModel.md5)
                }
                if strongSelf.updated == true {
                    return
                }
                strongSelf.updated = true

                let version = responeModel.versionNo
                if responeModel.update {
                    let title = responeModel.title
                    let content = responeModel.content
                    let systemTime = responeModel.systemTime
                    let times = responeModel.times
                    let seconds = responeModel.seconds

                    strongSelf.updateUrlString = responeModel.filePath
                    switch responeModel.updateMode {
                    case 1://强制升级
                        strongSelf.latestShowTime = systemTime
                        strongSelf.showedTimes = strongSelf.showedTimes + 1

                        let alertView = YXUpdateAlertView(title: title + " V" + version, message: content, prompt:"")
                        alertView.clickedAutoHide = false

                        alertView.addAction(YXUpdateAlertAction(title: YXLanguageUtility.kLang(key: "common_go_update"), style: .fullDefault, handler: { (action) in
                            if let url = URL(string: strongSelf.updateUrlString) {
                                UIApplication.shared.open(url, completionHandler: nil)
                            } else {
                                alertView.hide()
                            }
                        }))
                            alertView.showInWindow()
                        break;
                    case 2://可取消升级
                        if strongSelf.latestVersion < version {
                            strongSelf.showedTimes = 1
                            strongSelf.latestShowTime = systemTime

                            let alertView = YXUpdateAlertView(title: title + " V" + version, message: content, prompt:"")
                            alertView.clickedAutoHide = false

                            alertView.addAction(YXUpdateAlertAction(title: YXLanguageUtility.kLang(key: "common_go_update"), style: .fullDefault, handler: { (action) in
                                if let url = URL(string: strongSelf.updateUrlString) {
                                    UIApplication.shared.open(url, completionHandler: nil)
                                }
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXPopManager.kNotificationName), object: nil, userInfo:nil)
                            }))

                            let bgView = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: YXConstant.screenHeight))
                            bgView.addSubview(alertView)

                            let button = UIButton(type: .custom)
                            button.setImage(UIImage(named: "pop_close_update"), for: .normal)
                            bgView.addSubview(button)

                            _ = button.rx.tap.subscribe(onNext: { (_) in
                                strongSelf.finishedUpdatePop = true
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXPopManager.kNotificationName), object: nil, userInfo:nil)
                                bgView.hide()
                            })

                            button.snp.makeConstraints { (make) in
                                make.width.height.equalTo(37)
                                make.top.equalTo(alertView.snp.bottom).offset(30)
                                make.centerX.equalToSuperview()
                            }
                            bgView.showInWindow()
                            
                        } else if  strongSelf.latestVersion == version, strongSelf.showedTimes < times, systemTime - strongSelf.latestShowTime > seconds {
                            strongSelf.showedTimes = strongSelf.showedTimes + 1
                            strongSelf.latestShowTime = systemTime

                            let alertView = YXUpdateAlertView(title: title + " V" + version, message: content, prompt:"")
                            alertView.clickedAutoHide = false

                            alertView.addAction(YXUpdateAlertAction(title: YXLanguageUtility.kLang(key: "common_go_update"), style: .fullDefault, handler: { (action) in
                                if let url = URL(string: strongSelf.updateUrlString) {
                                    UIApplication.shared.open(url)
                                }
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXPopManager.kNotificationName), object: nil, userInfo:nil)
                            }))

                            let bgView = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: YXConstant.screenHeight))
                            bgView.addSubview(alertView)

                            //关闭按钮
                            let button = UIButton(type: .custom)
                            button.setImage(UIImage(named: "pop_close_update"), for: .normal)
                            bgView.addSubview(button)

                            _ = button.rx.tap.subscribe(onNext: { (_) in
                                strongSelf.finishedUpdatePop = true
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXPopManager.kNotificationName), object: nil, userInfo:nil)
                                bgView.hide()
                            })

                            button.snp.makeConstraints { (make) in
                                make.width.height.equalTo(37)
                                make.top.equalTo(alertView.snp.bottom).offset(30)
                                make.centerX.equalToSuperview()
                            }
                            bgView.showInWindow()
                        } else {
                            strongSelf.finishedUpdatePop = true
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXPopManager.kNotificationName), object: nil, userInfo:nil)
                        }

                        break;
                    case 3://手动升级
                        strongSelf.finishedUpdatePop = true
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXPopManager.kNotificationName), object: nil, userInfo:nil)

                        break;

                    default:
                        strongSelf.finishedUpdatePop = true
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXPopManager.kNotificationName), object: nil, userInfo:nil)
                        break;
                    }
                } else {
                    strongSelf.showedTimes = 0
                    strongSelf.finishedUpdatePop = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXPopManager.kNotificationName), object: nil, userInfo:nil)
                }

                strongSelf.latestVersion = version
            }else{
                self?.finishedUpdatePop = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXPopManager.kNotificationName), object: nil, userInfo:nil)
            }
            
        }) { [weak self](request) in
            
        }
    }
}
