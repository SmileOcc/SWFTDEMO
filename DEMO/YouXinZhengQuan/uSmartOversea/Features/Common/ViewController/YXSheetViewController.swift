//
//  YXSheetViewController.swift
//  uSmartOversea
//
//  Created by ysx on 2021/8/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSheetViewController{

    init( _ edges:UIEdgeInsets) {
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.fillColor = QMUITheme().popupLayerColor().cgColor
        shapeLayer.frame = backgroundView.bounds
        backgroundView.layer.addSublayer(shapeLayer)
        let path = UIBezierPath.init(roundedRect: backgroundView.bounds, byRoundingCorners:[.topLeft,.topRight] , cornerRadii: CGSize.init(width: 16, height: 16))
        shapeLayer.path = path.cgPath
        backgroundEdges = edges
        self.shapeLayer = shapeLayer
    }
    
    private var backgroundEdges : UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    private var shapeLayer : CAShapeLayer = CAShapeLayer.init()
    private var alertVC:YXAlertController?
    private var actions:[YXSheetAction] = [YXSheetAction]()
    
    private var backgroundView : UIView = {
        let view = UIView()
        return view
    }()
    
    private var lastAction:YXSheetAction?
    

    
    func addAction(_ action:YXSheetAction) {
        let width = YXConstant.screenWidth //- backgroundEdges.left + backgroundEdges.right
        
        if action.style == .defaultStyle {
            action.frame = CGRectFlatMake(0, lastAction?.bottom ?? 0, width, 54)
        }else {
            action.frame = CGRectFlatMake(0, lastAction?.bottom ?? 0, width, 54 + 8)
        }
        
        backgroundView.addSubview(action)
        lastAction = action
        
        let maxY = YXConstant.tabBarPadding() + action.bottom
        
        backgroundView.frame = CGRectFlatMake(0, YXConstant.screenHeight - maxY, width, maxY)
        
        shapeLayer.frame = backgroundView.bounds
        let path = UIBezierPath.init(roundedRect: backgroundView.bounds, byRoundingCorners:[.topLeft,.topRight] , cornerRadii: CGSize.init(width: 16, height: 16))
        shapeLayer.path = path.cgPath
        self.actions.append(action)
    }
    
    func showIn(_ vc:UIViewController) {
        if let alertVC = YXAlertController.init(alert: backgroundView, preferredStyle: .actionSheet, transitionAnimation: .scaleFade) {
            alertVC.backgoundTapDismissEnable = true
            self.alertVC = alertVC
            for itme in self.actions {
                itme.alertVC = alertVC
            }
            vc.present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    func hidden()  {
        self.alertVC?.dismissViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

enum YXSheetActionStyle {
    case defaultStyle
    case cancelStyle
    case errorStyle
}

class YXSheetAction:UIView {
    
    var style:YXSheetActionStyle  = .defaultStyle
    
    private var actionView:UIView = {
        let view = UIView()
        return view
    }()
    
    weak var alertVC:YXAlertController?
    var callBack :(()->())?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(actionView)
        actionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    
    
    convenience init(title:String,style:YXSheetActionStyle,hiddenLine:Bool,handel:(()->())?) {
        self.init(frame: .zero)
        self.style = style
        self.callBack = handel
        let actionBtn = UIButton(type: .custom)
        actionBtn.titleLabel?.font = .systemFont(ofSize: 16)
        actionBtn.setTitle(title, for: .normal)
        actionBtn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        actionBtn.addTarget(self, action: #selector(click), for: .touchUpInside)
        self.actionView.addSubview(actionBtn)
        let lineView = UIView()
        self.actionView.addSubview(lineView)
        if style == .defaultStyle  || style == .errorStyle{
            lineView.backgroundColor = QMUITheme().popSeparatorLineColor()
            actionBtn.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            lineView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }
            lineView.isHidden = hiddenLine
            if style == .errorStyle {
                actionBtn.setTitleColor(QMUITheme().errorTextColor(), for: .normal)
            }
        }else {
            lineView.backgroundColor = QMUITheme().blockColor()
            actionBtn.snp.makeConstraints { (make) in
                make.size.equalToSuperview()
                make.top.equalTo(lineView.snp.bottom)
            }
            lineView.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(8)
            }
        }
    
    }
    
    convenience init(customView:UIView,handel:(()->())?){
        self.init(frame: .zero)
        self.style = .defaultStyle
        self.callBack = handel
        self.actionView.addSubview(customView)
        customView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let tap = UITapGestureRecognizer()
        customView.isUserInteractionEnabled = true
        customView.addGestureRecognizer(tap)
        tap.addTarget(self, action: #selector(click))
    }
    
    @objc func click(){
        self.alertVC?.dismissViewController(animated: true)
        self.callBack?()
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
