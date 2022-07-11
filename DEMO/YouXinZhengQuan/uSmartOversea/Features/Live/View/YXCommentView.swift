//
//  YXCommentView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RSKGrowingTextView
import NSObject_Rx
import YXKit

class YXCommentView: UIView {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.register(YXCommentCell.self, forCellReuseIdentifier: "YXCommentCell")
        return tableView
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        
        view.addSubview(inputButton)
        view.addSubview(shareButton)
        view.addSubview(closeButton)
        
        inputButton.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.width.equalTo(150)
            make.height.equalTo(36)
            make.top.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(inputButton)
        }
        
        shareButton.snp.makeConstraints { (make) in
            make.right.equalTo(closeButton.snp.left).offset(-10)
            make.centerY.equalTo(inputButton)
        }
        
        return view
    }()
    
    var timeFlag: YXTimerFlag?
    
    var liveModel: YXLiveDetailModel? {
        didSet {
            if timeFlag == nil {
                timeFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (flag) in
                    self?.requestDetail()
                }, timeInterval: 3, repeatTimes: Int.max, atOnce: true)
            }
        }
    }
    
    var dataSource: [YXCommentItem] = []
    
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = self.bounds
        layer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        layer.locations = [0, 0.05, 0.1, 1]
        
        return layer
    }()
    
    lazy var inputButton: QMUIButton = {
        let button = QMUIButton()
        button.adjustsButtonWhenHighlighted = false
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 18
        button.setTitle(YXLanguageUtility.kLang(key: "live_comment"), for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.65), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left
        
        button.rx.tap.asObservable().subscribe(onNext: { [weak self] () in
            guard let strongSelf = self else { return }
            if strongSelf.inputContainerView.superview == nil {
                strongSelf.superview?.addSubview(strongSelf.inputContainerView)
                strongSelf.inputContainerView.snp.makeConstraints { (make) in
                    make.left.right.equalToSuperview()
                    make.bottom.equalToSuperview()
                }
            }
            strongSelf.inputContainerView.isHidden = false
            _ = strongSelf.inputTextView.becomeFirstResponder()
        }).disposed(by: rx.disposeBag)
        
        return button
    }()
    
    lazy var inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.isHidden = true
        
        view.addSubview(sendButton)
        view.addSubview(inputTextView)
        
        sendButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(63)
            make.height.equalToSuperview()
        }
        
        inputTextView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.right.equalTo(sendButton.snp.left)
            //make.height.greaterThanOrEqualTo(36)
        }
        
        return view
    }()
    
    lazy var inputTextView: RSKGrowingTextView = {
        let textView = RSKGrowingTextView()
        textView.attributedPlaceholder = NSAttributedString(string: YXLanguageUtility.kLang(key: "live_comment"), attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.qmui_color(withHexString: "#191919")!.withAlphaComponent(0.45)])
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        textView.layer.cornerRadius = 16.5
        textView.maximumNumberOfLines = 3
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        textView.enableMode = .disabled
        return textView
    }()
    
    lazy var sendButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "live_send"), for: .normal)
        button.setTitleColor(UIColor(hexString: "#2F79FF"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.rx.tap.asObservable().subscribe(onNext: { [weak self]() in
            self?.comment()
        }).disposed(by: rx.disposeBag)
        return button
    }()
    
    lazy var shareButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "live_share"), for: .normal)
        return button
    }()
    
    lazy var closeButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "live_close"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 275 + YXConstant.safeAreaInsetsBottomHeight()))
        
        NotificationCenter.default.addObserver(self, selector: #selector(YXCommentView.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(YXCommentView.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        addSubview(bottomView)
        addSubview(tableView)
        
        bottomView.snp.makeConstraints { (make) in
            make.height.equalTo(49)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-YXConstant.safeAreaInsetsBottomHeight())
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(210)
            make.bottom.equalTo(bottomView.snp.top).offset(-16)
        }
        
        self.layer.mask = gradientLayer
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        if let timeFlag = self.timeFlag {
//            YXTimerSingleton.shareInstance().invalidOperation(withFlag: timeFlag)
//        }        
    }
    func closeTimer() {
        if let timeFlag = self.timeFlag {
            YXTimerSingleton.shareInstance().invalidOperation(withFlag: timeFlag)
        }
    }
    
    func comment() {
        guard let content = inputTextView.text, content.count > 0 else { return }
        
        sendButton.isEnabled = false
        let hud =  YXProgressHUD.showLoading(nil)
        
        let postId = liveModel?.post_id
        
        let requestModel = YXGetUniqueIdRequestModel()
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            if let data = responseModel.data?["data"] as? [String], let uniqueId = data.first {
                let requestModel = YXCommentRequestModel()
                requestModel.content = content
                requestModel.post_id = postId
                requestModel.unique_id = uniqueId
                
                let request = YXRequest(request: requestModel)
                request.startWithBlock(success: { (responeModel) in
                    strongSelf.sendButton.isEnabled = true
                    hud.hideHud()
                    if responeModel.code != .success {
                        YXProgressHUD.showError(responseModel.msg)
                    } else {
                        strongSelf.inputTextView.text = nil
                        strongSelf.inputTextView.resignFirstResponder()
                        strongSelf.requestDetail()
                    }
                }, failure: {(_) in
                    strongSelf.sendButton.isEnabled = true
                    hud.hideHud()
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                })
            } else {
                strongSelf.sendButton.isEnabled = true
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                hud.hideHud()
            }
            
            }, failure: { [weak self] (_) in
                self?.sendButton.isEnabled = true
                hud.hideHud()
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
        })
        
    }
    
    var firstId: String?
    var latestId: String?
    
    var refreshing: Bool = false
    
    func requestOld() {
        guard let sortId = self.firstId else {
            return
        }
        
        let postId = liveModel?.post_id
        
        let sortDirect = 1
        let sortDesc = 1
        
        let requestModel = YXCommentDetailRequestModel()
        requestModel.post_id = postId
        requestModel.comment_sort_id = sortId
        requestModel.comment_sort_direct = sortDirect
        requestModel.comment_sort_desc = sortDesc
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            if responseModel.code == .success {
                if let model = responseModel as? YXCommentDetailResponseModel, let comments = model.comment_detail_info, comments.count > 0 {
                    let items = comments.reversed().map { (comment) -> YXCommentItem  in
                        let userName = comment.comment_user?.nick ?? ""
                        let content = comment.content ?? ""
                        let item = YXCommentItem()
                        var attributeString = NSMutableAttributedString(string: userName + ":", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.white.withAlphaComponent(0.65)])
                        if comment.comment_user?.user_id == strongSelf.liveModel?.anchor?.anchor_uid {
                            attributeString = NSMutableAttributedString(string: userName + ":", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.qmui_color(withHexString: "#2F79FF")!])
                        }
                        attributeString.append(NSAttributedString(string: content, attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 14)]))
                        item.attributeString = attributeString
                        item.height = attributeString.boundingRect(with: CGSize(width: strongSelf.bounds.width - 100, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height + 18
                        return item
                    }
                    
                    strongSelf.firstId = comments.last?.ID
                    strongSelf.dataSource = items + strongSelf.dataSource
                    strongSelf.tableView.reloadData()
                }
            }
            strongSelf.refreshing = false
            }, failure: { [weak self] (_) in
                self?.refreshing = false
        })
    }
    
    func requestDetail() {
        let postId = liveModel?.post_id
    
        var sortId = "0"
        var sortDirect = 1
        let sortDesc = 1
        
        if let id = latestId{
            sortId = id
            sortDirect = 0
        }
        
        let requestModel = YXCommentDetailRequestModel()
        requestModel.post_id = postId
        requestModel.comment_sort_id = sortId
        requestModel.comment_sort_direct = sortDirect
        requestModel.comment_sort_desc = sortDesc
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            if responseModel.code == .success {
                if let model = responseModel as? YXCommentDetailResponseModel, let comments = model.comment_detail_info, comments.count > 0 {
                    let items = comments.reversed().map { (comment) -> YXCommentItem  in
                        let userName = comment.comment_user?.nick ?? ""
                        let content = comment.content ?? ""
                        let item = YXCommentItem()
                        var attributeString = NSMutableAttributedString(string: userName + "：", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.white.withAlphaComponent(0.65)])
                        if comment.comment_user?.user_id == strongSelf.liveModel?.anchor?.anchor_uid {
                            attributeString = NSMutableAttributedString(string: userName + ":", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.qmui_color(withHexString: "#2F79FF")!])
                        }
                        attributeString.append(NSAttributedString(string: content, attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 14)]))
                        item.attributeString = attributeString
                        item.height = attributeString.boundingRect(with: CGSize(width: strongSelf.bounds.width - 96, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height + 18
                        return item
                    }
                    if sortId == "0" {
                        strongSelf.firstId = comments.last?.ID
                    }
                    strongSelf.latestId = comments.first?.ID
                    strongSelf.dataSource += items
                    strongSelf.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        strongSelf.tableView.scrollToBottom()
                    }
                }
            }
        }, failure: { (_) in
            
        })
    }
    
}

extension YXCommentView: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YXCommentCell", for: indexPath) as! YXCommentCell
        cell.item = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.row].height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset
        if point.y == 0, refreshing == false {
            refreshing = true
            requestOld()
        }
    }
    
}

extension YXCommentView {
    @objc func keyboardWillHide(_ sender: Notification) {
         if let userInfo = (sender as NSNotification).userInfo {
             if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                 if inputContainerView.superview != nil {
                     inputContainerView.isHidden = true
                     inputContainerView.snp.updateConstraints { (make) in
                         make.bottom.equalToSuperview()
                     }
                 }

                 UIView.animate(withDuration: 0.25, animations: { () -> Void in self.layoutIfNeeded() })
             }
         }
     }
     
     @objc func keyboardWillShow(_ sender: Notification) {
         if let userInfo = (sender as NSNotification).userInfo {
             if let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                 if self.inputContainerView.superview != nil {
                     self.inputContainerView.snp.updateConstraints { (make) in
                         make.bottom.equalToSuperview().offset(-keyboardHeight)
                     }
                 }
                 
                 UIView.animate(withDuration: 0.25, animations: { () -> Void in
                     self.layoutIfNeeded()
                 })
             }
         }
     }
}
