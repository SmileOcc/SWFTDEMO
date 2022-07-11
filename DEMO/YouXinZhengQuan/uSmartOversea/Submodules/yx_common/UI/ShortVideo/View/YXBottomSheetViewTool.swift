//
//  YXBottomSheetViewTool.swift
//  uSmartOversea
//
//  Created by youxin on 2021/4/14.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXBottomSheetViewTool: NSObject {
    
//    static let shared = YXBottomSheetViewTool()
    
    var viewControllerForShow: UIViewController?
    
    let defaultContentHeight = YXConstant.screenHeight - YXConstant.navBarHeight()
    
    @objc var leftButtonAction: (() -> Void)?
    @objc var rightButtonAction: (() -> Void)?
    
    var presentVC: QMUIModalPresentationViewController?
    
    @objc lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
//        label.textColor = QMUICMI().textColorLevel1()
        return label
    }()
    
    @objc lazy var leftButton: UIButton = {
        let btn = creatButton(title: "取消")
//        btn.setTitleColor(QMUICMI().mainThemeColor(), for: .normal)
        _ = btn.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            self?.leftButtonAction?()
        })
        return btn
    }()
    
    @objc lazy var rightButton: UIButton = {
        let btn = creatButton(title: "确定")
        btn.contentHorizontalAlignment = .right
        _ = btn.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            self?.rightButtonAction?()
        })
        return btn
    }()
    
    lazy var header: UIView = {
        let view = UIView()
        view.addSubview(leftButton)
        view.addSubview(titleLabel)
        view.addSubview(rightButton)
        
        view.layer.qmui_maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 16
        view.backgroundColor = UIColor.white
        view.layer.shadowColor = UIColor.qmui_color(withHexString: "#000000")?.withAlphaComponent(0.05).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 16.0
        
        leftButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        rightButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(40)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        return view
    }()
    
    func creatButton(title: String) -> QMUIButton {
        let button = QMUIButton()
        button.spacingBetweenImageAndTitle = 2
        button.imagePosition = .left
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
//        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        return button
    }
    
    @objc func showViewController(vc: UIViewController) {

        viewControllerForShow = vc
        
        showView(view: vc.view, contentHeight: defaultContentHeight)
    }
    
    func showViewController(vc: UIViewController, contentHeight: CGFloat? = nil) {

        viewControllerForShow = vc
        
        if let h = contentHeight {
            showView(view: vc.view, contentHeight: h)
        }else {
            showView(view: vc.view, contentHeight: defaultContentHeight)
        }
        
    }
    
    @objc func showView(view: UIView, contentHeight: CGFloat = (YXConstant.screenHeight - YXConstant.navBarHeight())) {
        
        let contentView = UIView()

        header.removeFromSuperview()
        contentView.addSubview(header)
        contentView.addSubview(view)

        header.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(50)
        }

        view.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(header.snp.bottom)
        }
        
        contentView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: contentHeight)
        
        let presentVC = QMUIModalPresentationViewController()
        self.presentVC = presentVC
        if let vc = viewControllerForShow {
            presentVC.addChild(vc)
        }
        presentVC.delegate = self
        presentVC.animationStyle = .slide
        presentVC.contentViewMargins = UIEdgeInsets.zero
        presentVC.contentView = contentView
        presentVC.layoutBlock = { (containerBounds, keyboardHeight, contentViewDefaultFrame) in
            let rect = CGRectSetXY(contentView.frame, CGFloatGetCenter(containerBounds.width, contentView.width), containerBounds.height - contentView.height)
            contentView.qmui_frameApplyTransform = rect
        }
        
        viewControllerForShow?.beginAppearanceTransition(true, animated: true)
//        presentVC.showWith(animated: true, completion: {[weak self] _ in
//            self?.viewControllerForShow?.endAppearanceTransition()
//        })
        
        if let window = UIViewController.current().view.window {
            presentVC.show(in: window, animated: true) { [weak self] _ in
                self?.viewControllerForShow?.endAppearanceTransition()
            }
        }
        
    }
    
    @objc func hide() {
        
//        presentVC?.hideWith(animated: true, completion: nil)
        if let window = UIViewController.current().view.window {
            presentVC?.hide(in: window, animated: true, completion: nil)
        }
        
    }
    
    @objc func rightBtnOnlyImage(iamge:UIImage?){
        if let btn = rightButton as? QMUIButton  {
            btn.imagePosition = .right
        }
        rightButton.setImage(iamge, for: .normal)
        rightButton.setTitle("", for: .normal)
    }

}

extension YXBottomSheetViewTool: QMUIModalPresentationViewControllerDelegate {
    
    func willHide(_ controller: QMUIModalPresentationViewController) {
        viewControllerForShow?.beginAppearanceTransition(false, animated: true)
    }
    
    func didHide(_ controller: QMUIModalPresentationViewController) {
        viewControllerForShow?.endAppearanceTransition()
        viewControllerForShow?.removeFromParent()
        viewControllerForShow = nil
        presentVC = nil
        
    }
}
