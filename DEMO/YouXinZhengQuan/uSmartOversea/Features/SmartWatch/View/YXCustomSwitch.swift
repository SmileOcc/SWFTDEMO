//
//  YXCustomSwitch.swift
//  CustomSwitch
//
//  Created by youxin on 2019/3/28.
//  Copyright © 2019年 hyku. All rights reserved.
//

import UIKit


typealias YXSwitchValueChange = (_ value: Bool) -> ()

struct YXSwitchConfig {
    /// 关闭背景颜色
    var offBgColor = UIColor.qmui_color(withHexString: "#E8EBFB") ?? .white
    /// 打开背景颜色
    var onBgColor = UIColor.qmui_color(withHexString: "#E8EBFB") ?? .white
    
    /// 关闭圆点颜色    
    var offPointColor = UIColor.qmui_color(withHexString: "#B7B7B7") ?? .white
    /// 打开圆点颜色
    var onPointColor = (QMUITheme().themeTextColor())
    
    /// 关闭圆点颜色
    var offShadowColor =  UIColor.qmui_color(withHexString: "#B7B7B7") ?? .white
    /// 打开圆点颜色    
    var onShadowColor = UIColor.qmui_color(withHexString: "#6F8DCF") ?? .white
    
    /// 背景View的上下边距
    var bgHeight: CGFloat = 12
    
    /// 圆点的上下边距
    var pointHeight: CGFloat = 15
    
    var animateDuration: Double = 0.3
}

@IBDesignable
class YXCustomSwitch: UIControl {

    //#MARK: Properties
    var valueChangeHandle: YXSwitchValueChange?
    private var lineLayer = CAShapeLayer()
    private var pointerLayer = CAShapeLayer()
    var config: YXSwitchConfig! {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    fileprivate var animateDuration = 0
    //set on without animated
    var isOn: Bool {
        set {
            on = newValue
            switchValueChanged(false)
        }
        
        get {
            on
        }
    }
    
    private var on: Bool = false
    
    //MARK: Event trigger method
    
    //setOn  can with animated
    final func setOn(_ on: Bool, animate: Bool = true) {
        guard on != isOn else { return }
        self.on = on
        switchValueChanged(animate)
        
    }
    
    fileprivate func switchValueChanged(_ animated: Bool) {
        
        valueChangeHandle?(isOn)
        sendActions(for: UIControl.Event.valueChanged)
        
        let lineFillColor = self.lineFillColor(isOn)
        let pointerFillColor = self.pointerFillColor(isOn)
        let pointerShadowColor = self.pointerShadowColor(isOn)
        
        if animated {
            pointerLayer.add(self.createKeyframeAniamtionWithValue(), forKey: "MovePointer")
            UIView.animate(withDuration: self.config.animateDuration) {
                self.lineLayer.fillColor = lineFillColor
                self.pointerLayer.fillColor = pointerFillColor
                self.pointerLayer.shadowColor = pointerShadowColor
            }
        } else {
            pointerLayer.path = pointerBeginPath(isOn).cgPath
            self.lineLayer.fillColor = lineFillColor
            self.pointerLayer.fillColor = pointerFillColor
            self.pointerLayer.shadowColor = pointerShadowColor
        }
    }
    
    //MARK: initialization method
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect =  CGRect(x: 0, y: (self.bounds.height - self.config.bgHeight)/2.0, width: self.bounds.width, height: self.config.bgHeight)
        lineLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: self.config.bgHeight/2.0).cgPath
        pointerLayer.path = pointerBeginPath(isOn).cgPath
        lineLayer.fillColor = lineFillColor(isOn)
        pointerLayer.fillColor = pointerFillColor(isOn)
        pointerLayer.shadowColor =  pointerShadowColor(isOn)
    }
    
    convenience public init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    fileprivate func setUpView() {
        self.addTarget(self, action: #selector(clickSwitch), for: UIControl.Event.touchUpInside)
        self.config = YXSwitchConfig()
        self.layer.addSublayer(lineLayer)
        self.layer.addSublayer(pointerLayer)
        
        pointerLayer.shadowOffset = CGSize(width: 0, height: 2);
        pointerLayer.shadowOpacity = 1;
        pointerLayer.shadowRadius = 4;
    }
    
    @objc func clickSwitch() {
        on = !on
        switchValueChanged(true)
    }
}

extension YXCustomSwitch {
    func createKeyframeAniamtionWithValue() -> CAAnimation {
        let keyframeAnimation = CAKeyframeAnimation(keyPath: "path")
        var values: [Any]
        if isOn {
            values = [self.switchLeftPath.cgPath, self.switchMiddlePath.cgPath, self.switchRightPath.cgPath]
        } else {
            values = [self.switchRightPath.cgPath, self.switchMiddlePath.cgPath, self.switchLeftPath.cgPath]
        }
        keyframeAnimation.values = values;
        keyframeAnimation.duration = self.config.animateDuration
        keyframeAnimation.keyTimes = [NSNumber(value: 0), NSNumber(value: 1.0 / 2.0), NSNumber(value: 1)]
        keyframeAnimation.isRemovedOnCompletion = false
        keyframeAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        return keyframeAnimation
    }
    
    var switchLeftPath: UIBezierPath {
        let rect = CGRect(x: 0, y: (self.bounds.height - self.config.pointHeight)/2.0, width: self.config.pointHeight, height: self.config.pointHeight)
        return UIBezierPath(roundedRect: rect, cornerRadius: self.config.pointHeight/2.0)
    }
    
    var switchMiddlePath: UIBezierPath {
        let scale: CGFloat = 0.8
        let rect = CGRect(x: (self.bounds.width - self.config.pointHeight * scale)/2.0, y: (self.bounds.height - self.config.pointHeight * scale)/2.0, width: self.config.pointHeight * scale , height: self.config.pointHeight * scale)
        return UIBezierPath(roundedRect: rect, cornerRadius: self.config.pointHeight/2.0)
    }
    
    var switchRightPath: UIBezierPath {
        let rect = CGRect(x: self.bounds.width - self.config.pointHeight, y: (self.bounds.height - self.config.pointHeight)/2.0, width: self.config.pointHeight, height: self.config.pointHeight)
        return UIBezierPath(roundedRect: rect, cornerRadius: self.config.pointHeight/2.0)
    }
    
    func bubblePosition(_ isOn :Bool) -> CGPoint{
        let pointH = self.config.pointHeight
       
        if isOn{
            return CGPoint(x: self.bounds.width - pointH, y: 0)
        }else{
            return CGPoint(x: 0, y: 0)
        }
    }
    
    func pointerFillColor(_ isOn: Bool)-> CGColor {
        if isOn {
            return self.config.onPointColor.cgColor
        }
        else{
            return self.config.offPointColor.cgColor
        }
    }
    
    func pointerShadowColor(_ isOn: Bool)-> CGColor {
        if isOn {
            return self.config.onShadowColor.cgColor
        }
        else{
            return self.config.offShadowColor.cgColor
        }
    }
    
    func lineFillColor(_ isOn: Bool)-> CGColor {
        if isOn {
            return self.config.onBgColor.cgColor
        }
        else{
            return self.config.offBgColor.cgColor
        }
    }
    
    func pointerBeginPath(_ isOn: Bool)-> UIBezierPath {
        var rect = CGRect.zero
        if isOn {
           rect = CGRect(x: self.bounds.width - self.config.pointHeight, y: (self.bounds.height - self.config.pointHeight)/2.0, width: self.config.pointHeight, height: self.config.pointHeight)
        }
        else{
            rect = CGRect(x: 0, y: (self.bounds.height - self.config.pointHeight)/2.0, width: self.config.pointHeight, height: self.config.pointHeight)
        }
        return UIBezierPath(roundedRect: rect, cornerRadius: self.config.pointHeight/2.0)
    }
}
