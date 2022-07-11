//
//  YXStockDetailHeaderViewProtocol.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2022/2/15.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift
import NSObject_Rx

protocol YXStockDetailSubHeaderViewProtocol {
    var contentHeight: CGFloat { get set }
    var contentHeighDidChange: (() -> Void)? { get set }
}

private struct AssociatedKey {
    static var contentHeight: String = "contentHeight"
    static var contentHeighDidChange: String = "contentHeighDidChange"
}

extension YXStockDetailSubHeaderViewProtocol where Self: UIView {
    
    var contentHeight: CGFloat {
        set {
            let oldValue = contentHeight
            objc_setAssociatedObject(self, &AssociatedKey.contentHeight, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if oldValue != newValue {
                    self.contentHeighDidChange?()
            
            }
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKey.contentHeight) as? CGFloat) ?? 0
        }
    }
    
    var contentHeighDidChange: (() -> Void)? {
        set {
            objc_setAssociatedObject(self, &AssociatedKey.contentHeighDidChange, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)

        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKey.contentHeighDidChange) as? (() -> Void))
        }
    }
    
}

protocol YXStockDetailHeaderViewProtocol {
    var heightDidChange: (() -> Void)? { get set }
    var stackView: UIStackView { get set }
        
    var topMargin: CGFloat { get }
    var bottomMargin: CGFloat { get }
    var minContentHeight: CGFloat { get }
}

extension YXStockDetailHeaderViewProtocol where Self: UIView {
    
    func configStackView() {
        stackView.arrangedSubviews.forEach { [weak self] (view) in
            guard let strongSelf = self else { return }
            if view is YXStockDetailSubHeaderViewProtocol {
                let subView = view as! (UIView & YXStockDetailSubHeaderViewProtocol)
                subView.contentHeighDidChange = { [weak subView, weak strongSelf]  in
                    guard let subView = subView else { return }

                    strongSelf?.updateHeight()
                    subView.snp.updateConstraints { (make) in
                        make.height.equalTo(subView.contentHeight)
                    }
                }
                subView.snp.makeConstraints { (make) in
                    make.height.equalTo(subView.contentHeight)
                }
            }
            
            view.rx.observe(Bool.self, "hidden").distinctUntilChanged().subscribe(onNext: { [weak strongSelf] (_) in
                strongSelf?.updateHeight()
            }).disposed(by: rx.disposeBag)
        }
    }
    
    func updateHeight() {
        var totalHeight: CGFloat = 0

        stackView.arrangedSubviews.forEach { (view) in
            if let subView = view as? YXStockDetailSubHeaderViewProtocol {
                if !view.isHidden {
                    totalHeight += subView.contentHeight
                }
            }
        }
        
        totalHeight = max(totalHeight, minContentHeight)

        totalHeight += topMargin
        totalHeight += bottomMargin
        
        if self is YXStockDetailSubHeaderViewProtocol {
            (self as! (UIView & YXStockDetailSubHeaderViewProtocol)).contentHeight = totalHeight
        } else {
            if totalHeight != self.frame.size.height {
                self.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: totalHeight)
                heightDidChange?()
            }
        }
    }
    
    var topMargin: CGFloat {
        get {
            return 0
        }
    }
    var bottomMargin: CGFloat {
        get {
            return 0
        }
    }
    var minContentHeight: CGFloat {
        get {
            return 0
        }
    }
}
