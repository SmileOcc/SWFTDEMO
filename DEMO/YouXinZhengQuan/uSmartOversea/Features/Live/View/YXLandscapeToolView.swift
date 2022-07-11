//
//  YXLandscapeToolView.swift
//  uSmartOversea
//
//  Created by suntao on 2021/2/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RSKGrowingTextView
import NSObject_Rx
import YXKit

class YXLandscapeToolView: UIView, UITextViewDelegate {
    
    typealias ReqDetailCommentBlock = () -> Void
    @objc var reqDetailCommentBlock: ReqDetailCommentBlock?
    
    @objc lazy var inputTextView: RSKGrowingTextView = {
        let textView = RSKGrowingTextView()
        textView.attributedPlaceholder = NSAttributedString(string: YXLanguageUtility.kLang(key: "live_comment"), attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.qmui_color(withHexString: "#191919")!.withAlphaComponent(0.45)])
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 4
        textView.maximumNumberOfLines = 3
        textView.returnKeyType = .send
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.qmui_color(withHexString: "#F8F8F8")
        addSubview(inputTextView)
        
        inputTextView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func keyboardShowBecomeEdit() {
        self.inputTextView.becomeFirstResponder()
    }
    
    @objc func keyBoardHideEndEdit() {
        self.inputTextView.resignFirstResponder()
    }
    
    @objc var liveModel: YXLiveDetailModel?
    
    func comment() {
        guard let content = inputTextView.text, content.count > 0 else { return }
        
        let hud: YXProgressHUD = YXProgressHUD.showLoading("")
        hud.offset.y = -95
        let postId = liveModel?.post_id
        
        let requestModel = YXGetUniqueIdRequestModel()
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            if let data = responseModel.data?["data"] as? [String], let uniqueId = data.first {
                let commentRequestModel = YXCommentRequestModel()
                commentRequestModel.content = content
                commentRequestModel.post_id = postId
                commentRequestModel.unique_id = uniqueId
                
                let request = YXRequest(request: commentRequestModel)
                request.startWithBlock(success: { (responseModel) in
                    //strongSelf.sendButton.isEnabled = true
                    hud.hide(animated: true)
                    if responseModel.code != .success {
                        YXProgressHUD.showError(responseModel.msg)
                    } else {
                        strongSelf.inputTextView.text = nil
                        strongSelf.inputTextView.resignFirstResponder()
                        YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "live_send_success"))
                        strongSelf.reqDetailCommentBlock?()
                        
                       
                    }
                }, failure: {(_) in
                    //strongSelf.sendButton.isEnabled = true
                    hud.hide(animated: true)
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"))
                })
            } else {
                //strongSelf.sendButton.isEnabled = true
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"))
                hud.hide(animated: true)
            }
            
            }, failure: { (_) in
                //self?.sendButton.isEnabled = true
                hud.hide(animated: true)
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"))
        })
    }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                comment()
                return false
            }
            return true
        }
}


