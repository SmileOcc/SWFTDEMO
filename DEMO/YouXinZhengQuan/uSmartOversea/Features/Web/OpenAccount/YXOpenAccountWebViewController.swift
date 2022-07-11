//
//  YXOpenAccountWebViewController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/12/28.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import MGFaceIDLiveDetect

class YXOpenAccountWebViewController: YXWebViewController {
    
//    var portraitSuccessCallback: String?, portraitErrorCallback: String?, nationalEmblemSuccessCallback: String?, nationalEmblemErrorCallback: String?
//    var idCardQualityFront: YXFaceIdIDCardQuality = {
//        YXFaceIdIDCardQuality()
//    }()
//
//    var idCardQualityBack: YXFaceIdIDCardQuality = {
//        YXFaceIdIDCardQuality()
//    }()
    
//    var liveStill: YXFaceIDLiveStill = {
//        return YXFaceIDLiveStill()
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        super.initUI()
    }
    
    
    func bindViewModel() {
        
    }
    
    override func webViewLoadRequest() {
        super.webViewLoadRequest()
        
        if let url = URL.init(string: YXH5Urls.YX_OPEN_ACCOUNT_URL()) {
            self.webView?.load(URLRequest.init(url: url))
        }
    }
    
    // MARK: - YXWKWebViewDelegate
    func onGetIDCardImageSideFront(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        var title: String?
        if let paramsJsonValue = paramsJsonValue {
            title = paramsJsonValue["title"] as? String
        }
        
        self.portraitSuccessCallback = successCallback
        self.portraitErrorCallback = errorCallback
        
        let cancel = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .default) { (alertController, action) in
            
        }
        cancel.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel2(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        let scan = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "scan_taking_pictures"), style: .default) { (alertController, action) in
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            guard authStatus != .restricted && authStatus != .denied else {
                if let webView = self.webView, let errorCallback = self.portraitErrorCallback {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "no_camera"), callback: errorCallback)
                }
                return
            }
            
            if authStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                    if granted {
                        DispatchQueue.main.async(execute: {
                            self.idCardQualityFront.startDetect(viewController: self, shootPage: .Portrait)
                        })
                    }
                })
            } else {
                self.idCardQualityFront.startDetect(viewController: self, shootPage: .Portrait)
            }
        }
        scan.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        
        let camera = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "common_taking_pictures"), style: .default) { (alertController, action) in
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            guard authStatus != .restricted && authStatus != .denied else {
                if let webView = self.webView, let errorCallback = self.portraitErrorCallback {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "no_camera"), callback: errorCallback)
                }
                return
            }
            
            if authStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                    if granted {
                        DispatchQueue.main.async(execute: {
                            self.idCardQualityFront.startSystemCapture(viewController: self, shootPage: .Portrait)
                        })
                    }
                })
            } else {
                self.idCardQualityFront.startSystemCapture(viewController: self, shootPage: .Portrait)
            }
        }
        camera.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        
        let album = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "camera_up"), style: .default) { (alertController, action) in
            self.chooseImage(withMode: .album)
            self.chooseImageOrFileSuccessCallback = successCallback
            self.chooseImageOrFileErrorCallback = errorCallback
        }
        album.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        
        let alertController = YXAlertViewController(title: title, message: nil, preferredStyle: .actionSheet)
        alertController.defaultSheetConfig()
        alertController.addAction(scan)
        alertController.addAction(camera)
        alertController.addAction(album)
        alertController.addAction(cancel)
        alertController.showWith(animated: true)
    }
    
    func onGetIDCardImageSideBack(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        var title: String?
        if let paramsJsonValue = paramsJsonValue {
            title = paramsJsonValue["title"] as? String
        }
        
        self.nationalEmblemSuccessCallback = successCallback
        self.nationalEmblemErrorCallback = errorCallback
        
        let cancel = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .default) { (alertController, action) in
            
        }
        cancel.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel2(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        let scan = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "scan_taking_pictures"), style: .default) { (alertController, action) in
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            guard authStatus != .restricted && authStatus != .denied else {
                if let webView = self.webView, let errorCallback = self.nationalEmblemErrorCallback {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "no_camera"), callback: errorCallback)
                }
                return
            }
            
            if authStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                    if granted {
                        DispatchQueue.main.async(execute: {
                            self.idCardQualityBack.startDetect(viewController: self, shootPage: .NationalEmblem);
                        })
                    }
                })
            } else {
                self.idCardQualityBack.startDetect(viewController: self, shootPage: .NationalEmblem);
            }
        }
        scan.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        
        let camera = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "common_taking_pictures"), style: .default) { (alertController, action) in
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            guard authStatus != .restricted && authStatus != .denied else {
                if let webView = self.webView, let errorCallback = self.nationalEmblemErrorCallback {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "no_camera"), callback: errorCallback)
                }
                return
            }
            
            if authStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                    if granted {
                        DispatchQueue.main.async(execute: {
                            self.idCardQualityBack.startSystemCapture(viewController: self, shootPage: .NationalEmblem)
                        })
                    }
                })
            } else {
                self.idCardQualityBack.startSystemCapture(viewController: self, shootPage: .NationalEmblem)
            }
        }
        camera.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        
        let album = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "camera_up"), style: .default) { (alertController, action) in
            self.chooseImage(withMode: .album)
            self.chooseImageOrFileSuccessCallback = successCallback
            self.chooseImageOrFileErrorCallback = errorCallback
        }
        album.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        
        let alertController = YXAlertViewController(title: title, message: nil, preferredStyle: .actionSheet)
        alertController.defaultSheetConfig()
        alertController.addAction(scan)
        alertController.addAction(camera)
        alertController.addAction(album)
        alertController.addAction(cancel)
        alertController.showWith(animated: true)
    }
    
    override func onGetMegLiveData(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        var idCardName: String?, idCardNumber: String?, bizToken: String?
        if let paramsJsonValue = paramsJsonValue {
            idCardName = paramsJsonValue["idcard_name"] as? String
            idCardNumber = paramsJsonValue["idcard_number"] as? String
            bizToken = paramsJsonValue["biz_token"] as? String
        }
        
        self.megLiveSuccessCallback = successCallback
        self.megLiveErrorCallback = errorCallback
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        guard authStatus != .restricted && authStatus != .denied else {
            if let webView = self.webView, let errorCallback = self.megLiveErrorCallback {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorCode: Int(MGFaceIDLiveDetectErrorNotCameraPermission.rawValue), errorMessage: "NO_CAMERA_PERMISSION", callback: errorCallback)
            }
            return
        }
        
        if let idCardName = idCardName,
            let idCardNumber = idCardNumber {
            
            QMUITips.showLoading(YXLanguageUtility.kLang(key: "common_loading"), in: self.view)
            //有源比对
            self.liveStill.startDetect(idCardName: idCardName, idCardNumber: idCardNumber, bizToken: bizToken, currentVC: self) { [weak self] (dictionary, error) in
                guard let `self` = self else { return }
                
                QMUITips.hideAllTips(in: self.view)
                if let dictionary = dictionary {
                    if let theJSONData = try?  JSONSerialization.data(
                        withJSONObject: dictionary,
                        options: .prettyPrinted
                        ),
                        let jsonText = String(data: theJSONData,
                                              encoding: String.Encoding.ascii) {
                        if let webView = self.webView, let successCallback = self.megLiveSuccessCallback {
                            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonText, callback: successCallback)
                        }
                    }
                } else {
                    if let errorCallback = self.megLiveErrorCallback {
                        if let webView = self.webView, let error = error {
                            YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorCode: Int(error.code.rawValue), errorMessage: error.errorMessageStr, callback: errorCallback)
                        }
                    }
                }
            }
        } else {
            if let webView = self.webView, let errorCallback = errorCallback {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorCode: Int(MGFaceIDLiveDetectErrorUnknown.rawValue), errorMessage: YXLanguageUtility.kLang(key: "common_unknown_error"), callback: errorCallback)
            }
        }
    }
    
    
    
    // MARK: - YXFaceIdIDCardQualityProtocol
    override func detectFinish(portraitImage: UIImage?) {
        if let portraitImage = portraitImage {
            let imageData = portraitImage.jpegData(compressionQuality: 0.7)
            if let encodeData = imageData?.base64EncodedString() {
                if let webView = self.webView, let successCallback = self.portraitSuccessCallback {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: encodeData, callback: successCallback)
                }
            } else {
                if let webView = self.webView, let errorCallback = self.portraitErrorCallback {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "identify_failure"), callback: errorCallback)
                }
            }
        }
    }
    
    override func detectFinish(emblemImage: UIImage?) {
        if let emblemImage = emblemImage {
            let imageData = emblemImage.jpegData(compressionQuality: 0.7)
            if let encodeData = imageData?.base64EncodedString() {
                if let webView = self.webView, let successCallback = self.nationalEmblemSuccessCallback {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: encodeData, callback: successCallback)
                }
            } else {
                if let webView = self.webView, let errorCallback = self.nationalEmblemErrorCallback {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "identify_failure"), callback: errorCallback)
                }
            }
        }
    }
}
