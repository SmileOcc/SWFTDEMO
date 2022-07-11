//
//  YXPersonalDataViewModel.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import URLNavigator
import NSObject_Rx
import QMUIKit
import QCloudCOSXML
import Photos

class YXPersonalDataViewModel: HUDServicesViewModel, HasDisposeBag {
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXUserService & HasYXGlobalConfigService
    
    var navigator: NavigatorServicesType!
    
    let alertSubject = PublishSubject<Bool>()
    
    
    var image:UIImage?
    var tempPath:String?
    var assets:Array<Any>?
    var imageUrl:String = YXUserManager.shared().curLoginUser?.avatar ?? ""
    
    var picTokenResponse: YXResultResponse<YXQCloudToken>?
    /*更新用户基本信息
     update-base-user-info/v1 */
    var updateUserInfoResponse: YXResultResponse<JSONAny>?
    //let successSubject = PublishSubject<Bool>()
    
    var services: Services! {
        didSet {
            /*更新用户基本信息
             update-base-user-info/v1 */
            updateUserInfoResponse = {[weak self](response) in
                guard let `self` = self else {return}
                
                self.hudSubject.onNext(.hide)
                switch response {
                case .success(let result , let code):
                    switch code {
                    case .success?:
                        YXUserManager.shared().curLoginUser?.avatar = self.imageUrl
                        YXUserManager.saveCurLoginUser()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateUserInfo), object: nil)
                    default:
                        if let msg = result.msg {
                            self.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                    
                }
            }
        }
    }
    
    //上传图片请求
    func uploadImageRequest(fileName: String, region: String, bucket: String) {
        if let temp = self.tempPath {
            self.hudSubject.onNext(.loading("", false))
            
            let url = URL(fileURLWithPath: temp)
            let put = QCloudCOSXMLUploadObjectRequest<AnyObject>()
            put.object = fileName
            put.bucket =  bucket //"user-server-public-1257884527"//"user-feedback-test-1257884527"
            put.body = url as AnyObject
            put.customHeaders.setObject("www.yxzq.com", forKey: "Referer" as NSCopying)
            
            put.sendProcessBlock = { bytesSent, totalBytesSent, totalBytesExpectedToSend in
                print("upload \(bytesSent) totalSend \(totalBytesSent) aim \(totalBytesExpectedToSend)")
            }
            
            put.finishBlock = {[weak self] outputObject, error in
                guard let strongSelf = self else {return}
                DispatchQueue.main.async(execute: {
                    if error != nil {
                        strongSelf.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "mine_upload_failure"), false))
                    } else {
                        strongSelf.imageUrl = (outputObject as! QCloudUploadObjectResult).location
                        //头像提交
                        /*更新用户基本信息
                         update-base-user-info/v1 */
                        strongSelf.services.userService.request(.updateUserInfo(avatar: strongSelf.imageUrl, nickname: nil), response: strongSelf.updateUserInfoResponse).disposed(by: strongSelf.disposeBag)
                        
                    }
                })
                
            };
            
            QCloudCOSTransferMangerService.costransfermangerService(forKey: region).uploadObject(put)
        }
        
    }
    
    //头像提交
    func headerImageSubmit() {
        
    }
    
    
    init() {
        
    }
    
}
