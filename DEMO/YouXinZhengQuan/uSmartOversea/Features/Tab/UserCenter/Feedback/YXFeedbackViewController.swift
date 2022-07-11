//
//  YXFeedbackViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
//意见反馈
import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit
import QCloudCOSXML
import TYAlertController

class YXFeedbackViewController: YXHKViewController, HUDViewModelBased, UITextViewDelegate, YXAreaCodeBtnProtocol {
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXFeedbackViewModel!
    
    var logPut: QCloudCOSXMLUploadObjectRequest<AnyObject>?
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.contentSize = CGSize(width: YXConstant.screenWidth, height: 680)
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    //地区手机码
    lazy var areaBtn: UIButton = self.buildAreaBtn()
    
    var textView: UITextView = {
        let textView = UITextView()
        textView.textColor = QMUITheme().textColorLevel1()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        
        return textView
    }()
    
    var countLabel: QMUILabel = {
        let countLabel = QMUILabel()
        countLabel.textColor = QMUITheme().textColorLevel4()
        countLabel.font = .systemFont(ofSize: 12)
        countLabel.text = "0/500"
        return countLabel
    }()
    
    var placeHolderLabel: QMUILabel = {
        let label  = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel4()
        label.numberOfLines = 0
        label.text = "Please describe your suggestion in detail,it would be more helpful if you can upload related screenshots."
        return label
    }()
    
    
    var phoneInputView: YXInputView = {
        let inputView = YXInputView(placeHolder: YXLanguageUtility.kLang(key: "mine_feedback_phone"), type: .email,showClear: false)
        inputView.textField.font = .systemFont(ofSize: 14)
        inputView.textField.textAlignment = .right
        inputView.textField.textColor = QMUITheme().textColorLevel1()
        if YXUserManager.isLogin() {
            inputView.setSecretPhone()
        }
        return inputView
    }()
    
    var pictureView: YXReturnbackPictureView = {
        let v = YXReturnbackPictureView()
        return v
    }()
    
    var submitBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "mine_submit"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().mainThemeColor()), for: .normal)

        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        return btn
    }()
    
    override var pageName: String {
           return "App Center"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = QMUITheme().blockColor()
        title = "App FeedBack"

        initUI()
        bindViewModel()
        bindHUD()
    }
   
    func initUI() {
        
        textView.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(submitBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        let tipLab = QMUILabel()
        tipLab.text = "Leave your feedback"
        tipLab.font = .systemFont(ofSize: 14)
        tipLab.textColor = QMUITheme().textColorLevel1()
        tipLab.numberOfLines = 0
        tipLab.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tipLab.backgroundColor = QMUITheme().blockColor()
        scrollView.addSubview(tipLab)
        tipLab.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(42)
        }
        
        let textBackView = UIView()
        textBackView.backgroundColor = QMUITheme().foregroundColor()
        scrollView.addSubview(textBackView)
        textBackView.addSubview(textView)
        textBackView.addSubview(placeHolderLabel)
        textBackView.addSubview(countLabel)
        
        textBackView.snp.makeConstraints { make in
            make.top.equalTo(tipLab.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(120)
            make.width.equalTo(view)
        }
        
        textView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalTo(countLabel.snp.top).offset(-5)
        }
    
        placeHolderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(textView).offset(6)
            make.top.equalTo(textView).offset(3)
            make.right.equalTo(textView).offset(-6)
            
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        
        let contactBackView = UIView()
        contactBackView.backgroundColor = QMUITheme().foregroundColor()
        
        scrollView.addSubview(contactBackView)
        contactBackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(48)
            make.top.equalTo(textBackView.snp.bottom).offset(8)
        }
        
        let email = QMUILabel()
        email.text = "Contact Email"
        email.font = .systemFont(ofSize: 14)
        email.textColor = QMUITheme().textColorLevel1()
        
        contactBackView.addSubview(email)
        contactBackView.addSubview(phoneInputView)
        
        email.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        phoneInputView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
        let pitcureBackView = UIView()
        pitcureBackView.backgroundColor = QMUITheme().foregroundColor()
        
        scrollView.addSubview(pitcureBackView)
        pitcureBackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(220)
            make.top.equalTo(contactBackView.snp.bottom).offset(8)
        }
        
        let pictureLab = QMUILabel()
        pictureLab.font = .systemFont(ofSize: 14)
        pictureLab.textColor = QMUITheme().textColorLevel1()
        pictureLab.text = "Picture(Optional,Max 5 images)"
        
        pitcureBackView.addSubview(pictureLab)
        pictureLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
        }
        
        pitcureBackView.addSubview(pictureView)
        pictureView.snp.makeConstraints { (make) in
            make.top.equalTo(pictureLab.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
        
        let noticeLabel = UILabel()
        noticeLabel.font = .systemFont(ofSize: 12)
        noticeLabel.textColor = QMUITheme().textColorLevel4()
        noticeLabel.numberOfLines = 0
        noticeLabel.text = YXLanguageUtility.kLang(key: "feedback_notice") 
        
        scrollView.addSubview(noticeLabel)
        
        noticeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(pitcureBackView.snp.bottom).offset(12)
        }
        
        submitBtn.snp.makeConstraints { (make) in
            make.top.equalTo(pitcureBackView.snp.bottom).offset(96)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }
        
        if YXUserManager.isLogin() {
            phoneInputView.textField.text = YXUserManager.secretEmail()
            viewModel.code = YXUserManager.shared().curLoginUser?.areaCode ?? YXUserManager.shared().defCode
            areaBtn.setTitle(String(format: "+%@", viewModel.code), for: .normal)
        }
        
        setImageEdgeInsets()
    }
    
    func bindViewModel() {
        areaBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.showAreaAlert()
        }).disposed(by: disposeBag)
        
        
        textView.rx.text.orEmpty
            .asDriver()
            .map{$0.count > 0}
            .drive(placeHolderLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty
            .asDriver()
            .map{$0.count > 0}
            .drive(submitBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty.asObservable()
            .subscribe(onNext: {[weak self] (text) in
                guard let strongSelf = self else { return }
                strongSelf.countLabel.text = String(format: "%ld/%ld", text.count, strongSelf.viewModel.MaxCount)
                if text.count >= strongSelf.viewModel.MaxCount {
                    strongSelf.countLabel.textColor = UIColor.red
                }else {
                    strongSelf.countLabel.textColor = QMUITheme().textColorLevel4()
                }
            }).disposed(by: disposeBag)
       
        submitBtn.rx.tap.subscribe(onNext: {[weak self] _ in
           
            guard let strongSelf = self else { return }
            strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
            
            let fileName = "feedback/*"
            var region = YXQCloudService.keyQCloudGuangZhou
            if YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
                region = YXQCloudService.keyQCloudSingapore
            } else {
                region = YXQCloudService.keyQCloudGuangZhou
            }
            let bucket = YXUrlRouterConstant.suggestionBucket()
            YXUserManager.updateToken(fileName: fileName, region: region, bucket: bucket) {
                if strongSelf.pictureView.imgLocationUrlArr.count > 0 {
                    strongSelf.viewModel.uploadPicSubject.onNext(true)
                } else {
                    strongSelf.suggestionSubmit()
                }
            } failed: { msg in
                self?.viewModel.imageUrlArr.removeAll()
                self?.viewModel.hudSubject.onNext(.error(msg, false))
            }
        }).disposed(by: disposeBag)
        
        viewModel.uploadPicSubject.subscribe(onNext: {[weak self] (_) in
            
            self?.uploadImageRequest()
            
        }).disposed(by: disposeBag)
        
        viewModel.successSubject.subscribe(onNext: {[weak self] (_) in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        textView.rx.text.orEmpty.subscribe(onNext: {[weak self] (text) in
            guard let strongSelf = self else { return }
            if text.count > strongSelf.viewModel.MaxCount {
                let str = text.prefix(500)
                strongSelf.textView.text = "\(str)"
            }
        }).disposed(by: disposeBag)
        
    }
    //上传图像请求
    func uploadImageRequest() {

        self.viewModel.hudSubject.onNext(.loading(YXLanguageUtility.kLang(key: ""), false))
        let group = DispatchGroup()
        for i in 0..<pictureView.imgLocationUrlArr.count {
            group.enter()
            let url = URL(fileURLWithPath: self.pictureView.imgLocationUrlArr?[i] as! String)
            let put = QCloudCOSXMLUploadObjectRequest<AnyObject>()
            let obj = String(format: "feedback/iOS_feedback_%llu_%ld_%ld.jpg", YXUserManager.userUUID(), Int(Date().timeIntervalSince1970 * 1000), i)
            put.object = obj
            put.bucket = YXUrlRouterConstant.suggestionBucket()//"user-server-1257884527"//"user-feedback-test-1257884527"
            put.body = url as AnyObject
            put.customHeaders.setObject("www.yxzq.com", forKey: "Referer" as NSCopying)
            
            put.sendProcessBlock = { bytesSent, totalBytesSent, totalBytesExpectedToSend in
                print("upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend)
            }
            

            put.finishBlock = {[weak self] outputObject, error in
                if error != nil {
                    
                    self?.viewModel.isUploadSuccess = false
                    
                } else {
                    if let outputObject = outputObject as? QCloudUploadObjectResult {
                        
                        self?.viewModel.imageUrlArr.append(outputObject.location)
                    }
                    
                }
                group.leave()
                
            }
            
            if YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
                QCloudCOSTransferMangerService.costransfermangerService(forKey: YXQCloudService.keyQCloudSingapore).uploadObject(put)
            } else {
                QCloudCOSTransferMangerService.costransfermangerService(forKey: YXQCloudService.keyQCloudGuangZhou).uploadObject(put)
            }
            
            //存储在数组中
            viewModel.putRequestsArr.append(put)
        }

        group.notify(queue: .main){ [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.hudSubject.onNext(.hide)
            if strongSelf.viewModel.isUploadSuccess {
                //开始提交
                strongSelf.suggestionSubmit()
            } else {
                strongSelf.viewModel.imageUrlArr.removeAll()
                strongSelf.viewModel.isUploadSuccess = true

                strongSelf.viewModel.hudSubject.onNext(.hide)
                strongSelf.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "mine_upload_failure"), false))
            }
        }
    }

    func postFileLog() {
        DispatchQueue.global().async { [weak self] in
            if let path = YXRealLogger.shareInstance.logZipFilePath() {
                let url = URL(fileURLWithPath: path)
                self?.logPut = QCloudCOSXMLUploadObjectRequest<AnyObject>()
                self?.logPut?.object = url.lastPathComponent
                self?.logPut?.bucket = "hq-prod-applog-1257884527"
                self?.logPut?.body = url as AnyObject
                self?.logPut?.customHeaders.setObject("www.yxzq.com", forKey: "Referer" as NSCopying)
                
                self?.logPut?.sendProcessBlock = { bytesSent, totalBytesSent, totalBytesExpectedToSend in
                    print("upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend)
                }
                
                
                self?.logPut?.finishBlock = { outputObject, error in
                    if error != nil {
                    } else {
                        if let outputObject = outputObject as? QCloudUploadObjectResult {
                            YXRealLogger.shareInstance.postPathLog(path: outputObject.location, zipPath: path)
                            
                        }
                    }
                }
                QCloudCOSTransferMangerService.costransfermangerService(forKey: YXQCloudService.keyQCloudShenZhenFsi)?.uploadObject((self?.logPut)!)
            }
        }
    }
    
    func suggestionSubmit() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        postFileLog()
        if viewModel.imageUrlArr.count > 5 {
            var imageUrlArr = [String]()
            imageUrlArr.append(contentsOf: viewModel.imageUrlArr[0...4])
            viewModel.imageUrlArr = imageUrlArr
        }
        var email:String = phoneInputView.textField.text ?? ""
        let phone = ""
        if phoneInputView.isClear == false {
            email = (YXUserManager.shared().curLoginUser?.email ?? "").removePreAfterSpace()
             viewModel.services.userService.request(.feedback(textView.text, viewModel.code, phone, email, viewModel.imageUrlArr), response: viewModel.feedbackResponse).disposed(by: disposeBag)

        }else {
            email = (phoneInputView.textField.text ?? "").removePreAfterSpace()
            viewModel.services.userService.request(.feedback(textView.text, viewModel.code, phone, email, viewModel.imageUrlArr), response: viewModel.feedbackResponse).disposed(by: disposeBag)
        }
    }
    
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "") {
            return true
        }
        if range.location >= viewModel.MaxCount {
            return false
        } else {
            return true
        }
        
    }
}
extension YXFeedbackViewController {
    func showAreaAlert() {
        let hotAreaCount = YXGlobalConfigManager.shareInstance.countryAreaModel?.commonCountry?.count ?? 0
        let viewHeight: CGFloat = CGFloat(hotAreaCount + 1) * 48.0
        let bgView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: YXConstant.screenWidth, height: viewHeight + 34.0 ))
        
        let areaCodeView = YXAreaCodeAlertView(frame: CGRect(x: 20, y: 0, width: YXConstant.screenWidth - 40, height: viewHeight), selectCode: self.viewModel.code)
        bgView.addSubview(areaCodeView)
        
        let alertVc = TYAlertController(alert: bgView, preferredStyle: .actionSheet, transitionAnimation: .scaleFade)
        alertVc!.backgoundTapDismissEnable = true
        areaCodeView.didSelected = { [weak alertVc, weak self, weak bgView] code in
            guard let `self` = self else { return }
            if code.count > 0 {
                self.phoneInputView.textField.becomeFirstResponder()
                self.viewModel.code = code
                self.areaBtn.setTitle(String(format: "+%@", code), for: .normal)
                self.setImageEdgeInsets()
                alertVc?.dismissViewController(animated: true)
            } else {
                
                alertVc?.dismissComplete = {[weak self] in
                    self?.showMoreAreaAlert()
                }
                bgView?.hide()
            }
            
        }
        
        self.present(alertVc!, animated: true, completion: nil)
        
    }
    
    
    private func showMoreAreaAlert() {
        let areaCodeModel = YXAreaCodeViewModel()
        areaCodeModel.didSelectSubject.subscribe(onNext: { [weak self] (code) in
            guard let `self` = self else {return}
            self.phoneInputView.textField.becomeFirstResponder()
            self.viewModel.code = code
            self.areaBtn.setTitle(String(format: "+%@", code), for: .normal)
            self.setImageEdgeInsets()
                        
        }).disposed(by: self.disposeBag)
        
        let context = YXNavigatable(viewModel: areaCodeModel)
        self.viewModel.navigator.push(YXModulePaths.areaCodeSelection.url, context: context)
    }
}
