//
//  YXLiveChatRoomView.swift
//  uSmartOversea
//
//  Created by Apple on 2020/10/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RSKGrowingTextView
import IQKeyboardManagerSwift

class YXLiveChatRoomView: UIView {
    
    @objc weak var watchLiveViewController: UIViewController?

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.register(YXLiveChatRoomCell.self, forCellReuseIdentifier: "YXLiveChatRoomCell")
        return tableView
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        
        view.addSubview(stockButton)
        view.addSubview(inputButton)
        view.addSubview(likeButton)
        view.addSubview(likeCountView)
        view.backgroundColor = UIColor(hexString: "#191919")!.withAlphaComponent(0.03)
        
        stockButton.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.bottom.equalTo(-12)
            make.size.equalTo(stockButton.size)
        }
        
        inputButton.snp.makeConstraints { (make) in
            make.left.equalTo(74)
            make.right.equalTo(-64)
            make.height.equalTo(40)
            make.top.equalTo(12)
        }
        
        likeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        likeCountView.snp.makeConstraints { (make) in
            make.centerX.equalTo(likeButton)
            make.top.equalTo(2)
            make.height.equalTo(20)
        }
        
        return view
    }()
    
//    lazy var sendButton: QMUIButton = {
//        let button = QMUIButton()
//        button.setTitle(YXLanguageUtility.kLang(key: "live_send"), for: .normal)
//        button.setTitleColor(UIColor(hexString: "#2F79FF"), for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 16)
//        button.rx.tap.asObservable().subscribe(onNext: { [weak self]() in
//            self?.comment()
//        }).disposed(by: rx.disposeBag)
//        return button
//    }()
    
    lazy var likeButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named:"live_like"), for: .normal)

        button.rx.tap.asObservable().subscribe(onNext: { [weak self]() in
            self?.showApplause()
        }).disposed(by: rx.disposeBag)
        return button
    }()
    
    var likeCount: Int64 = 0
    lazy var likeCountView: QMUIButton = {
        let button = QMUIButton()
        let bgImage = UIImage(gradientColors: [UIColor(hexString: "#FFB5B5")!, UIColor(hexString: "#EA3D3D")!], size: CGSize(width: 30, height: 20))
        button.setBackgroundImage(bgImage, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.setTitle("0", for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()
    
    var timeFlag: YXTimerFlag?
    
    @objc var liveModel: YXLiveDetailModel? {
        didSet {
            if timeFlag == nil {
                timeFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (flag) in
                    self?.requestDetail()
                    self?.requestLikeCount()
                    self?.reqeuestStockList()
                }, timeInterval: 3, repeatTimes: Int.max, atOnce: true)
            }
        }
    }
    
    var dataSource: [YXCommentItem] = []
    
    lazy var stockButton: QMUIButton = {
        let button = QMUIButton()
        button.adjustsButtonWhenHighlighted = false
        button.setImage(UIImage(named: "icon_gupiao"), for: .normal)
        button.adjustsButtonWhenDisabled = false
        button.sizeToFit()
        button.qmui_badgeBackgroundColor = UIColor(hexString: "#269DF1")
        button.qmui_badgeTextColor = .white
        button.qmui_badgeFont = .systemFont(ofSize: 12)
        button.qmui_badgeOffset = CGPoint(x: -14, y: button.height)
        button.qmui_badgeContentEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)

        button.rx.tap.asObservable().subscribe(onNext: { [weak self] () in
            guard let strongSelf = self else { return }
            
            if strongSelf.stockView.superview == nil {
                if button.qmui_badgeInteger == 0 { return }
                strongSelf.showStockView()
            } else {
                strongSelf.hideStockView()
            }


        }).disposed(by: rx.disposeBag)
        
        return button
    }()
    
    lazy var stockView: YXLiveStockListView = {
        let stockHeight = YXConstant.screenHeight - YXConstant.safeAreaInsetsBottomHeight() - YXConstant.navBarHeight() - 65
        let stockView = YXLiveStockListView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: stockHeight))
        stockView.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] (_) in
            guard let strongSelf = self else { return }
            
            strongSelf.hideStockView()
        }).disposed(by: rx.disposeBag)

        stockView.backgroundColor = UIColor(hexString: "#191919")?.withAlphaComponent(0.5)
        return stockView
    }()

    @objc lazy var stockPopupView: YXStockLivePopupView = {
        let view = YXStockLivePopupView()
        view.sourceView = stockButton
        
        view.cell.rx.tapGesture().subscribe(onNext: {
            [weak self] ges in
            guard let `self` = self else { return }
            if ges.state == .ended {
                let quote = view.cell.quote
                if let symbol = quote?.symbol, let market = quote?.market {
                    if let currentViewController = self.watchLiveViewController as? YXWatchLiveViewController {
                        self.hideStockPopupView(false)
                        YXFloatingView.shared().sourceViewController = currentViewController
                        currentViewController.showFloatingView()
                        
                        let input = YXStockInputModel()
                        input.market = market
                        input.symbol = symbol
                        input.name = quote?.name ?? ""
                        
                        currentViewController.viewModel.services.pushPath(.stockDetail, context: ["dataSource": [input], "selectIndex":  0], animated: true)


                    }
                }
            }
        }).disposed(by: rx.disposeBag)

        return view
    }()
    
    
    lazy var inputButton: QMUIButton = {
        let button = QMUIButton()
        button.adjustsButtonWhenHighlighted = false
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 4
        button.setTitle(YXLanguageUtility.kLang(key: "live_write_comment"), for: .normal)
        button.setImage(UIImage(named: "edit_comment"), for: .normal)
        button.setTitleColor(UIColor(hexString: "#191919")!.withAlphaComponent(0.45), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.imagePosition = .left
        button.spacingBetweenImageAndTitle = 6
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left
        
        button.rx.tap.asObservable().subscribe(onNext: { [weak self] () in
            guard let strongSelf = self else { return }
            
            strongSelf.hideStockView()
            strongSelf.hideStockPopupView(false)

            
            if YXUserManager.isLogin() == false {
                (YXNavigationMap.navigator as? NavigatorServices)?.pushToLoginVC(callBack: nil)
                return
            }
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
        view.backgroundColor = .white
        view.isHidden = true
        
        //view.addSubview(sendButton)
        view.addSubview(inputTextView)
        
//        sendButton.snp.makeConstraints { (make) in
//            make.right.equalToSuperview()
//            make.centerY.equalToSuperview()
//            make.width.equalTo(63)
//            make.height.equalToSuperview()
//        }
        
        inputTextView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.right.equalToSuperview().offset(-12)
            //make.height.greaterThanOrEqualTo(36)
        }
        
        return view
    }()
    
    lazy var inputTextView: RSKGrowingTextView = {
        let textView = RSKGrowingTextView()
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 4
        textView.maximumNumberOfLines = 3
        textView.returnKeyType = .send
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        let placeholder = NSMutableAttributedString.qmui_attributedString(with: UIImage(named:"edit_comment") ?? UIImage(), baselineOffset: -3, leftMargin: 0, rightMargin: 4)
        placeholder.append(NSAttributedString(string: YXLanguageUtility.kLang(key: "live_write_comment"), attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.qmui_color(withHexString: "#191919")!.withAlphaComponent(0.45)]))
        textView.attributedPlaceholder = placeholder
        return textView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(YXCommentView.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(YXCommentView.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        addSubview(bottomView)
        addSubview(tableView)
        
        bottomView.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-YXConstant.safeAreaInsetsBottomHeight())
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top).offset(-16)
        }
                
        IQKeyboardManager.shared.enable = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        closeTimer()
    }
    
    @objc func pauseTimer() {
        if let timerFlag = self.timeFlag {
            YXTimerSingleton.shareInstance().pauseOperation(withFlag: timerFlag)
        }
        IQKeyboardManager.shared.enable = true
    }
    
    
    @objc func resumeTimer() {
        if let timerFlag = self.timeFlag {
            YXTimerSingleton.shareInstance().resumeOperation(withFlag: timerFlag)
        }
        IQKeyboardManager.shared.enable = false
    }
    
    @objc func closeTimer() {
        if let timeFlag = self.timeFlag {
            YXTimerSingleton.shareInstance().invalidOperation(withFlag: timeFlag)
        }
    }
    
    func comment() {
        guard let content = inputTextView.text, content.count > 0 else { return }
        
        let hud = YXProgressHUD.showLoading("")
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
                    hud.hideHud()
                    if responseModel.code != .success {
                        YXProgressHUD.showError(responseModel.msg)
                    } else {
                        strongSelf.inputTextView.text = nil
                        strongSelf.inputTextView.resignFirstResponder()
                        strongSelf.requestDetail()
                        
                        strongSelf.likeCount = 0
                    }
                }, failure: {(_) in
                    //strongSelf.sendButton.isEnabled = true
                    hud.hideHud()
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                })
            } else {
                //strongSelf.sendButton.isEnabled = true
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                hud.hideHud()
            }
            
            }, failure: { [weak self] (_) in
                //self?.sendButton.isEnabled = true
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
                        //var attributeString = NSMutableAttributedString(string: userName + ":", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor(])
//                        if comment.comment_user?.user_id == strongSelf.liveModel?.anchor?.anchor_uid {
//                            attributeString = NSMutableAttributedString(string: userName + ":", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.qmui_color(withHexString: "#2F79FF")!])
//                        }
                        item.nickAttributeString =  NSMutableAttributedString(string: userName, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor(hexString: "#191919")!.withAlphaComponent(0.45)])
                        if comment.comment_user?.user_id == strongSelf.liveModel?.anchor?.anchor_uid {
//                            item.nickAttributeString = NSMutableAttributedString(string: userName, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor(hexString: "#2F79FF")!])
                            item.isAnchor = true
                        }
                        item.iconUrl = comment.comment_user?.head_shot_url ?? ""
                        let attributeString = NSAttributedString(string: content, attributes: [.foregroundColor: UIColor(hexString: "#191919")!, .font: UIFont.systemFont(ofSize: 14)])
                        item.attributeString = attributeString
                        item.height = attributeString.boundingRect(with: CGSize(width: strongSelf.bounds.width - 122, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height + 60
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
//                        var attributeString = NSMutableAttributedString(string: userName + "：", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.white.withAlphaComponent(0.65)])
                        item.nickAttributeString =  NSMutableAttributedString(string: userName, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor(hexString: "#191919")!.withAlphaComponent(0.45)])
                        if comment.comment_user?.user_id == strongSelf.liveModel?.anchor?.anchor_uid {
//                            item.nickAttributeString = NSMutableAttributedString(string: userName, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor(hexString: "#2F79FF")!])
                            item.isAnchor = true
                        }
                        item.iconUrl = comment.comment_user?.head_shot_url ?? ""
                        let attributeString = NSAttributedString(string: content, attributes: [.foregroundColor: UIColor(hexString: "#191919")!, .font: UIFont.systemFont(ofSize: 14)])
                        item.attributeString = attributeString
                        item.height = attributeString.boundingRect(with: CGSize(width: strongSelf.bounds.width - 122, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height + 60
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
    
    func requestLikeCount() {
        let requestModel = YXLiveLikeCountRequestModel()
        let list = [["bizId" : liveModel?.post_id ?? "", "bizPreFix": "live::chat"]]
        requestModel.list = list;
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            
            if let dic = responseModel.data?["data"] as? NSDictionary, let value = dic.allValues.first as? [String : Any], let count = value["count"] as? Int64 {
                let totalCount = count + strongSelf.likeCount
                strongSelf.likeCountView.setTitle("\(totalCount)", for: .normal)
                strongSelf.updateLikeCount()
            }
        }, failure: { (_) in
            
        })
    }
    
    func updateLikeCount() {
        guard likeCount > 0 else {
            return
        }
        let requestModel = YXUpdateLiveLikeCountRequestModel()
        requestModel.biz = ["bizId" : liveModel?.post_id ?? "", "bizPreFix": "live::chat"]
        requestModel.count = likeCount
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            if responseModel.code == .success {
            
                strongSelf.likeCount = 0
            }
        }, failure: { (_) in
            
        })
    }
    
    var timeNum = 0
    func reqeuestStockList() {
        if timeNum % 2 == 0 {
            guard let stocksId = self.liveModel?.show_stocks_id else {
                return
            }
            
            let requestModel = YXLiveShowStockRequestModel()
            requestModel.show_stocks_id = stocksId
            let request = YXRequest(request: requestModel)
            request.startWithBlock(success: { [weak self] (responseModel) in
                guard let strongSelf = self else { return }
            
                if responseModel.code == .success {
                    if let model = responseModel as? YXLiveShowStockResponseModel,
                       let stockIdList = model.stockIdList {
                        if let last = stockIdList.last {
                            if strongSelf.stockView.stockIdList.contains(last) {
                                if strongSelf.stockView.stockIdList.count != stockIdList.count {
                                    strongSelf.stockView.stockIdList = stockIdList
                                }
                            } else {
                                if (strongSelf.stockView.superview == nil) {
                                    strongSelf.requestQuote(last)
                                }
                                
                                strongSelf.stockView.stockIdList = stockIdList
                            }
                        }
                        
                        strongSelf.stockButton.qmui_badgeInteger = UInt(stockIdList.count)
                    }
                }

            }, failure: { (_) in
                
            })
        }
        timeNum += 1
    }
    
    func requestQuote(_ last: String) {
        if let currentViewController = UIViewController.current() as? YXWatchLiveViewController {
            if currentViewController.playView.isFullScreen {
                return
            }
        }
        let secuId = YXSecuID(string: last)
        let secu = Secu(market: secuId.market, symbol: secuId.symbol)
        let level = YXUserManager.shared().getLevel(with: secu.market)
        YXQuoteManager.sharedInstance.onceRtSimpleQuote(secus: [secu], level: level, handler: ({ [weak self] (quotes, scheme) in
            guard let strongSelf = self else { return }
            if let quote = quotes.first {
                strongSelf.showStockPopupView(quote)
            }
        }))
    }

    func showApplause() {
        likeCount += 1
        var totalLikeCount = Int64(likeCountView.titleLabel?.text ?? "0") ?? 0
        totalLikeCount += 1
        likeCountView.setTitle("\(totalLikeCount)", for: .normal)
        
        let index = arc4random_uniform(5)
        let applauseView = UIImageView(image: UIImage(named: "icon\(index)"))
        applauseView.frame = CGRect(x: self.frame.size.width - 64, y: self.frame.size.height - 98 - YXConstant.safeAreaInsetsBottomHeight(), width: 34, height: 34)
        addSubview(applauseView)
        
        let animalHeight: CGFloat = 130
        applauseView.transform = CGAffineTransform(scaleX: 0, y: 0)
        applauseView.alpha = 0
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            applauseView.transform = .identity
            applauseView.alpha = 0.9
        }, completion: nil)
        
        let i: CGFloat = CGFloat(arc4random_uniform(2))
        let rotationDirection: CGFloat = CGFloat(1 - (2 * i))
        let rotationFraction: CGFloat = CGFloat(arc4random_uniform(10))
        
        UIView.animate(withDuration: 4, animations: {
            let angle = rotationDirection * CGFloat.pi / (4.0 + rotationFraction * 0.2)
            applauseView.transform = CGAffineTransform(rotationAngle: angle)
        }, completion: nil)
        
        let path = UIBezierPath()
        path.move(to: applauseView.center)
        
        let viewX = applauseView.center.x
        let viewY = applauseView.center.y
        let endPoint = CGPoint(x: viewX + rotationDirection * 10, y: viewY - animalHeight)
        
        let j: CGFloat = CGFloat(arc4random_uniform(2))
        let travelDirection: CGFloat = 1 - (2 * j)
        
        let m1 = viewX + travelDirection * (CGFloat(arc4random_uniform(20)) + 50.0)
        let n1 = viewY - 60.0 + travelDirection * CGFloat(arc4random_uniform(20))
        let m2 = viewX - travelDirection * (CGFloat(arc4random_uniform(20)) + 50.0)
        let n2 = viewY - 90.0 + travelDirection * CGFloat(arc4random_uniform(20))

        let controlPoint1 = CGPoint(x: m1, y: n1)
        let controlPoint2 = CGPoint(x: m2, y: n2)
        
        path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnimation.path = path.cgPath
        keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        keyFrameAnimation.duration = 3
        applauseView.layer.add(keyFrameAnimation, forKey: "positionOnPath")
        
        UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseInOut, animations: {
            applauseView.alpha = 0.0
        }) { (finished) in
            applauseView.removeFromSuperview()
        }
    }
 
//
//        //关键帧动画,实现整体图片位移
//        CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//        keyFrameAnimation.path = heartTravelPath.CGPath;
//        keyFrameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
//        keyFrameAnimation.duration = 3 ;//往上飘动画时长,可控制速度
//        [applauseView.layer addAnimation:keyFrameAnimation forKey:@"positionOnPath"];
//
//        //消失动画
//        [UIView animateWithDuration:3 animations:^{
//            applauseView.alpha = 0.0;
//        } completion:^(BOOL finished) {
//            [applauseView removeFromSuperview];
//        }];
//    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

// MARK: StockView
extension YXLiveChatRoomView {
    
    func showStockPopupView(_ quote: YXV2Quote) {
        stockPopupView.cell.quote = quote
        stockPopupView.showWith(animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.hideStockPopupView(true)
        }
    }
    
    @objc func hideStockPopupView(_ animated: Bool) {
        if stockPopupView.isShowing() {
            stockPopupView.hideWith(animated: animated)
        }
    }
    
    func showStockView() {
        hideStockPopupView(false)
        let currentViewController = UIViewController.current()
        currentViewController.view.addSubview(stockView)
        currentViewController.view.addSubview(stockButton)
        
        stockView.requestStockQuote()
        
        stockButton.snp.remakeConstraints { (make) in
            make.left.equalTo(12)
            make.bottom.equalTo(-12 - YXConstant.safeAreaInsetsBottomHeight())
            make.size.equalTo(stockButton.size)
        }
        
        stockButton.isEnabled = false
        stockView.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.stockView.alpha = 1.0
        }) { (isFinish) in
            self.stockButton.isEnabled = true
        }
    }
    
    func hideStockView() {

        stockButton.isEnabled = false
        stockView.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.stockView.alpha = 0.0
        }) { (isFinish) in
            self.stockView.removeFromSuperview()
            self.bottomView.addSubview(self.stockButton)
            
            self.stockButton.snp.remakeConstraints { (make) in
                make.left.equalTo(12)
                make.bottom.equalTo(-12)
                make.size.equalTo(self.stockButton.size)
            }
            self.stockButton.isEnabled = true
        }
    }
}

extension YXLiveChatRoomView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            comment()
            return false
        }
        return true
    }
}

extension YXLiveChatRoomView: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YXLiveChatRoomCell", for: indexPath) as! YXLiveChatRoomCell
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

extension YXLiveChatRoomView {
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
