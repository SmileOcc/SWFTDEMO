//
//  YXProgressSliderBar.swift
//  uSmartEducation
//
//  Created by usmart on 2022/2/17.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

enum YXProgressSliderBarEventType {
    case touchesBegan
    case touchesMoved
    case touchesEnded
}

class YXProgressSliderBar: UIControl {
    
    var beginTouch: Bool = false
    var beginPoint: CGPoint?
    var beginValue: Float = 0
    
    var touchEventBlock: ((YXProgressSliderBarEventType,Float)->Void)?
    
    private let normalSliderHeight: CGFloat = 6
    private let selectedSliderHeight: CGFloat = 8
    
    
    lazy var slider: UISlider = {
        let s = UISlider()
        s.qmui_thumbSize = CGSize(width: 1, height: normalSliderHeight)
//        s.thumbColor = QMUITheme().mainThemeColor()
        s.qmui_trackHeight = normalSliderHeight
        s.isUserInteractionEnabled = false
//        s.tintColor = QMUITheme().mainThemeColor()
//        s.maximumTrackTintColor = QMUITheme().mainThemeColor().withAlphaComponent(0.3)
        return s
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(slider)
        slider.snp.makeConstraints { make in
            make.height.equalTo(normalSliderHeight)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(-2)
            make.right.equalToSuperview().offset(2)
        }
    }
    
    func setValue(_ value: Float, animated: Bool) {
        if beginTouch {
            return
        }
        if value > 1 {
            return
        }
        self.slider.setValue(value, animated: animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        beginTouch = true
        for touch: AnyObject in touches {
            let t:UITouch = touch as! UITouch
            beginValue = self.slider.value
            beginPoint = t.location(in: self)
        }
        slider.qmui_trackHeight = selectedSliderHeight
        slider.qmui_thumbSize = CGSize(width: 1, height: selectedSliderHeight)
        slider.snp.updateConstraints { make in
            make.height.equalTo(selectedSliderHeight)
        }
        touchEventBlock?(YXProgressSliderBarEventType.touchesBegan,slider.value)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        slider.qmui_trackHeight = normalSliderHeight
        slider.qmui_thumbSize = CGSize(width: 1, height: normalSliderHeight)
        beginTouch = false
        slider.snp.updateConstraints { make in
            make.height.equalTo(normalSliderHeight)
        }
        touchEventBlock?(YXProgressSliderBarEventType.touchesEnded,slider.value)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let t:UITouch = touch as! UITouch
            if let beginPoint = beginPoint {
                let offsetX = t.location(in: self).x - beginPoint.x
                let value = beginValue+Float(offsetX/YXConstant.screenWidth)
                slider.setValue(value, animated: true)
                touchEventBlock?(YXProgressSliderBarEventType.touchesMoved,value)
            }
        }
    }
    
}
