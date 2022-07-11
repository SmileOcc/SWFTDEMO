//
//  YXCommentLandscapeView.swift
//  uSmartOversea
//
//  Created by suntao on 2021/2/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RSKGrowingTextView
import NSObject_Rx
import YXKit

class YXCommentLandscapeView: UIView {
    
    lazy var gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        let gradientLayer: CAGradientLayer = CAGradientLayer.init()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 300, height: YXConstant.screenWidth - 70 - 90)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.15)
        gradientLayer.colors = [UIColor.clear.withAlphaComponent(0).cgColor ,UIColor.clear.withAlphaComponent(1.0).cgColor]
        gradientLayer.locations = [0,1.0]
        gradientLayer.rasterizationScale = UIScreen.main.scale
    
        view.layer.mask = gradientLayer
        
        return view
    }()
    

    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.register(YXCommentLandscapeCell.self, forCellReuseIdentifier: "YXCommentLandscapeCell")
        return tableView
    }()
    
    var iconImageString: NSAttributedString = {
        let attach : NSTextAttachment = NSTextAttachment()
        attach.image = UIImage(named: "zhubo_icon")
        attach.bounds = CGRect(x: 0, y: -2, width: 28, height: 15)
        
        let imageString: NSAttributedString = NSAttributedString(attachment: attach)
        
        return imageString
    }()
    
    var timeFlag: YXTimerFlag?
    
    @objc var liveModel: YXLiveDetailModel? {
        didSet {
            if timeFlag == nil {
                timeFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (flag) in
                    self?.requestDetail()
                }, timeInterval: 3, repeatTimes: Int.max, atOnce: true)
            }
        }
    }
    
    var dataSource: [YXCommentItem] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        gradientView.frame = CGRect(x: 0, y: 0, width: 300, height: YXConstant.screenWidth - 70 - 90)
        addSubview(gradientView)
        gradientView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(gradientView)
        }
    }
    
    @objc func startTimer() {
        self.timeFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (flag) in
            self?.requestDetail()
        }, timeInterval: 3, repeatTimes: Int.max, atOnce: true)
    }

    @objc func closeTimer() {
        if let timeFlag = self.timeFlag {
            YXTimerSingleton.shareInstance().invalidOperation(withFlag: timeFlag)
        }
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
                        if comment.comment_user?.user_id == strongSelf.liveModel?.anchor?.anchor_uid {//是主播
                            attributeString = NSMutableAttributedString(string: userName + ":", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.white.withAlphaComponent(0.65)])
                            attributeString.insert(self!.iconImageString, at: 0)
                        }
                        let userId : String = comment.comment_user?.user_id ?? ""
                        let userIdDouble: Double = Double(userId) ?? 99
                        if( YXUserManager.userUUID() == UInt64(userIdDouble) ){   //是本人
                            attributeString = NSMutableAttributedString(string: userName + ":", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.qmui_color(withHexString: "#2F79FF")!])
                        }
                        attributeString.append(NSAttributedString(string: content, attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 14)]))
                        item.attributeString = attributeString
                        item.height = attributeString.boundingRect(with: CGSize(width: 270, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height + 18
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
    var commentRequest: YXRequest?

    @objc func requestDetail() {
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
        if let request = self.commentRequest {
            request.stop()
            self.commentRequest = nil
        }

        self.commentRequest = YXRequest(request: requestModel)
        self.commentRequest?.startWithBlock(success: { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            if responseModel.code == .success {
                if let model = responseModel as? YXCommentDetailResponseModel, let comments = model.comment_detail_info, comments.count > 0 {
                    let items = comments.reversed().map { (comment) -> YXCommentItem  in
                        let userName = comment.comment_user?.nick ?? ""
                        let content = comment.content ?? ""
                        let item = YXCommentItem()
                        var attributeString = NSMutableAttributedString(string: userName + "：", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.white.withAlphaComponent(0.65)])
                        
                        if comment.comment_user?.user_id == strongSelf.liveModel?.anchor?.anchor_uid { //是主播
                            attributeString = NSMutableAttributedString(string: userName + ":", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.white.withAlphaComponent(0.65)])
                            attributeString.insert(self!.iconImageString, at: 0)
                            
                        }
                        let userId : String = comment.comment_user?.user_id ?? ""
                        let userIdDouble: Double = Double(userId) ?? 99
                        if( YXUserManager.userUUID() == UInt64(userIdDouble) ){   //是本人
                            attributeString = NSMutableAttributedString(string: userName + ":", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.qmui_color(withHexString: "#2F79FF")!])
                        }
                        
                        attributeString.append(NSAttributedString(string: content, attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 14)]))
                        item.attributeString = attributeString
                        item.height = attributeString.boundingRect(with: CGSize(width: 270, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height + 18
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
    
    @objc func updateRequestDetailFromLogin() {
        latestId = nil //重新拉取全量
        self.dataSource.removeAll()
        requestDetail()
    }

    
}

extension YXCommentLandscapeView: UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YXCommentLandscapeCell", for: indexPath) as! YXCommentLandscapeCell
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

