//
//  YXShortVideoCommentViewController.swift
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
        tableView.backgroundColor = QMUITheme().popupLayerColor()
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
    
    private lazy var popover: YXStockPopover = {
        let popover = YXStockPopover()
        return popover
    }()
    
    lazy var commentInputView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().popupLayerColor()
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
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel4()
        label.text = YXLanguageUtility.kLang(key: "nbb_saysomething")
        
        let grayBackView = UIView()
        grayBackView.backgroundColor = QMUITheme().blockColor()
        grayBackView.layer.cornerRadius = 6
        grayBackView.layer.masksToBounds = true
        
        let line = UIView()
        line.backgroundColor = QMUITheme().popSeparatorLineColor()
        
        view.addSubview(grayBackView)
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(line)
        view.addSubview(imageView2)
        
        grayBackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-56)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(6)
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
            make.height.equalTo(0.5)
        }
        
        imageView2.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(grayBackView)
        }
        
        return view
    }()
    
    lazy var commentTextView: YXCommentTextView1 = {
        let view = YXCommentTextView1()
        return view
    }()
    
    var currentSelectedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = QMUITheme().popupLayerColor()
        
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
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"), in: window)
                }
            }
        }.disposed(by: disposeBag)
        
        // 删除评论
        viewModel.deleteComment.drive { [weak self] index in
            if let index = index {
                YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "mine_del_success"))
                self?.deleteComment(indexPath: index)
            } else {
                if let window = UIApplication.shared.keyWindow {
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"), in: window)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.likeComment.drive { success in
            if !success {
                if let window = UIApplication.shared.keyWindow {
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"), in: window)
                }
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
                    self.commentTextView.textView.placeholder = YXLanguageUtility.kLang(key: "nbb_saysomething")
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                    self?.commentTextView.textView.becomeFirstResponder()
                }
            }
        }
    }
    
    func getMenuView(item: YXShortVideoCommentItem?, indexPath: IndexPath) -> UIStackView? {
        guard let item = item else { return nil }
        guard let uid = item.uid, let commentId = item.commentId else { return nil}
        
        let replyButton = QMUIButton()
        replyButton.backgroundColor = .clear
        replyButton.setTitle(YXLanguageUtility.kLang(key: "reply"), for: .normal)
        replyButton.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            self.popover.dismiss()
            self.benginInput(indexPath: indexPath, replyId: commentId, replyName: item.nick)
        }
        replyButton.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        replyButton.titleLabel?.font = .systemFont(ofSize: 14)
        replyButton.contentMode = .center
        replyButton.frame = CGRect.init(x: 0, y: 0, width: 75, height: 48)
        
        
        let complainButton = QMUIButton()
        replyButton.backgroundColor = .clear
        complainButton.setTitle(YXLanguageUtility.kLang(key: "report_comment"), for: .normal)
        complainButton.qmui_tapBlock = { [weak self] _ in
            self?.popover.dismiss()
            self?.handleComplain(indexPath: indexPath,
                                 commentId: commentId)
        }
        complainButton.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        complainButton.titleLabel?.font = .systemFont(ofSize: 14)
        complainButton.contentMode = .center
        complainButton.frame = CGRect.init(x: 0, y: 0, width: 75, height: 48)
        
        let deleteButton = QMUIButton()
        replyButton.backgroundColor = .clear
        deleteButton.setTitle(YXLanguageUtility.kLang(key: "nbb_delete"), for: .normal)
        deleteButton.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            self.deleteComment.onNext((commentId,indexPath))
            self.popover.dismiss()
        }
        deleteButton.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 14)
        deleteButton.contentMode = .center
        deleteButton.frame = CGRect.init(x: 0, y: 0, width: 75, height: 48)
        
        
        var array: [UIView] = [replyButton,complainButton]
        if item.delFlag == true {
            array.insert(deleteButton, at: 1)
        }
        var views = array.flatMap { btn -> [UIView] in
            let line = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 1))
            line.backgroundColor = UIColor.themeColor(withNormalHex: "#DDDDDD", andDarkColor: "#555665")
            btn.snp.makeConstraints { make in
                make.width.equalTo(75)
                make.height.equalTo(48)
            }
            line.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(0.5)
            }
            return [btn,line]
        }
        views.removeLast()
        let stackView = UIStackView.init(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 0
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 75, height: array.count*49))
        stackView.backgroundColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#19191F")
        stackView.frame = frame
        return stackView
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
            self.showEmptyView(with: UIImage(named: "empty_noData"),
                               text: YXLanguageUtility.kLang(key: "common_no_data"),
                               detailText: nil,
                               buttonTitle: nil,
                               buttonAction: nil)
            self.view.bringSubviewToFront(self.commentInputView)
            self.emptyView?.contentView.backgroundColor = QMUITheme().popupLayerColor()
            self.emptyView?.backgroundColor = QMUITheme().popupLayerColor()
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
            cell.backgroundColor = QMUITheme().popupLayerColor()
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
                guard let `self` = self else { return }
                if let view = self.getMenuView(item: item, indexPath: indexPath) {
                    self.popover.show(view, from: cell.moreButton,
                                      in: self.view)
                    view.backgroundColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#19191F")
                }

            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXShortVideoReplyCell.self), for: indexPath) as! YXShortVideoReplyCell
            let item = dataSource[indexPath.section].childrenNodeList[indexPath.row-1]
            cell.backgroundColor = QMUITheme().popupLayerColor()
            cell.authorId = viewModel.authorId
            cell.model = item
            cell.isLive = self.viewModel.businessType == .live
            if indexPath.row == 1 {
                cell.stackView.snp.updateConstraints { make in
                    make.top.equalToSuperview().offset(12)
                }
            } else {
                cell.stackView.snp.updateConstraints { make in
                    make.top.equalToSuperview().offset(0)
                }
            }
            cell.bgView.layer.cornerRadius = 8
            let childrenNodes = dataSource[indexPath.section].childrenNodeList
            if indexPath.row == 1 {
                if childrenNodes.count == 1 {
                    cell.bgView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
                } else {
                    cell.bgView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
                }
            } else if indexPath.row == childrenNodes.count {
                cell.bgView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            } else {
                cell.bgView.layer.maskedCorners = []
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
        return item.shouldDisplayMore ? 64 : 24
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let moreView = YXCommentMoreFooterView()
        moreView.backgroundColor = QMUITheme().popupLayerColor()
        let item = dataSource[section]
        moreView.moreButton.isSelected = self.dataSource[section].isExpand
        moreView.bg.isHidden = !item.shouldDisplayMore
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
        view.backgroundColor = QMUITheme().popupLayerColor()
        return view
    }()
    
    lazy var textView: QMUITextView = {
        let view = QMUITextView.init()
        
        view.textColor = QMUITheme().textColorLevel1()
        view.font = .normalFont14()
        view.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 50)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        if let label  = view.value(forKey: "placeholderLabel") as? UILabel {
            label.numberOfLines = 1
        }
        view.placeholderMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50)
//        view.placeholder = YXLanguageUtility.kLang(key: "nbb_saysomething")
        view.keyboardType = .default
        view.backgroundColor = QMUITheme().blockColor()
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
        containerView.addSubview(sendButton)
        containerView.addSubview(beyondLabel)
        addSubview(containerView)
        
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(40)
        }
        
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-32)
            make.bottom.equalToSuperview().offset(-16)
        }
        
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
