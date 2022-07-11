//
//  YXStockCornerShadowView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/8/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

@IBDesignable


class YXStockCornerShadowView: UIView {
    // MARK: - IBOutlet
    
    // MARK: - properties
    @IBInspectable
    public var topLeft: Bool = false{
        didSet{
            redraw()
        }
    }
    
    @IBInspectable
    public var bottomLeft: Bool = false{
        didSet{
            redraw()
        }
    }
    
    @IBInspectable
    public var topRight: Bool = false{
        didSet{
            redraw()
        }
    }
    
    @IBInspectable
    public var bottomRight: Bool = false{
        didSet{
            redraw()
        }
    }
    
    @IBInspectable
    public var cornerRadius: CGFloat = 10{
        didSet{
            redraw()
        }
    }
    @IBInspectable
    public var shadowOffset: CGSize = .zero{
        didSet{
            redraw()
        }
    }
    @IBInspectable
    public var shadowRadius: CGFloat = 0{
        didSet{
            redraw()
        }
    }
    @IBInspectable
    public var shadowColor: UIColor = .black{
        didSet{
            redraw()
        }
    }
    @IBInspectable
    public var fillColor: UIColor = QMUITheme().foregroundColor(){
        didSet{
            redraw()
        }
    }
    @IBInspectable
    public var margins: UIEdgeInsets = .zero{
        didSet{
            redraw()
        }
    }
    
    // MARK: - initial method
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        var corners: UIRectCorner = []
        if topLeft {
            corners.insert(.topLeft)
        }
        if bottomLeft {
            corners.insert(.bottomLeft)
        }
        if topRight {
            corners.insert(.topRight)
        }
        if bottomRight {
            corners.insert(.bottomRight)
        }
        
        
        if self.shadowRadius > 0 {
            //绘制阴影
            let shadowPath = UIBezierPath(roundedRect: rect.inset(by: self.margins), byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            
            let context = UIGraphicsGetCurrentContext()
            context?.setShadow(offset: self.shadowOffset, blur: shadowRadius, color: shadowColor.cgColor)
            fillColor.setFill()
            shadowPath.fill()
        }
        
        //绘制mask
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        maskLayer.frame = rect
        layer.mask = maskLayer
    }
    
    // MARK: - lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: - private method
    fileprivate func redraw(){
        setNeedsDisplay()
        if shadowRadius > 0 {
            backgroundColor = UIColor.clear
        }
    }
}


class YXStockDetailPopBtn: QMUIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        
        didSet {
            super.isSelected = isSelected
//            if self.isSelected {
//                self.layer.borderColor = QMUITheme().textColorLevel1().cgColor
//                self.backgroundColor = .white
//            } else {
//                self.backgroundColor = UIColor.qmui_color(withHexString: "#F4F4F4")
//                self.layer.borderColor = UIColor.clear.cgColor
//            }
        }
    }
    
    func setUI(){
        self.layer.cornerRadius = 2.0
        self.layer.masksToBounds = true
        self.layer.borderColor = QMUITheme().pointColor().cgColor
        self.layer.borderWidth = 1.0
        self.setTitle("1", for: .normal)
        self.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        self.setTitleColor(QMUITheme().textColorLevel1(), for: .selected)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
}
