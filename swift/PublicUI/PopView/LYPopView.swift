//
//  LYPopView.swift
//  LYProductModel
//
//  Created by MountainZhu on 2020/11/13.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

protocol LYPopCtrlCellClickDelegate: NSObjectProtocol {
    func popCtrlCellClick(tag: Int)
}

class LYPopView: UIView {

    //代理
    var delegate: LYPopCtrlCellClickDelegate?
    
    /// MARK - frame为弹出popView一个cell的frame
    init(frame: CGRect, imageNameArr:[String], titleArr:[String]) {
        super.init(frame: UIScreen.main.bounds)
        
        //整个屏幕背景
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        //凸起的小角
        let small_w:CGFloat = 10.0
        let small_h:CGFloat = 6.0
        let small_y = frame.origin.y - small_h
        
        let small_x = frame.origin.x + frame.size.width / 4 * 3
        var small_rect = CGRect.init()
        small_rect.origin.x = small_x
        small_rect.origin.y = small_y
        small_rect.size.width = small_w
        small_rect.size.height = small_h
        let smallImageView = UIImageView.init(frame: small_rect)
        smallImageView.image = UIImage.init(named: "区号选择new")
        self.addSubview(smallImageView)
        
        let popCtrl_w = frame.size.width
        let popCtrl_h = frame.size.height
        let popCtrl_x = frame.origin.x
        
        for index in 0..<imageNameArr.count {
            let popCtrl_y = frame.origin.y + CGFloat(index) * popCtrl_h
            
            var popCtrl_rect = CGRect.init()
            popCtrl_rect.origin.x = popCtrl_x
            popCtrl_rect.origin.y = popCtrl_y
            popCtrl_rect.size.width = popCtrl_w
            popCtrl_rect.size.height = popCtrl_h
            
            var isLastCell:Bool = false
            isLastCell = true
            
            let popCtrl = LYPopControl.init(frame: popCtrl_rect, imageName: imageNameArr[index], title: titleArr[index], hiddenLine:isLastCell)
            
            popCtrl.tag = 1000+index
            popCtrl.addTarget(self, action: #selector(popCtrlClick), for: .touchUpInside)
            
            if index == 0 {
                let cornerSize = CGSize(width: 5, height: 5)
                let maskPath = UIBezierPath.init(roundedRect: popCtrl.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: cornerSize)
                let maskLayer = CAShapeLayer()
                maskLayer.frame = popCtrl.bounds
                maskLayer.path = maskPath.cgPath
                popCtrl.layer.mask = maskLayer
            } else if index == imageNameArr.count - 1 {
                let cornerSize = CGSize(width: 5, height: 5)
                let maskPath = UIBezierPath.init(roundedRect: popCtrl.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: cornerSize)
                let maskLayer = CAShapeLayer()
                maskLayer.frame = popCtrl.bounds
                maskLayer.path = maskPath.cgPath
                popCtrl.layer.mask = maskLayer
            }
            
            self.addSubview(popCtrl)
        }
        
        UIApplication.shared.keyWindow?.addSubview(self)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { (view) in
            self.removeFromSuperview()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { (view) in
            self.removeFromSuperview()
        }
    }
    
    
    @objc func popCtrlClick(popCtrl: LYPopControl) {
        guard delegate == nil else {
            delegate?.popCtrlCellClick(tag: popCtrl.tag)
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 0
            }, completion: { (view) in
                self.removeFromSuperview()
            })
            return
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
