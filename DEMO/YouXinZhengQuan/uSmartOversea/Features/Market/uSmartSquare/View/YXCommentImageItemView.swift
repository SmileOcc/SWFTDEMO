//
//  YXCommentImageItemView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/24.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentImageItemView: UIView {

    lazy var imageView:UIImageView  = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    lazy var playImageView:UIImageView  = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "icon_play_normal")
        imageView.isHidden = true
        
        return imageView
    }()
    
    lazy var statusView:YXNewsLiveStatusView = {
        let view = YXNewsLiveStatusView()
        view.isHidden = true
        
        return view
        
    }()
    
    lazy var videoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#141414")?.withAlphaComponent(0.6)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.isHidden = true
        
        return view
    }()
    lazy var videoIconImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "play_red")
        
        return imageView
    }()
    lazy var timeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().foregroundColor()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#000000")?.withAlphaComponent(0.38)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.isHidden = true
        
        return view
    }()
    lazy var backLabel: QMUILabel = {
        let label = QMUILabel()
        label.backgroundColor = UIColor.qmui_color(withHexString: "#979797")
        label.textAlignment = .center
        label.text = YXLanguageUtility.kLang(key: "news_play")
        label.textColor = QMUITheme().foregroundColor()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    lazy var backTimeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().foregroundColor()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()

    lazy var hotDegreeLabel: QMUILabel = {
        let label = QMUILabel()
        label.backgroundColor = UIColor.qmui_color(withHexString: "#979797")
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 10)
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(imageView)
        addSubview(playImageView)
        imageView.addSubview(statusView)
        
        addSubview(videoView)
        videoView.addSubview(videoIconImageView)
        videoView.addSubview(timeLabel)
        
        addSubview(backView)
        backView.addSubview(backLabel)
        backView.addSubview(backTimeLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        videoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview().offset(6)
            make.right.equalTo(timeLabel.snp.right).offset(5)
            make.height.equalTo(16)
        }
        videoIconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.width.height.equalTo(12)
            make.centerY.equalToSuperview()
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(videoIconImageView.snp.right).offset(2)
            make.centerY.equalToSuperview()
        }
        
        backView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview().offset(6)
            make.right.equalTo(backTimeLabel.snp.right).offset(5)
            make.height.equalTo(16)
        }
        backLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(28)
            make.height.equalTo(16)
            make.centerY.equalToSuperview()
        }
        backTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(backLabel.snp.right).offset(2)
            make.centerY.equalToSuperview()
        }
        
        playImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        statusView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.height.equalTo(16)
            make.top.equalToSuperview().offset(6)
        }

        addSubview(hotDegreeLabel)
        hotDegreeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.right.equalToSuperview().offset(-6)
            make.height.equalTo(16)
        }
    }
    
    var modelDic:[String:String]? {
        didSet {
            updateUI()
        }
    }
    func updateUI() {
        if let model = modelDic {
            //内容类型 1=要闻资讯 2=图文 3=直播 4=回放 5=个股讨论
            let content_type:String = model["content_type"] ?? "0"
            let duration:String = model["duration"] ?? ""
            let videoUrl:String = model["videoUrl"] ?? ""
            let chatRoomStatus = Int(model["chatRoomStatus"] ?? "0") ?? 0
            videoView.isHidden = true
            statusView.rightLabel.isHidden = false
            if Int(content_type) == YXInformationFlowType.live.rawValue {
                
                self.playImageView.isHidden = false
                self.statusView.isHidden = false
                self.backView.isHidden = true
                
                self.statusView.rightLabel.text = ""
                self.statusView.rightLabel.isHidden = true
                self.statusView.status = .live
            }else if Int(content_type) == YXInformationFlowType.replay.rawValue {
                self.playImageView.isHidden = false
                self.statusView.isHidden = true
                self.backView.isHidden = false
                backTimeLabel.text = YXUGCCommentManager.transforMinSencond(ms: duration)
            }else if Int(content_type) == YXInformationFlowType.chatRoom.rawValue {
                self.playImageView.isHidden = true
                self.statusView.isHidden = false
                self.backView.isHidden = true
                
                self.statusView.rightLabel.isHidden = true
                if (YXChatRoomStatus.init(rawValue: chatRoomStatus) == .live) {
                    self.statusView.status = .chatRoomLive
                }else {
                    self.statusView.status = .chatRoomEnd
                }
                
            }else{
                self.statusView.isHidden = true
                self.backView.isHidden = true
                if videoUrl.count > 0 {
                    self.playImageView.isHidden = false
                    videoView.isHidden = false
                    timeLabel.text = YXUGCCommentManager.transforMinSencond(ms: duration)
                }else{
                    self.playImageView.isHidden = true
                }
            }

            // TODO: 根据需求暂时不显示观看人数
//            if let hotDegreeStr = model["hot_degree"],
//               let hotDegree = Int(hotDegreeStr),
//               hotDegree > 0 {
//                hotDegreeLabel.isHidden = false
//                hotDegreeLabel.text = hotDegreeStr + YXLanguageUtility.kLang(key: "live_viewer")
//            } else {
                hotDegreeLabel.isHidden = true
//            }
        }else{
            self.playImageView.isHidden = true
            self.statusView.isHidden = true
            self.backView.isHidden = true
            self.videoView.isHidden = true
            hotDegreeLabel.isHidden = true
        }
    }
}
