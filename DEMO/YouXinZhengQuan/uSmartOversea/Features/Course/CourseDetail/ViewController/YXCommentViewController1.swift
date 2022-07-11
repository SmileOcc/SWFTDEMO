//
//  YXCommentViewController.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/19.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YXCommentViewController1: YXHKViewController, UITableViewDelegate, UITableViewDataSource {
    
    let viewModel = YXCommentViewModel1()
    
    var deleteComment = PublishSubject<String>.init()
    var reloadComment = PublishSubject<()>.init()
    
    var dataSource = [YXCourseCommentItem]()
    
    var getDataCompleteBlock: ( (_ commentCount: Int) -> Void)?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.register(YXCourseCommentCell.self, forCellReuseIdentifier: NSStringFromClass(YXCourseCommentCell.self))
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: YXConstant.safeAreaInsetsBottomHeight()+60, right: 0)
        tableView.mj_footer = refreshFooter
        
        return tableView
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter = {
        let footer = YXRefreshAutoNormalFooter.init()
        footer.setStateTextColor(QMUITheme().textColorLevel3())
        footer.activityIndicatorViewStyle = .gray;
        return footer
    }()
    
    lazy var commentTextView: YXCommentTextView1 = {
        let view = YXCommentTextView1()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = true
        self.view.backgroundColor = QMUITheme().foregroundColor()

        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
            //make.bottom.equalTo(commentInputView.snp.top)
        }
        
        let sendTap = commentTextView.sendButton.rx.tap.filter { [weak self]_ in
            guard let `self` = self, let window = UIApplication.shared.keyWindow else { return false }
            if let text = self.commentTextView.textView.text, text.count > 0 {
                if text.count > self.commentTextView.maxTextCount {
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "nbb_beyondmaxlimit"), in: window)
                    return false
                }
            }
            return true
        }.asSignal(onErrorJustReturn: ())
        
        commentTextView.cancelButton.rx.tap.subscribe { [weak self] _ in
            self?.commentTextView.textView.resignFirstResponder()
            self?.commentTextView.textView.text = nil
        }.disposed(by: disposeBag)
        
        viewModel.setInput(input: (viewWillAppear: self.rx.methodInvoked(#selector(viewWillAppear(_:))),
                                   textViewInput: commentTextView.textView.rx.text.orEmpty.asDriver(),
                                   publishComment: sendTap,
                                   deleteComment: deleteComment.asDriver(onErrorJustReturn: ""),
                                   loadMore: refreshFooter.rx.refreshing.asDriver(),
                                   reloadComment: reloadComment.asDriver(onErrorJustReturn: ())))
        
        bindViewModel()

    }
    
    func bindViewModel() {
        // 评论列表
        viewModel.refreshCommentList.drive {[weak self] res in
            guard let `self` = self else { return }

            if res?.code == .success{
                self.dataSource = res?.items ?? []
                self.tableView.reloadData()
                self.getDataCompleteBlock?(res?.total ?? 0)
                self.refreshFooter.resetNoMoreData()
                if self.dataSource.count == 0{
                    self.showNoDataEmptyView()
                    self.emptyView?.setTextLabelText(YXDefaultEmptyEnums.noCommnet.tip())
                }else {
                    self.hideEmptyView()
                }
            }else {
                self.showErrorEmptyView()
            }
//            self.view.isUserInteractionEnabled = true
//            self.view.bringSubviewToFront(self.commentInputView)

        }.disposed(by: disposeBag)
        
        // 发送评论按钮
        viewModel.sendButtonEnable.drive(commentTextView.sendButton.rx.isEnabled).disposed(by: disposeBag)

        // 发表评论
        viewModel.publishComment.drive { [weak self]success in
            if success {
                self?.commentTextView.textView.resignFirstResponder()
                self?.commentTextView.textView.text = nil
            }else {
                if let window = UIApplication.shared.keyWindow {
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "network_timeout"), in: window)
                }
            }

        }.disposed(by: disposeBag)

        // 删除评论
        viewModel.deleteComment.drive { success in
            if success {
                if let window = UIApplication.shared.keyWindow {
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "mine_del_success"), in: window)
                }
            }
        }.disposed(by: disposeBag)
        
        // 加载更多
        viewModel.loadMoreCommentList.drive {[weak self] list in
            guard let `self` = self else { return }
            if list.count != self.dataSource.count {
                self.refreshFooter.endRefreshing()
            }else {
                self.refreshFooter.endRefreshingWithNoMoreData()
            }
            self.dataSource = list
            self.tableView.reloadData()
            
        }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func benginInput() {

        YXToolUtility.handleBusinessWithLogin {
            if let window = self.view.window {
                window.addSubview(self.commentTextView)
                self.commentTextView.snp.makeConstraints { make in
                    make.left.right.top.bottom.equalToSuperview()
                }
                self.commentTextView.textView.placeholder = YXLanguageUtility.kLang(key: "nbb_saysomething")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                    self?.commentTextView.textView.becomeFirstResponder()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXCourseCommentCell.self), for: indexPath) as! YXCourseCommentCell
        let item = dataSource[indexPath.row]
        cell.model = item
        cell.delecClick = { [weak self]  in
            guard let `self` = self else { return }
            guard let uid = item.uid, let commentId = item.commentId else { return }
            if uid == String(YXUserManager.userUUID()) {
                self.deleteComment.onNext(commentId)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = dataSource[indexPath.row]
        if let discuss = item.discuss {
            let h = YXToolUtility.getStringSize(with: discuss, andFont: .systemFont(ofSize: 14), andlimitWidth: (Float(tableView.width)-72.0), andLineSpace: 3.5).height
            
            return h + 82
        }
        
        return 82
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let item = dataSource[indexPath.row]
        
    }
    
    override func emptyRefreshButtonAction() {
        self.reloadComment.onNext(())
    }
}



class YXCommentTextView1: UIView {
    
    var sendAction: ((_ content: String) -> Void)?
    
    var textViewHeight: CGFloat = 200
    let maxTextCount = 200
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    lazy var textView: QMUITextView = {
        let view = QMUITextView.init()

        view.textColor = QMUITheme().textColorLevel4()
        view.font = .systemFont(ofSize: 14)
        view.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.layer.masksToBounds = true
        view.placeholder = YXLanguageUtility.kLang(key: "nbb_saysomething")
        view.keyboardType = .default
        view.backgroundColor = .clear
        view.maximumHeight = 80
        view.maximumTextLength = UInt(maxTextCount)
        view.delegate = self
        view.showsVerticalScrollIndicator = false
        
        view.qmui_keyboardWillChangeFrameNotificationBlock = { [weak self](keyboardUserInfo) in
            guard let `self` = self else { return }
            QMUIKeyboardManager.handleKeyboardNotification(with: keyboardUserInfo, show: { (info) in
                if let keyBorardInfo = info {
                    self.showWithKeyBoardUserInfo(info: keyBorardInfo)
                }
            }) { (info) in
                if let keyBorardInfo = info {
                    self.hideWithKeyBoardUserInfo(info: keyBorardInfo)
                }
            }
        }
        
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        return button
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "publish"), for: .normal)
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    
    lazy var beyondLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
//        label.isHidden = true
        return label
    }()
    
    func showWithKeyBoardUserInfo(info: QMUIKeyboardUserInfo) {
        self.isHidden = false
        sendButton.isEnabled = textView.text.count > 0
        QMUIKeyboardManager.animateWith(animated: true, keyboardUserInfo: info, animations: {[weak self] in
            guard let `self` = self else { return }
            if let view = self.superview {
                let distanceFromBottom = QMUIKeyboardManager.distanceFromMinYToBottom(in: view, keyboardRect: info.endFrame)
                self.containerView.layer.transform = CATransform3DMakeTranslation(0, (-distanceFromBottom - self.containerView.frame.size.height), 0)
            }
        }, completion: {_ in
            
        })
    }
    
    func hideWithKeyBoardUserInfo(info: QMUIKeyboardUserInfo) {
        self.isHidden = true
        QMUIKeyboardManager.animateWith(animated: true, keyboardUserInfo: info, animations: {[weak self] in
            self?.containerView.layer.transform = CATransform3DIdentity
        }, completion: {[weak self] (finish) in
            self?.removeFromSuperview()
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isHidden = true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        let line = UIView()
        line.backgroundColor = QMUITheme().popSeparatorLineColor()
        
        containerView.addSubview(line)
        containerView.addSubview(textView)
        containerView.addSubview(sendButton)
        containerView.addSubview(cancelButton)
        containerView.addSubview(beyondLabel)
        
        addSubview(containerView)
        
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(cancelButton.snp.bottom).offset(8)
            make.height.equalTo(0.5)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(160)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
           // make.bottom.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
        }
        
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
           // make.bottom.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
        }
        
        beyondLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
            make.height.equalTo(200)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YXCommentTextView1: QMUITextViewDelegate {
//    func textView(_ textView: QMUITextView!, newHeightAfterTextChanged height: CGFloat) {
//
//        if height < 40, textViewHeight == 40 {
//            return
//        }
//        var h = height
//        if height < 40 {
//            h = 40
//        }
//
//        textView.snp.updateConstraints { make in
//            make.height.equalTo(h)
//        }
//
//        let change = h - textViewHeight
//
//        self.containerView.layer.transform = CATransform3DTranslate(self.containerView.layer.transform, 0, -change, 0)
//        textViewHeight = h
//    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.count > 0 {
            sendButton.isEnabled = true
            textView.textColor = QMUITheme().textColorLevel1()
        }else {
            sendButton.isEnabled = false
            textView.textColor = QMUITheme().textColorLevel4()
        }
        
        beyondLabel.text = "\(textView.text.count)/\(maxTextCount)"
    }
}
