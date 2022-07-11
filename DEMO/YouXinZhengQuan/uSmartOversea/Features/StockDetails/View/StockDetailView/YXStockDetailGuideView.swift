//
//  YXStockDetailGuideView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

enum YXGuideViewType {
    // 原样展示
    case origin
    // 高亮展示
    case needHighLight
}

class YXStockDetailGuideView: UIView {

    var step: Int = 0
    var parentView: UIView!
    var titles: [String] = []
    var highLightViews: [UIView] = []
    var higLightViewTypes: [YXGuideViewType]?
    var edgeInsets: UIEdgeInsets = UIEdgeInsets.zero
    var completion: (() -> Void)?
    
    var isUp = true

    func layoutPageGuide(highLightView: UIView, title: String, type: YXGuideViewType = .needHighLight) {
        let frame = highLightView.convert(highLightView.bounds, to: parentView).inset(by: edgeInsets)
        
        if frame.minY < 250 {
            self.isUp = false
        } else {
            self.isUp = true
        }
        
        arrowLayer = creatArrowLayer()
        guideLabel = createGuideLabel()
        self.layer.addSublayer(arrowLayer)
        self.addSubview(guideLabel)

        let bgPath = UIBezierPath(rect: self.bounds)
        
        if type == .needHighLight {
            let reversingPath = UIBezierPath(roundedRect: frame, cornerRadius: 4.0).reversing()
            bgPath.append(reversingPath)
            
        }else {
            highLightView.isHidden = false
        }
        
        self.bgLayer.path = bgPath.cgPath
        guideLabel.text = title

        if self.isUp {
            arrowLayer.position = CGPoint(x: frame.minX + frame.width / 2.0, y: frame.minY - arrowLayer.frame.height / 2.0)
        } else {
            arrowLayer.position = CGPoint(x: frame.minX + frame.width / 2.0, y: frame.maxY + 5 + arrowLayer.frame.height / 2.0)
        }
        
        
        var isLeft = true
        if frame.midX > (UIScreen.main.bounds.size.width * 0.5) {
            isLeft = false
        }
        
        guideLabel.snp.makeConstraints { (make) in
            
            if isLeft {
                make.left.equalToSuperview().offset(16)
                make.right.lessThanOrEqualToSuperview().offset(-16)
            } else {
                make.right.equalToSuperview().offset(-16)
                make.left.greaterThanOrEqualToSuperview().offset(16)
            }
            
            if self.isUp {
                make.bottom.equalToSuperview().offset(-(self.frame.height - frame.minY + arrowLayer.frame.height))
            } else {
                make.top.equalToSuperview().offset(arrowLayer.frame.maxY)
            }
        }
    }

    func showPageGuide(step: Int, completion: (() -> Void)?) {

        self.completion = completion
        guard self.step < titles.count, self.step < highLightViews.count else {
//            hidePageGuide()
            return
        }

//        if step > 0 {
//            self.hidePageGuide()
//        }
        if let types = higLightViewTypes {
            for (index, type) in types.enumerated() {
                if type == .origin {
                    highLightViews[index].isHidden = true
                }
            }
        }
        
        if let types = higLightViewTypes {
            self.layoutPageGuide(highLightView: self.highLightViews[self.step], title: self.titles[self.step], type: types[self.step])
        }else {
            self.layoutPageGuide(highLightView: self.highLightViews[self.step], title: self.titles[self.step])
        }
        
    }

    func resetPageGuide() {
        arrowLayer.removeFromSuperlayer()
        guideLabel.removeFromSuperview()
        showPageGuide(step: self.step, completion: self.completion)
    }

    convenience init(parentView: UIView) {
        self.init(frame: .zero, parentView: parentView)
    }

    init(frame: CGRect, parentView: UIView) {
        super.init(frame: frame)
        parentView.addSubview(self)
        self.frame = parentView.bounds
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(clickControl)
        clickControl.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        self.layer.addSublayer(bgLayer)
    }

    lazy var clickControl: UIControl = {
        let control = UIControl()
        control.addTarget(self, action: #selector(hidePageGuide), for: .touchUpInside )
        return control
    }()

    @objc func hidePageGuide() {

        if self.step >= self.titles.count - 1 {
            self.removeFromSuperview()
            self.isHidden = true
            self.completion?()
            return
        }

        arrowLayer.removeFromSuperlayer()
        guideLabel.removeFromSuperview()
        self.step += 1
        showPageGuide(step: self.step, completion: self.completion)
    }

    var guideLabel: QMUILabel = QMUILabel()
    func createGuideLabel() -> QMUILabel {
        let label = QMUILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = QMUITheme().holdMark()
        label.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }

    lazy var bgLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.black.withAlphaComponent(0.4).cgColor
        return layer
    }()

    var arrowLayer: CALayer = CALayer()
    func creatArrowLayer() -> CALayer {
        let layer = CALayer()

        let circleWH: CGFloat = 11
        let innerCircleWH: CGFloat = 6
        let lineH: CGFloat = 40
        let lineW: CGFloat = 2
        let bottomMargin: CGFloat = 5.0
        layer.frame = CGRect(x: 0, y: 0, width: circleWH, height: circleWH + lineH + bottomMargin)

        if isUp {
            let lineLayer = CALayer()
            lineLayer.frame = CGRect(x: (circleWH - lineW) / 2.0, y: 0, width:lineW, height: lineH)
            lineLayer.backgroundColor = QMUITheme().holdMark().cgColor
            layer.addSublayer(lineLayer)

            let circleLayer = CAShapeLayer()
            circleLayer.frame = CGRect(x: 0, y: lineH, width: circleWH, height: circleWH)
            circleLayer.borderWidth = 1.0
            circleLayer.borderColor = QMUITheme().holdMark().cgColor
            circleLayer.backgroundColor = UIColor.white.cgColor
            circleLayer.cornerRadius = circleWH / 2.0
            layer.addSublayer(circleLayer)

            let subLayer = CALayer()
            let insetXY: CGFloat = (circleWH - innerCircleWH) / 2.0
            subLayer.frame = CGRect(x: insetXY, y: insetXY, width: innerCircleWH, height: innerCircleWH)
            subLayer.backgroundColor = QMUITheme().holdMark().cgColor
            subLayer.cornerRadius = innerCircleWH / 2.0
            circleLayer.addSublayer(subLayer)
            
        } else {
            let circleLayer = CAShapeLayer()
            circleLayer.frame = CGRect(x: 0, y: 0, width: circleWH, height: circleWH)
            circleLayer.borderWidth = 1.0
            circleLayer.borderColor = QMUITheme().holdMark().cgColor
            circleLayer.backgroundColor = UIColor.white.cgColor
            circleLayer.cornerRadius = circleWH / 2.0
            layer.addSublayer(circleLayer)

            let subLayer = CALayer()
            let insetXY: CGFloat = (circleWH - innerCircleWH) / 2.0
            subLayer.frame = CGRect(x: insetXY, y: insetXY, width: innerCircleWH, height: innerCircleWH)
            subLayer.backgroundColor = QMUITheme().holdMark().cgColor
            subLayer.cornerRadius = innerCircleWH / 2.0
            circleLayer.addSublayer(subLayer)
            
            let lineLayer = CALayer()
            lineLayer.frame = CGRect(x: (circleWH - lineW) / 2.0, y: circleWH, width:lineW, height: lineH)
            lineLayer.backgroundColor = QMUITheme().holdMark().cgColor
            layer.addSublayer(lineLayer)
        }
        
        return layer
    }

}

