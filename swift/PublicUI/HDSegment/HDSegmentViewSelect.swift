//
//  HDSegmentViewSelect.swift
//  HDPublicUIProject
//
//  Created by MountainZhu on 2020/7/20.
//  Copyright © 2020 航电. All rights reserved.
//

//使用方法
//let titleView = HDSegmentViewSelect.init(frame
//titleView.dataSource = self
//titleView.delegate = self

import UIKit

public class HDSegmentViewSelectStyle: NSObject {
    //默认颜色
    public var normalColor: UIColor = .black
    //选中颜色
    public var selectColor: UIColor = .orange
    //文字大小
    public var fontSize: CGFloat = .scaleW(15)
    //移动高度
    public var mobileLineHeight: CGFloat = .scaleW(2)
    //移动线颜色
    public var mobileLineColor: UIColor = .orange
    //是否显示移动线
    public var isShowMobileLine: Bool = true
    //额外间距
    public var itemMargin: CGFloat = .scaleW(30)
    //title height
    public var titleHeight: CGFloat = .scaleW(44)
    
    //底部高度
    public var bottomLineHeight: CGFloat = 0.5
    //底部线颜色
    public var bottomLineColor: UIColor = .lightGray
    //是否显示底部线
    public var isShowBottomLine: Bool = true
}

public protocol HDSegmentViewSelectDelegate: NSObjectProtocol {
    func titleView(_ titleView: HDSegmentViewSelect, index: Int)
}

public protocol HDSegmentViewSelectDataSource : NSObjectProtocol {
    
    //返回个数
    func numberOfItems(in titleView: HDSegmentViewSelect) -> Int
    
    //返回当前需要显示的文字
    func titleView(_ titleView: HDSegmentViewSelect, titleForItemAt index: Int) -> NSString?
}

public class HDSegmentViewSelect: UIView {
    public var dataSource: HDSegmentViewSelectDataSource? {
        set {
            _dataSource = newValue
            if newValue == nil {return}
            reloadData()
        }
        get {
            return _dataSource
        }
    }
    
    public weak var delegate: HDSegmentViewSelectDelegate?
    public var _dataSource: HDSegmentViewSelectDataSource?
    public var clickIndexBlock:((Int) -> ())?
    
    private var style: HDSegmentViewSelectStyle?
    private var isScrollEnable: Bool = true //如果大于5个为true 反之
    private lazy var currentIndex: Int = 0
    private lazy var titleLabels: [UILabel] = [UILabel]()
    private var viewsArray = [UIView]()
    private var count = 0 // 记录个数
    
    //移动线
    private lazy var mobileLine: UIView = {
        let mobileLine = UIView()
        return mobileLine
    }()
    
    //底部线
    private lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.frame = CGRect.init(x: 0, y: self.bounds.size.height, width: self.bounds.size.width, height: 0)
        return bottomLine
    }()
    
    //设置移动线样式
    private func setBottomLineStyle() {
        bottomLine.isHidden = self.style?.isShowBottomLine == true ? false : true
        bottomLine.backgroundColor = self.style?.bottomLineColor
        bottomLine.frame.origin.y = self.frame.size.height-(self.style?.bottomLineHeight ?? 0)
        bottomLine.frame.size.height = (self.style?.bottomLineHeight ?? 0)
    }
    
    //设置移动线样式
    private func setMobileLineStyle() {
        mobileLine.backgroundColor = self.style?.mobileLineColor
        mobileLine.frame.size.height = self.style?.mobileLineHeight ?? 0
        mobileLine.frame.origin.y = self.bounds.height - (self.style?.mobileLineHeight ?? 0)
    }
    
    private lazy var titleScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        return scrollView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        style = HDSegmentViewSelectStyle()
        addSubview(bottomLine)
        backgroundColor = UIColor.white
        titleScrollView.addSubview(mobileLine)
        addSubview(titleScrollView)
        refreshStyle(style!)
    }
    
    convenience init(frame: CGRect, style: HDSegmentViewSelectStyle? = nil) {
        self.init(frame: frame)
        if style != nil {
            self.style = style!
            refreshStyle(style!)
        }
    }

    public func refreshStyle(_ style:HDSegmentViewSelectStyle) {
        self.style = style
        setMobileLineStyle()
        setBottomLineStyle()
        refreshTitleLabelsStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    public func reloadData() {
        mobileLine.isHidden = !(style?.isShowMobileLine ?? true)
        guard let dataSource = dataSource else { return }
        count = dataSource.numberOfItems(in: self)
        if count <= 0 {return}
        setupTitleLabels()
    }

    private func setupTitleLabels() {
        for view in titleScrollView.subviews {
            if view != mobileLine && view != bottomLine {
                view.removeFromSuperview()
            }
        }
        
        titleLabels.removeAll()
        for i in 0..<count {
            let titleLabel = UILabel()
            let title = dataSource?.titleView(self, titleForItemAt: i)
            titleLabel.text = title as String?
            titleLabel.tag = i
            titleLabel.textAlignment = .center
            titleLabel.backgroundColor = UIColor.clear
            titleScrollView.addSubview(titleLabel)
            titleLabels.append(titleLabel)
            
            titleLabel.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(titleLabelClick(_:)))
            titleLabel.addGestureRecognizer(tapGes)
        }
        refreshTitleLabelsStyle()
        setupTitleLabelsFrame()
    }

    private func refreshTitleLabelsStyle() {
        for (i, titleLabel) in titleLabels.enumerated() {
            titleLabel.font = UIFont.systemFont(ofSize: style?.fontSize ?? .scaleW(15))
            titleLabel.textColor = i == currentIndex ? style?.selectColor : style?.normalColor
        }
    }

    private func setupTitleLabelsFrame() {
        for i in 0..<count {
            let label = titleLabels[i]
            var w: CGFloat = 0
            let h: CGFloat = bounds.height
            var x: CGFloat = 0
            let y: CGFloat = 0
            if count > 5 {
                isScrollEnable = true
                let title = dataSource?.titleView(self, titleForItemAt: i)
                w = getStringWidth(title! as String, height: self.bounds.height, font: self.style?.fontSize ?? .scaleW(15))
                if i == 0 {
                    x = (style?.itemMargin ?? 0)/2.0
                    
                } else {
                    let preLabel = titleLabels[i - 1]
                    x = preLabel.frame.maxX + (style?.itemMargin ?? 0)
                }
            } else {
                isScrollEnable = false
                w = bounds.width / CGFloat(count)
                x = w * CGFloat(i)
            }
            
            if i == currentIndex && style?.isShowMobileLine == true {
                mobileLine.frame.origin.x = x
                mobileLine.frame.size.width = w
            }
            label.frame = CGRect(x: x, y: y, width: w, height: h)
        }
        
        titleScrollView.contentSize = isScrollEnable ? CGSize(width: titleLabels.last!.frame.maxX + (style?.itemMargin ?? 0)/2.0, height: 0) : CGSize.zero
        if currentIndex != 0 {
            setMobileLineoX(currentIndex, false)
        }
    }
    
    @objc fileprivate func titleLabelClick( _ tapGes: UITapGestureRecognizer) {
        let targetLabel = tapGes.view as! UILabel
        modifyFrame(targetLabel.tag)
        /// 通过代理方法传递出去
        delegate?.titleView(self, index: currentIndex)
        if clickIndexBlock != nil {
            clickIndexBlock!(currentIndex)
        }
    }

    func modifyFrame(_ index: Int) {
        let targetLabel = titleLabels[index]
        adjustTitleLabel(targetIndex: targetLabel.tag)
        //buttomLine
        if style?.isShowMobileLine == true {
            UIView.animate(withDuration: 0.25) {
                self.mobileLine.frame.origin.x = targetLabel.frame.origin.x
                self.mobileLine.frame.size.width = targetLabel.frame.width
            }
        }
    }
    
    private func adjustTitleLabel(targetIndex: Int){
        if targetIndex == currentIndex { return }
        let targetLabel = titleLabels[targetIndex]
        let sourceLabel = titleLabels[currentIndex]
        sourceLabel.textColor = style?.normalColor
        targetLabel.textColor = style?.selectColor
        currentIndex = targetIndex
        setMobileLineoX(targetIndex)
    }
    
    //修改移动线位置
    private func setMobileLineoX(_ targetIndex: Int,_ animated: Bool? = nil) {
        let targetLabel = titleLabels[targetIndex]
        //adjust position
        if isScrollEnable {
            var offsetX  = targetLabel.center.x - titleScrollView.bounds.width * 0.5
            if offsetX < 0 {
                offsetX = 0
            }
            if offsetX > titleScrollView.contentSize.width - titleScrollView.bounds.width {
                offsetX = titleScrollView.contentSize.width - titleScrollView.bounds.width
            }
            titleScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated == nil ? true : animated!)
        }
    }
    
    //计算文字宽带
    private func getStringWidth(_ text: String, height : CGFloat, font: CGFloat) -> CGFloat {
        let rect = text.boundingRect(with: CGSize.init(width: 1000, height: height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font)], context: nil)
        return rect.size.width
    }
}

