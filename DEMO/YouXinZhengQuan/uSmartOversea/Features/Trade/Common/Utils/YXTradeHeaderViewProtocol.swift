//
//  YXTradeOrderProtocol.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/3/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift
import NSObject_Rx

protocol YXTradeHeaderSubViewProtocol {
    var contentHeight: CGFloat { get set }
    var contentHeightDidChange: (() -> Void)? { get set }
}

private struct AssociatedKey {
    static var contentHeight: String = "contentHeight"
    static var contentHeightDidChange: String = "contentHeighDidChange"
}

extension YXTradeHeaderSubViewProtocol where Self: UIView {
    
    var contentHeight: CGFloat {
        set {
            let oldValue = contentHeight
            objc_setAssociatedObject(self, &AssociatedKey.contentHeight, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if oldValue != newValue {
                self.contentHeightDidChange?()
            }
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKey.contentHeight) as? CGFloat) ?? 0
        }
    }
    
    var contentHeightDidChange: (() -> Void)? {
        set {
            objc_setAssociatedObject(self, &AssociatedKey.contentHeightDidChange, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)

        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKey.contentHeightDidChange) as? (() -> Void))
        }
    }
}

protocol YXTradeHeaderViewProtocol {
    var heightDidChange: (() -> Void)? { get set }
    var stackView: UIStackView { get set }
    
    var tradeModel: TradeModel! { get set }
    var quote: YXV2Quote? { get set }
    
    var topMargin: CGFloat { get }
    var bottomMargin: CGFloat { get }
    var minContentHeight: CGFloat { get }
}

extension YXTradeHeaderViewProtocol where Self: UIView {
    
    func configStackView() {
        stackView.arrangedSubviews.forEach { [weak self] (subview) in
            guard let strongSelf = self else { return }
            if let subView = subview as? (UIView & YXTradeHeaderSubViewProtocol) {
                subView.contentHeightDidChange = { [weak subView, weak strongSelf]  in
                    guard let subView = subView else { return }
                    
                    strongSelf?.updateHeight()
                    
                    subView.snp.updateConstraints { (make) in
                        make.height.equalTo(subView.contentHeight)
                    }
                }
                
                subView.snp.makeConstraints { (make) in
                    make.height.equalTo(subView.contentHeight)
                }
                
                subview.rx.observe(Bool.self, "hidden").distinctUntilChanged().subscribe(onNext: { [weak strongSelf] (hidden) in
                    strongSelf?.updateHeight()
                }).disposed(by: rx.disposeBag)
            }
        }
    }
    
    func updateHeight() {
        var totalHeight: CGFloat = 0
        stackView.arrangedSubviews.forEach { (view) in
            if let subView = view as? YXTradeHeaderSubViewProtocol {
                if !view.isHidden {
                    totalHeight += subView.contentHeight
                }
            }
        }
        
        totalHeight = max(totalHeight, minContentHeight)
        
        totalHeight += topMargin
        totalHeight += bottomMargin
        
        if self is YXTradeHeaderSubViewProtocol {
            (self as? (UIView & YXTradeHeaderSubViewProtocol))?.contentHeight = totalHeight
        } else {
            if totalHeight != frame.size.height {
                frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: totalHeight)
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
