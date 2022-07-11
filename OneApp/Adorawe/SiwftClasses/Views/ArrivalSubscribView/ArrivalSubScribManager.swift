//
//  ArrivalSubScribManager.swift
//  Adorawe
//
//  Created by fan wang on 2021/11/18.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift

@objcMembers
class ArrivalSubScribManager: NSObject {
    static let shared = ArrivalSubScribManager()
    
    private var baseInfo:OSSVDetailsBaseInfoModel!
    
    let disposeBag = DisposeBag()
    
    var goodsImage:String?
    
    func showArrivalAlert(goodsInfo:OSSVDetailsBaseInfoModel!){
        baseInfo = goodsInfo
        
        self.goodsImage = goodsInfo.goodsSmallImg
        ///接口返回状态 接口返回消息  email
        var result:Observable<(SubscribeStatus, String?, String?)>!
        var pop:zhPopupController?
        // 区分是否已登录
        if OSSVAccountsManager.shared().isSignIn{//已登录直接请求
            result =  ArrivalSubscribApi.subscribe(email: OSSVAccountsManager.shared().account.email, goodsSn: goodsInfo.goods_sn)
        }else{///未登录弹出邮箱填写
            let arrivalSubView = ArrivalSubscribView()
            arrivalSubView.goodsImageView.yy_setImage(with: URL(string:goodsInfo.goodsSmallImg ?? ""), placeholder: UIImage(named: "ProductImageLogo"))
            arrivalSubView.goodsName.text = goodsInfo.goodsTitle
            let sizeText = goodsInfo.showSizeText()
            if sizeText.isEmpty{
                arrivalSubView.sizeLabel.isHidden = true
            }
            arrivalSubView.sizeLabel.text = "\(STLLocalizedString_("size")!):\(sizeText)"
            arrivalSubView.goodsSn = goodsInfo.goods_sn
            
            pop = zhPopupController(view: arrivalSubView, size: CGSize(width: CGFloat.screenWidth - 40, height: 410))
            pop?.keyboardChangeFollowed = true
            pop?.show()
            
            arrivalSubView.closePub.subscribe(onNext:{[weak pop] in
                pop?.dismiss()
            }).disposed(by: disposeBag)
            
            result = arrivalSubView.actionPub.flatMap { email,goodsSn in
                return ArrivalSubscribApi.subscribe(email: email, goodsSn: goodsSn)
            }
        }
        
        result.subscribe(onNext:{[weak self] success,message,email in
            switch success{
            case .Success,.AlreadySubscribe:
                pop?.dismiss()
                if let email = email,
                   let thumUrl = self?.goodsImage{
                    self?.showSuccessAlert(email: email, thumUrl: thumUrl,success: success)
                }
            case .Failed:
                HUDManager.showHUD(withMessage: message)
                pop?.dismiss()
            }
        }).disposed(by: disposeBag)
    }
    
    func showSuccessAlert(email:String,thumUrl:String,success:SubscribeStatus){
        if success == .AlreadySubscribe{
            let arrivalSuccess = ArrivalAlready()
            arrivalSuccess.goodsName.text = baseInfo.goodsTitle
            let sizeText = baseInfo.showSizeText()
            if sizeText.isEmpty{
                arrivalSuccess.sizeLabel.isHidden = true
            }
            arrivalSuccess.sizeLabel.text = "\(STLLocalizedString_("size")!):\(sizeText)"
            arrivalSuccess.goodsImageView.yy_setImage(with: URL(string:thumUrl), placeholder: UIImage(named: "ProductImageLogo"))
            
            let pop = zhPopupController(view: arrivalSuccess, size: CGSize(width: CGFloat.screenWidth - 40, height: 303))
            pop.keyboardChangeFollowed = true
            pop.show()
            
            arrivalSuccess.closePub.subscribe(onNext:{[weak pop] in
                pop?.dismiss()
            }).disposed(by: disposeBag)
            
        }else if success == .Success{
            let arrivalSuccess = ArrivalSubScribeSuccess()
            var string = STLLocalizedString_("Arrival_Notify_Done_Text")!
            string = string.replacingOccurrences(of: "\nxxx@xx.com\n", with: " \(email) ")
            let attrStr = NSMutableAttributedString(string: string )
            attrStr.yy_font = UIFont.systemFont(ofSize: 14)
            let range = NSString(string: string).range(of: email)
            attrStr.yy_setFont(UIFont.boldSystemFont(ofSize: 14), range: range)
            
            arrivalSuccess.tipInfo.attributedText = attrStr
            arrivalSuccess.thumImage.yy_setImage(with: URL(string:thumUrl), placeholder: UIImage(named: "ProductImageLogo"))
            
            let pop = zhPopupController(view: arrivalSuccess, size: CGSize(width: CGFloat.screenWidth - 40, height: 364))
            pop.keyboardChangeFollowed = true
            pop.show()
            
            arrivalSuccess.closePub.subscribe(onNext:{[weak pop] in
                pop?.dismiss()
            }).disposed(by: disposeBag)
        }
        
    }
}
