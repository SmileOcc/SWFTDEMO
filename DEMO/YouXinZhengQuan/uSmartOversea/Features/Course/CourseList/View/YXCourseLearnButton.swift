//
//  YXCourseLearnButton.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit
import SnapKit

class YXCourseLearnButton: UIControl {
    var clickBlock: (() -> ())?

    var progess: CGFloat = 0.0 {
        didSet {
           isSelected = progess != 0
        }
    } // 环形进度
    var lineWidth: CGFloat = 2.0 // 环形的宽
    private var foreLayer: CAShapeLayer? // 进度条的layer层（可做私有属性）
    
    lazy var image: QMUIButton = {
        let image = QMUIButton()
        image.contentEdgeInsets = UIEdgeInsets.zero
        image.isUserInteractionEnabled = false
        let selectIamge = UIImage.init(named: "course_progress_normal")
        image.setImage(selectIamge, for: .selected)
        return image
    }()
    
    override var isSelected: Bool {
        didSet {
            image.isSelected = isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(image)
        image.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawProgess()
    }
    
    func drawProgess() {

            let rect = self.bounds
            let shapeLayer: CAShapeLayer = CAShapeLayer()

            shapeLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
            shapeLayer.lineWidth = self.lineWidth
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor.themeColor(
                withNormal: UIColor.qmui_color(withHexString: "#EAEAEA")!,
                andDarkColor: UIColor.qmui_color(withHexString: "#D3D4E6")!
            ).cgColor

            let center: CGPoint = CGPoint(x: rect.size.width/2, y: rect.size.height/2)
            let bezierPath: UIBezierPath = UIBezierPath(arcCenter: center, radius: (rect.size.width - self.lineWidth)/2, startAngle: CGFloat(-0.5 * Double.pi), endAngle: CGFloat(1.5 * Double.pi), clockwise: true)
            shapeLayer.path = bezierPath.cgPath
            self.layer.addSublayer(shapeLayer)

            let layer = CALayer()
            layer.frame = self.bounds
            layer.backgroundColor = QMUITheme().mainThemeColor().cgColor // UIColor(hexString: "FF8B00")!.cgColor
            self.layer.addSublayer(layer)


            self.foreLayer = CAShapeLayer()
            self.foreLayer?.frame = self.bounds
            self.foreLayer?.fillColor = UIColor.clear.cgColor
            self.foreLayer?.lineWidth = self.lineWidth
            self.foreLayer?.strokeColor = QMUITheme().mainThemeColor().cgColor //UIColor.red.cgColor
            self.foreLayer?.strokeEnd = progess
            self.foreLayer?.lineCap = .round
            self.foreLayer?.path = bezierPath.cgPath
            layer.mask = self.foreLayer
            
        }
    
    func setProgress(value: CGFloat) -> Void {
        progess = value // 设置当前属性的值
        self.foreLayer?.strokeEnd = progess
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        clickBlock?()
    }
}
