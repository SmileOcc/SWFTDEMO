//
//  YXSquareHotDscussionCell.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

extension String {
    var reportStock: YXStockInputModel? {
        if let from = range(of: "(", options: .backwards), let to = range(of: ")", options: .backwards), let first = range(of: "$") {
            let str = self[from.upperBound ..< to.lowerBound]
            let secu = YXStockInputModel()
            secu.name = String(self[first.upperBound ..< from.lowerBound])
            let stockItems = str.components(separatedBy: ".")
            let market = stockItems.last?.lowercased() ?? ""
            var symbol = ""
            for (index, item) in stockItems.enumerated() {
                if index < stockItems.count - 1 {
                    symbol.append(item)
                    if index != stockItems.count - 2 {
                        symbol.append(".")
                    }
                }
            }
            secu.market = market
            secu.symbol = symbol
            return secu
        }
        return nil
    }
}

class YXSquareHotDscussionSubView: UIView {
    
    let label = YYLabel.init()
    
    let lineView = UIView.line()
    
    let bgView = UIView()
    
    var item: YXHotDiscussionModel? {
        didSet {
//            label.text = item?.content

            
            guard let item = item else {
                label.text = ""
                return
            }
            //富文本内容
            item.content = item.content.replacingOccurrences(of: "\n", with: " ")
            let contentNoHtml: String = YXToolUtility.reverseTransformHtmlString(item.content) ?? ""
            let contentMutAttr: NSMutableAttributedString = YXSquareCommentManager.transformAttributeString(text: contentNoHtml, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1())
            let textParser = YXReportTextParser()
            textParser.font = UIFont.systemFont(ofSize: 14)
            textParser.parseText(contentMutAttr, selectedRange: nil)
            
            
            if item.pictures.count > 0 {  //评论里面有图片
                let emptyStr:String = " "
                let emptyAttribut:NSAttributedString = NSAttributedString.init(string: emptyStr)
                
                let image = UIImage.init(named: "comment_icon_default_WhiteSkin")
                let btn = YXExpandAreaButton.init(type: .custom, image: image, target: self, action: #selector(self.clickImage(_:)))
                btn?.expandX = 10
                btn?.expandY = 10
                btn?.frame = CGRect.init(x: 0, y: 0, width: 12, height: 12)
                let attachMent = NSMutableAttributedString.yy_attachmentString(withContent: btn, contentMode: .center, attachmentSize: CGSize(width: 14, height: 14), alignTo: UIFont.systemFont(ofSize: 12), alignment: .center)
                contentMutAttr.append(emptyAttribut)
                contentMutAttr.append(attachMent)
            }
            
            contentMutAttr.yy_lineSpacing = 5
            label.attributedText = contentMutAttr
            label.numberOfLines = 2
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        bgView.layer.cornerRadius = 13
        bgView.clipsToBounds = true
        bgView.backgroundColor = QMUITheme().foregroundColor()
        
        label.textContainerInset = UIEdgeInsets.init(top: 0, left: 12, bottom: 0, right: 12)
        label.numberOfLines = 1
        label.highlightTapAction = { (containerView, text, range ,rect) in
            let string = (text.string as NSString).substring(with: range)
            if let stock = string.reportStock {
                YXSquareManager.getTopService()?.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [stock], "selectIndex" : 0])
            }
        }
        
        addSubview(bgView)
        bgView.addSubview(label)
        
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
        }
                
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    @objc func clickAction() {
        if let item = item {
            YXUGCCommentManager.gotoStockCommentDetail(cid: item.post_id)
        }
       
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        clickAction()
    }
    
    @objc func clickImage(_ sender: UIButton) {
        if let model = item, model.pictures.count > 0 {
            XLPhotoBrowser.show(withImages: model.pictures, currentImageIndex: 0)
        }
    }
}

class YXSquareHotDscussionCell: UICollectionViewCell {
    
    deinit {
        if timerFlag > 0 {
            YXTimerSingleton.shareInstance().invalidOperation(withFlag: timerFlag)
        }
    }
    
    var index = 0
    
    let maxCount: Int = 3
    let itemHeight: CGFloat = 34
    
    var list: [YXHotDiscussionModel]? {
        didSet {
            if timerFlag > 0 {
                YXTimerSingleton.shareInstance().invalidOperation(withFlag: timerFlag)
                timerFlag = 0
            }
            if let list = list, list.count > 0 {
                for (index, item) in list.enumerated() {
                    let view = YXSquareHotDscussionSubView.init()
                    view.item = item
                    view.frame = CGRect.init(x: 0, y: CGFloat(index) * itemHeight, width: YXConstant.screenWidth, height: itemHeight)
                    cycleScrollView.addSubview(view)
                }
                
                if list.count > maxCount {
                    // 再添加三条(无限轮询)
                    let arr = list[..<maxCount]
                    for (index, item) in arr.enumerated() {
                        let view = YXSquareHotDscussionSubView.init()
                        view.item = item
                        view.frame = CGRect.init(x: 0, y: CGFloat(index + list.count) * itemHeight, width: YXConstant.screenWidth, height: itemHeight)
                        cycleScrollView.addSubview(view)
                    }
                    self.index = 0
                    self.cycleScrollView.contentOffset = CGPoint.zero
                    
                    timerFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] flag in
                        guard let `self` = self else { return }
                        self.index += 1;
                        
                        UIView.animate(withDuration: 0.3) {
                            self.cycleScrollView.contentOffset = CGPoint.init(x: 0, y: CGFloat(self.index) * self.itemHeight)
                        } completion: { [weak self] _ in
                            guard let `self` = self else { return }
                            let index = Int(self.cycleScrollView.contentOffset.y / self.itemHeight)
                            self.index = index
                            if self.index >= list.count {
                                // 最后一个
                                self.index = 0
                                self.cycleScrollView.contentOffset = CGPoint.zero
                            }
                        }
                    }, timeInterval: 2, repeatTimes: Int.max, atOnce: false)
                    
                    let count = list.count > maxCount ? maxCount : list.count
                    self.cycleScrollView.contentSize = CGSize.init(width: cycleScrollView.bounds.size.width, height: CGFloat(count) * itemHeight)
                }
            }
        }
    }
    
    var timerFlag: YXTimerFlag = 0
    
    typealias ShowMoreBlock = () -> Void
    var showMoreBlock: ShowMoreBlock?
    
    lazy var cycleScrollView: UIScrollView = {
        let scrollView = UIScrollView.init(frame: .zero)
        scrollView.backgroundColor = .clear
        scrollView.isScrollEnabled = false
        scrollView.clipsToBounds = true
        return scrollView
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        contentView.addSubview(cycleScrollView)

        cycleScrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
    }
}
