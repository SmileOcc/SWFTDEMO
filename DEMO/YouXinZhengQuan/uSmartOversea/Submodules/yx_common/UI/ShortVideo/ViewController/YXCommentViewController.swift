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
import MMKV
import QMUIKit

class YXShortVideoCommentViewController: YXHKViewController, UITableViewDelegate, UITableViewDataSource {
    
    ///评论举报列表
    var complainList: [String] {
        get {
            return MMKV.default().string(forKey: "YX_COMPLAIN_COMMENT", defaultValue: "")!.components(separatedBy: ",")
        }
        set {
            MMKV.default().set(newValue.joined(separator: ","), forKey: "YX_COMPLAIN_COMMENT")
        }
    }
    
    let viewModel = YXShortVideoCommentViewModel()
    
    var deleteComment = PublishSubject<(String,IndexPath)>.init()
    
    var likeComment = PublishSubject<(String,YXShortVideoLikeAction)>.init()
    
    var dataSource = [YXShortVideoCommentItem]()
    
    var getDataCompleteBlock: ( (_ commentCount: Int) -> Void)?
    
    var shouldLoginCallBack: (() -> Void)?
    
    ///是否支持回复
    var canReply = false
        
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        tableView.register(YXShortVideoCommentCell.self, forCellReuseIdentifier: NSStringFromClass(YXShortVideoCommentCell.self))
        tableView.register(YXShortVideoReplyCell.self, forCellReuseIdentifier: NSStringFromClass(YXShortVideoReplyCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 60
        tableView.mj_footer = refreshFooter
        tableView.sectionHeaderHeight = 0
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height:0.01))
        return tableView
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter = {
        let footer = YXRefreshAutoNormalFooter.init()
        footer.setStateTextColor(UIColor(hexString:"#999999")!)
        footer.activityIndicatorViewStyle = .gray;
        return footer
    }()
    
    lazy var commentInputView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        let imageView = UIImageView(image: UIImage(named: "comment_write"))
        let imageView2 = UIImageView(image: UIImage(named: "comment_send"))
        
        let tap = UITapGestureRecognizer.init { [weak self]_ in
            guard let `self` = self else { return }
            self.benginInput(indexPath: nil,
                             replyId: nil,
                             replyName: nil)
        }
        
        view.addGestureRecognizer(tap)
        
        let label = UILabel()
        label.font = .normalFont14()
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "live_comment")
        
        let grayBackView = UIView()
        grayBackView.backgroundColor = UIColor.qmui_color(withHexString: "#F0F0F0")
        grayBackView.layer.cornerRadius = 20
        grayBackView.layer.masksToBounds = true
        
        let line = UIView()
        line.backgroundColor = UIColor.qmui_color(withHexString: "#F0F0F0")
        
        view.addSubview(grayBackView)
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(line)
        view.addSubview(imageView2)
        
        grayBackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.left.equalTo(grayBackView).offset(16)
            make.centerY.equalTo(grayBackView)
            
        }
        
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(8)
            make.centerY.equalTo(grayBackView)
        }
        
        line.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        imageView2.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-32)
            make.centerY.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var commentTextView: YXCommentTextView = {
        let view = YXCommentTextView()
        return view
    }()
    
    var currentSelectedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(commentInputView)
        
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(commentInputView.snp.top)
        }
        
        commentInputView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-YXConstant.safeAreaInsetsBottomHeight())
        }
        
        let sendTap = commentTextView.sendButton.rx.tap.map { [weak self] () -> String? in
            if let index = self?.currentSelectedIndex {
                if index.row == 0 {
                    return self?.dataSource[index.section].commentId
                } else {
                    return self?.dataSource[index.section].childrenNodeList[index.row-1].commentId
                }
            }
            return nil
        }.filter { [weak self] _ in
            guard let `self` = self, let window = UIApplication.shared.keyWindow else { return false }
            if let text = self.commentTextView.textView.text, text.count > 0 {
                if text.count > self.commentTextView.maxTextCount {
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "nbb_beyondmaxlimit"), in: window)
                    return false
                }
            }
            self.commentTextView.sendButton.isUserInteractionEnabled = false
            return true
        }.asSignal(onErrorJustReturn: nil)
        
        viewModel.setInput(input: (viewWillAppear: self.rx.methodInvoked(#selector(viewWillAppear(_:))),
                                   textViewInput: commentTextView.textView.rx.text.orEmpty.asDriver(),
                                   publishComment: sendTap,
                                   deleteComment: deleteComment.asDriver(onErrorJustReturn: ("",IndexPath(row: 0, section: 0))),
                                   likeComment: likeComment.asDriver(onErrorJustReturn: ("",.unLike)),
                                   loadMore: refreshFooter.rx.refreshing.asDriver()))
        
        bindViewModel()
        
    }
    
    func bindViewModel() {
        // 评论列表
        viewModel.refreshCommentList.drive { [weak self] res in
            self?.dataSource = res?.items.filter({ [weak self] item in
                if let id = item.commentId {
                    return !(self?.complainList.contains(id) ?? false)
                }
                return true
            }) ?? []
            self?.tableView.reloadData()
            self?.configEmptyView()
            self?.getDataCompleteBlock?(res?.total ?? 0)
            self?.refreshFooter.resetNoMoreData()
        }.disposed(by: disposeBag)
        
        // 发送评论按钮
        viewModel.sendButtonEnable.drive(commentTextView.sendButton.rx.isEnabled).disposed(by: disposeBag)
        
        // 发表评论
        viewModel.publishComment.drive { [weak self] res in
            self?.commentTextView.sendButton.isUserInteractionEnabled = true
            if res != nil {
                if res?.code == YXResponseStatusCode.success {
                    let model = YXShortVideoCommentItem.yy_model(withJSON: res?.data ?? [:])
                    self?.insertComment(model: model!)
                } else {
                    if let msg = res?.msg {
                        YXProgressHUD.showMessage(msg)
                    }
                }
                self?.commentTextView.textView.resignFirstResponder()
                self?.commentTextView.textView.text = nil
                
            }else {
                if let window = UIApplication.shared.keyWindow {
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"))
                }
            }
        }.disposed(by: disposeBag)
        
        // 删除评论
        viewModel.deleteComment.drive { [weak self] index in
            if let index = index {
                YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "mine_del_success"))
                self?.deleteComment(indexPath: index)
            } else {
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"))
            }
        }.disposed(by: disposeBag)
        
        viewModel.likeComment.drive { success in
            if !success {
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"))
            }
        }.disposed(by: disposeBag)
        
        // 加载更多
        viewModel.loadMoreCommentList.drive { [weak self] list in
            guard let `self` = self else { return }
            if list.count == 20 {
                self.refreshFooter.endRefreshing()
            } else {
                self.refreshFooter.endRefreshingWithNoMoreData()
            }
            self.dataSource = self.dataSource + list.filter({ [weak self] item in
                if let id = item.commentId {
                    return !(self?.complainList.contains(id) ?? false)
                }
                return true
            })
            self.tableView.reloadData()
            
        }.disposed(by: disposeBag)
    }
    
    func insertComment(model: YXShortVideoCommentItem) {
        if let index = currentSelectedIndex {
            let item = dataSource[index.section]
            if item.childrenNodeList.count >= 3 {
                dataSource[index.section].childrenNodeList.insert(model, at: item.displayReplyCount)
                dataSource[index.section].displayReplyCount += 1
            } else {
                dataSource[index.section].childrenNodeList.append(model)
            }
            self.tableView.reloadData()
            
        } else {
            dataSource.insert(model, at: 0)
            self.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        self.configEmptyView()
        self.getDataCompleteBlock?(dataSource.count)
    }
    
    func deleteComment(indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.dataSource.remove(at: indexPath.section)
        } else {
            self.dataSource[indexPath.section].childrenNodeList.remove(at: indexPath.row-1)
        }
        self.tableView.reloadData()
        self.configEmptyView()
        self.getDataCompleteBlock?(dataSource.count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func benginInput(indexPath: IndexPath?, replyId: String?, replyName: String?) {
        self.currentSelectedIndex = indexPath
        if !YXUserManager.isLogin() {
            self.shouldLoginCallBack?()
            return
        }
        YXToolUtility.handleBusinessWithLogin {
            if let window = self.view.window {
                window.addSubview(self.commentTextView)
                self.commentTextView.snp.makeConstraints { make in
                    make.left.right.top.bottom.equalToSuperview()
                }
                if let replyName = replyName {
                    self.commentTextView.textView.placeholder = YXLanguageUtility.kLang(key: "reply") + " \(replyName)"
                } else {
                    self.commentTextView.textView.placeholder = YXLanguageUtility.kLang(key: "live_comment")
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                    self?.commentTextView.textView.becomeFirstResponder()
                }
            }
        }
    }
    
    func longPressAction(item: YXShortVideoCommentItem?, indexPath: IndexPath) {
        guard let item = item else { return }
        guard let uid = item.uid, let commentId = item.commentId else { return }
        
        let reply = QMUIAlertAction.init(title: YXLanguageUtility.kLang(key: "reply"), style: .default) { [weak self]vc, action in
            guard let `self` = self else { return }
            self.benginInput(indexPath: indexPath, replyId: commentId, replyName: item.nick)
        }
        
        reply.buttonAttributes = [.font: UIFont.normalFont16(), .foregroundColor: UIColor(hexString:"#333333")]
        
        let complain = QMUIAlertAction.init(title: YXLanguageUtility.kLang(key: "report_comment"), style: .default) { [weak self] vc, action in
            self?.handleComplain(indexPath: indexPath,
                                 commentId: commentId)
        }
        
        complain.buttonAttributes = [.font: UIFont.normalFont16(), .foregroundColor: UIColor(hexString:"#333333")]
        
        let delete = QMUIAlertAction.init(title: YXLanguageUtility.kLang(key: "common_delete"), style: .default) { [weak self]vc, action in
            guard let `self` = self else { return }
            self.deleteComment.onNext((commentId,indexPath))
        }
        
        delete.buttonAttributes = [.font: UIFont.normalFont16(), .foregroundColor: UIColor.qmui_color(withHexString: "#F95151")!]
        
        let cancel = QMUIAlertAction.init(title:YXLanguageUtility.kLang(key: "common_cancel"), style: .default) { vc, action in
            
        }
        
        cancel.buttonAttributes = [.font: UIFont.normalFont16(), .foregroundColor: UIColor(hexString:"#333333")]
        
        let vc = QMUIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.sheetCancelButtonMarginTop = 0
        vc.sheetContentCornerRadius = 8
        vc.sheetContentMargin = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        vc.addAction(reply)
        if item.delFlag == true {
            vc.addAction(delete)
        }
        vc.addAction(complain)
        vc.addAction(cancel)
        vc.showWith(animated: true)
    }
    
    func handleComplain(indexPath:IndexPath, commentId: String) {
        if indexPath.row == 0 {
            self.dataSource.remove(at: indexPath.section)
            self.getDataCompleteBlock?(self.dataSource.count)

            if !self.complainList.contains(commentId) {
                self.complainList.append(commentId)
            }
        } else {
            self.dataSource[indexPath.section].childrenNodeList.remove(at: indexPath.row-1)
        }
        
        self.tableView.reloadData()
//        YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "report_success"))
    }
    
    func configEmptyView() {
        if self.dataSource.count == 0 {
            self.showEmptyView(with: UIImage(named: "empty2"),
                               text: YXLanguageUtility.kLang(key: "no_comment"),
                               detailText: nil,
                               buttonTitle: nil,
                               buttonAction: nil)
            self.view.bringSubviewToFront(self.commentInputView)
        } else {
            self.hideEmptyView()
        }
    }
}

extension YXShortVideoCommentViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].displayChildrenNodeList.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXShortVideoCommentCell.self), for: indexPath) as! YXShortVideoCommentCell
            let item = dataSource[indexPath.section]
            cell.authorId = viewModel.authorId
            cell.model = item
            cell.isLive = self.viewModel.businessType == .live
            let action = cell.likeButton.isSelected ? YXShortVideoLikeAction.unLike : YXShortVideoLikeAction.like
            let id = item.commentId ?? ""
            cell.likeButton.qmui_tapBlock = { [weak self, weak cell] _ in
                cell?.isLike = action == .like
                if (!YXUserManager.isLogin()) {
                    self?.shouldLoginCallBack?()
                    return
                }
                self?.likeComment.onNext((id,action))
            }
            cell.longPressCallback = { [weak self] item in
                self?.longPressAction(item: item, indexPath: indexPath)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXShortVideoReplyCell.self), for: indexPath) as! YXShortVideoReplyCell
            let item = dataSource[indexPath.section].childrenNodeList[indexPath.row-1]
            cell.authorId = viewModel.authorId
            cell.model = item
            cell.isLive = self.viewModel.businessType == .live
            let action = cell.likeButton.isSelected ? YXShortVideoLikeAction.unLike : YXShortVideoLikeAction.like
            let id = item.commentId ?? ""
            cell.likeButton.qmui_tapBlock = { [weak self, weak cell] _ in
                cell?.isLike = action == .like
                if (!YXUserManager.isLogin()) {
                    self?.shouldLoginCallBack?()
                    return
                }
                self?.likeComment.onNext((id,action))
            }
            cell.longPressCallback = { [weak self] item in
                self?.longPressAction(item: item, indexPath: indexPath)
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            let item = dataSource[indexPath.section]
            if let discuss = item.discuss {
                let h = YXToolUtility.getStringSize(with: discuss, andFont: .normalFont14(), andlimitWidth: (Float(tableView.width)-72.0), andLineSpace: 3.5).height
                return h + 67
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = dataSource[indexPath.section]
        if indexPath.row == 0 {
            if let commentId = item.commentId {
                self.benginInput(indexPath: indexPath,
                                 replyId: commentId,
                                 replyName: item.nick)
            }
        } else {
            if let commentId = item.displayChildrenNodeList[indexPath.row-1].commentId{
                let nickName = item.displayChildrenNodeList[indexPath.row-1].nick
                self.benginInput(indexPath: indexPath,
                                 replyId: commentId,
                                 replyName: nickName)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let item = dataSource[section]
        return item.shouldDisplayMore ? 30 : 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let moreView = YXCommentMoreFooterView()
        let item = dataSource[section]
        moreView.isHidden = !item.shouldDisplayMore
        moreView.moreButton.isSelected = self.dataSource[section].isExpand
        moreView.moreButton.qmui_tapBlock = { [weak self, weak moreView] _ in
            guard let `self` = self else { return }
            self.dataSource[section].isExpand = !self.dataSource[section].isExpand
            moreView?.moreButton.isSelected = self.dataSource[section].isExpand
            self.tableView.reloadData()
        }
        return moreView
    }
}

class YXCommentTextView: UIView {
    
    var sendAction: ((_ content: String) -> Void)?
    
    var textViewHeight: CGFloat = 40
    let maxTextCount = 200
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var textView: QMUITextView = {
        let view = QMUITextView.init()
        
        view.textColor = UIColor.qmui_color(withHexString: "#333333")
        view.font = .normalFont14()
        view.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        if let label  = view.value(forKey: "placeholderLabel") as? UILabel {
            label.numberOfLines = 1
        }
        view.placeholderMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
//        view.placeholder = YXLanguageUtility.kLang(key: "nbb_saysomething")
        view.keyboardType = .default
        view.returnKeyType = .send
        view.backgroundColor = UIColor.qmui_color(withHexString: "#F0F0F0")
        view.maximumHeight = 80
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
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "comment_send"), for: .normal)
        button.setImage(UIImage(named: "comment_send_gray"), for: .disabled)
        return button
    }()
    
    lazy var beyondLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont12()
        label.textColor = UIColor.qmui_color(withHexString: "#FF0000")
        label.isHidden = true
        return label
    }()
    
    func showWithKeyBoardUserInfo(info: QMUIKeyboardUserInfo) {
        self.isHidden = false
        sendButton.isEnabled = textView.text.count > 0
        QMUIKeyboardManager.animateWith(animated: true, keyboardUserInfo: info, animations: {
            if let view = self.superview {
                let distanceFromBottom = QMUIKeyboardManager.distanceFromMinYToBottom(in: view, keyboardRect: info.endFrame)
                self.containerView.layer.transform = CATransform3DMakeTranslation(0, (-distanceFromBottom - self.containerView.frame.size.height), 0)
            }
        }, completion: {_ in
            
        })
    }
    
    func hideWithKeyBoardUserInfo(info: QMUIKeyboardUserInfo) {
        self.isHidden = true
        QMUIKeyboardManager.animateWith(animated: true, keyboardUserInfo: info, animations: {
            self.containerView.layer.transform = CATransform3DIdentity
        }, completion: { (finish) in
            self.textView.placeholder = "" 
            self.removeFromSuperview()
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isHidden = true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        containerView.addSubview(textView)
//        containerView.addSubview(sendButton)
        containerView.addSubview(beyondLabel)
        addSubview(containerView)
        
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(40)
        }
        
//        sendButton.snp.makeConstraints { make in
//            make.right.equalToSuperview().offset(-32)
//            make.bottom.equalToSuperview().offset(-16)
//        }
        
        beyondLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-32)
            make.top.equalToSuperview().offset(32)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
            //            make.height.equalTo(56)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YXCommentTextView: QMUITextViewDelegate {
    
    func textViewShouldReturn(_ textView: QMUITextView!) -> Bool {
        self.sendButton.sendActions(for: .touchUpInside)
        return true
    }
    
    func textView(_ textView: QMUITextView!, newHeightAfterTextChanged height: CGFloat) {
        
        if height < 40, textViewHeight == 40 {
            return
        }
        var h = height
        if height < 40 {
            h = 40
        }
        
        textView.snp.updateConstraints { make in
            make.height.equalTo(h)
        }
        
        let change = h - textViewHeight
        
        self.containerView.layer.transform = CATransform3DTranslate(self.containerView.layer.transform, 0, -change, 0)
        textViewHeight = h
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.count > 0 {
            sendButton.isEnabled = true
        }else {
            sendButton.isEnabled = false
        }
        
        let beyondCount = textView.text.count - maxTextCount
        
        if beyondCount > 0 {
            beyondLabel.isHidden = false
            beyondLabel.text = "\(-beyondCount)"
        }else {
            beyondLabel.isHidden = true
        }
    }
}
