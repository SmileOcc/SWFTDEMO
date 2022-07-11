//
//  YXSquareCommentView.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/8.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSquareCommentView: YXCycleViewCell {
    
//    var clickCallBack: ((_ model: YXSquareCommentModel)->())?
    
    var commentModel: YXSquareCommentModel? {
        
        didSet {
            let str = ": "
            
            let text = commentModel?.content ?? ""
            let count = commentModel?.pictures?.count ?? 0
                        
            if text.count == 0 && count == 0 {
                // 没图片和文字
                titleLabel.text = YXLanguageUtility.kLang(key: "no_comment")
            } else {
                let contentNoHtml: String = YXToolUtility.reverseTransformHtmlString(str + text) ?? ""
                let contentMutAttr: NSMutableAttributedString = YXSquareCommentManager.transformAttributeString(text: contentNoHtml, font: UIFont.systemFont(ofSize: 12), textColor: QMUITheme().textColorLevel3())
                                
                let count = commentModel?.pictures?.count ?? 0
                if count > 0 {  //评论里面有图片
                    let emptyStr:String = " "
                    let emptyAttribut:NSAttributedString = NSAttributedString.init(string: emptyStr)
                    
                    let image = UIImage.init(named: "comment_icon_default_WhiteSkin")
                    let btn = YXExpandAreaButton.init(type: .custom, image: image, target: self, action: #selector(self.clickImage(_:)))
                    btn?.expandX = 10
                    btn?.expandY = 10
                    btn?.frame = CGRect.init(x: 0, y: 0, width: 12, height: 12)
                    let attachMent = NSMutableAttributedString.yy_attachmentString(withContent: btn, contentMode: .center, attachmentSize: CGSize(width: 12, height: 12), alignTo: UIFont.systemFont(ofSize: 12), alignment: .center)
                    contentMutAttr.append(emptyAttribut)
                    contentMutAttr.append(attachMent)
                }
                
                titleLabel.attributedText = contentMutAttr
                titleLabel.numberOfLines = 1
            }
            // 头像
            let url = URL.init(string: commentModel?.creator_user?.avatar ?? "")
            self.iconView.sd_setImage(with: url, placeholderImage: UIImage(named: "user_default_photo"), options: .retryFailed, context: nil)
        }
    }
    
    let lineView = UIView.init()
    let iconView = UIImageView.init(image: UIImage(named: "user_default_photo"))

    let titleLabel = YYLabel.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
//        self.layer.cornerRadius = 14.5
//        self.clipsToBounds = true
//        self.backgroundColor = UIColor.qmui_color(withHexString: "#2F79FF")?.withAlphaComponent(0.06)
        
        lineView.backgroundColor = UIColor.qmui_color(withHexString: "#D8D8D8")
        iconView.layer.cornerRadius = 13
        iconView.clipsToBounds = true
//        let control = UIControl.init()
//        control.addTarget(self, action: #selector(self.clickAction(_:)), for: .touchUpInside)
//
//        iconView.image = UIImage(named: "square_comment")
        titleLabel.text = YXLanguageUtility.kLang(key: "no_comment")
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = QMUITheme().textColorLevel3()
        titleLabel.numberOfLines = 1
        
        addSubview(lineView)
        addSubview(iconView)
        addSubview(titleLabel)
//        addSubview(control)
        
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(3)
        }
        
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(46)
            make.right.equalToSuperview().offset(-2)
            make.height.equalTo(30)
        }
        
//        control.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    }

    
//    @objc func clickAction(_ sender: UIButton) {
//
//        guard let model = commentModel else { return }
//
//        self.clickCallBack?(model)
//
//    }
    
    @objc func clickImage(_ sender: UIButton) {
        if let model = commentModel, let list = model.pictures, list.count > 0 {
            XLPhotoBrowser.show(withImages: list, currentImageIndex: 0)
        }
    }
}


class YXSquareScrollerCommentView: UIView {
    
    var clickCallBack: ((_ model: YXSquareCommentModel)->())?
    
    // 必然有值(插入空的)
    var list = [YXSquareCommentModel]() {
        
        didSet {
            var titleArr = [String]()
            if list.count > 0 {
                list.forEach { item in
                    titleArr.append(item.content ?? "")
                }
            } else {
                // 插入空
                let model = YXSquareCommentModel.init()
                list.append(model)
                titleArr.append("")
            }
            
            cycleScrollView.imageURLStringsGroup = titleArr
            cycleScrollView.titlesGroup = titleArr
        }
    }

    lazy var cycleScrollView: YXCycleScrollView = {
        let scrollView = YXCycleScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 34))
        scrollView.backgroundColor = .clear
        scrollView.delegate = self
        scrollView.titleLabelBackgroundColor = .clear
        scrollView.titleLabelTextColor = QMUITheme().textColorLevel1()
        scrollView.titleLabelTextFont = .systemFont(ofSize: 13)
        scrollView.scrollDirection = .vertical
                
        scrollView.showPageControl = false
        scrollView.autoScrollTimeInterval = 3
        scrollView.disableScrollGesture()
        
        return scrollView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        cycleScrollView.delegate = self
        cycleScrollView.autoScroll = true
        cycleScrollView.autoScrollTimeInterval = 2
        
        self.addSubview(cycleScrollView)
        
        cycleScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

extension YXSquareScrollerCommentView: YXCycleScrollViewDelegate {

    func customCollectionViewCellClass(for view: YXCycleScrollView!) -> AnyClass! {
        return YXSquareCommentView.self
    }


    func setupCustomCell(_ cell: UICollectionViewCell!, for index: Int, cycleScrollView view: YXCycleScrollView!) {

        //
//        guard let item = self.list?[index] else { return }

        if let cell = cell as? YXSquareCommentView {
            cell.commentModel = self.list[index]

        }
    }
    
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {
//        guard let item = self.list?[index] else { return }
        let item = self.list[index]
        guard let id = item.post_id, id.count > 0 else { return }
        clickCallBack?(item)
    }
}
