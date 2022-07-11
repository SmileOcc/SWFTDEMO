//
//  YXCommentDetailToolView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentDetailToolView: UIView {
    
    @objc var toolActionBlock:((_ type:CommentButtonType) -> Void)?
    
    private var likeFlag:Bool = false
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().blockColor()
        view.layer.cornerRadius = 6

        return view
    }()
    
    lazy var editImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage.init(named: "comment_edit")
        return view
    }()
    
    lazy var writeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.45)
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = YXLanguageUtility.kLang(key: "live_write_comment")
        
        return label
    }()
    
    lazy var writeButton: QMUIButton = {
        let btn = QMUIButton()
        btn.addTarget(self, action: #selector(writeAction(_:)), for: .touchUpInside)
       
        return btn
    }()
    
    lazy var likeCountLab:QMUILabel = {
        let label = QMUILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel1()
    
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .left
        
        return label
    }()

    lazy var likeBtn: YXExpandAreaButton = {
        let btn = YXExpandAreaButton()
        btn.expandX = 20
        btn.expandY = 20
        
        btn.addSubview(likeImageView)
        likeImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        btn.addTarget(self, action: #selector(likeAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var shareButton: YXExpandAreaButton = {
        let btn = YXExpandAreaButton()
        btn.expandX = 20
        btn.expandY = 20
        btn.setBackgroundImage(UIImage(named:"comment_foot_share"), for: .normal)
        btn.addTarget(self, action: #selector(shareAction(_:)), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var likeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "comment_foot_like")
        return imageView
    }()

    lazy var likeCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.text = ""
        return label
    }()
    lazy var topLine: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = QMUITheme().foregroundColor()
//        self.layer.shadowColor = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.05).cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: -2)
//        self.layer.shadowOpacity = 1
//        self.layer.shadowRadius = 2
        
        addSubview(bgView)
        bgView.addSubview(writeLabel)
        bgView.addSubview(editImageView)
        bgView.addSubview(writeButton)
        addSubview(likeBtn)
        addSubview(likeCountLab)
        addSubview(shareButton)
        addSubview(topLine)

        topLine.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        likeCountLab.snp.makeConstraints { make in
            make.left.equalTo(likeBtn.snp.right).offset(-5)
            make.bottom.equalTo(likeBtn.snp.top).offset(3)
            make.height.equalTo(12)
        }
        
        shareButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(bgView.snp.centerY)
            make.height.width.equalTo(24)
            
        }
        likeBtn.snp.makeConstraints { make in
            make.right.equalTo(shareButton.snp.left).offset(-22)
            make.centerY.equalTo(bgView.snp.centerY)
            make.height.width.equalTo(24)
            
        }
        
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(7)
            make.right.equalTo(likeBtn.snp.left).offset(-24)
            make.height.equalTo(uniVerLength(40))
        }
        editImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        writeLabel.snp.makeConstraints { make in
            make.left.equalTo(editImageView.snp.right).offset(6)
            make.top.bottom.equalToSuperview()
        }
        
        writeButton.snp.makeConstraints { make in
            make.edges.equalTo(bgView)
        }

    }
    
    
    @objc func updateLikeCount(likeCount:Int, likeFlag:Bool) {
        self.likeFlag = likeFlag
        if likeCount == 0 {
            self.likeCountLab.isHidden = true
        }else if likeCount < 10 {
            self.likeCountLab.text = YXSquareCommentManager.transformCount(count: Int64(likeCount))
            self.likeCountLab.isHidden = false
        }else{
            self.likeCountLab.text = YXSquareCommentManager.transformCount(count: Int64(likeCount))
            self.likeCountLab.isHidden = false
          
        }
        likeBtn.isHidden = false
        updateLikeUI(likeFlag: likeFlag)
       
    }
    
    private func updateLikeUI(likeFlag:Bool) {
        if likeFlag {
            self.likeCountLab.textColor = QMUITheme().themeTextColor()
            self.likeImageView.image = UIImage(named: "comment_foot_liked")
        }else{
            self.likeCountLab.textColor = QMUITheme().textColorLevel1()
            self.likeImageView.image = UIImage.init(named: "comment_foot_like")
        }
    }
    
    @objc func likeAction(_ sender:UIButton) {
        YXToolUtility.handleBusinessWithLogin { [weak self] in
            guard let `self` = self else { return }
//            if !self.likeFlag {
//                self.likeBtn.isHidden = true
//                let animationView = LOTAnimationView(name: "comment_like")
//                animationView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//                animationView.center = self.likeImageView.center
//                animationView.loopAnimation = false
//                animationView.completionBlock = { [weak self] (_) in
//                    animationView.removeFromSuperview()
//                    self?.likeImageView.isHidden = false
//
//                }
//                self.likeBtn.addSubview(animationView)
//                self.likeImageView.isHidden = true
//
//                animationView.play()
//            }
            self.toolActionBlock?(.like)
        }
    }
    
    @objc func shareAction(_ sender:UIButton) {
        self.toolActionBlock?(.share)
    }
    
    @objc func writeAction(_ sender:UIButton) {
        self.toolActionBlock?(.comment)
    }
}
