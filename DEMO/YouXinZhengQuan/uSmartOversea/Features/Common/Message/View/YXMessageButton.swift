//
//  YXMessageButton.swift
//  uSmartOversea
//
//  Created by ellison on 2019/3/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import QMUIKit

@objcMembers class YXMessageButton: QMUINavigationButton {
    static var messageButtons = [WeakBox<YXMessageButton>]()
    static var messageBarButtonItems = [WeakBox<UIBarButtonItem>]()
    
    static var brokerMessageButtons = [WeakBox<YXMessageButton>]()
    static var brokerMessageBarButtonItems = [WeakBox<UIBarButtonItem>]()
    
    class func appendItem(item: UIBarButtonItem) {
        YXMessageButton.messageBarButtonItems.append(WeakBox(item))
    }
    
    class func appendBrokerItem(item: UIBarButtonItem) {
        YXMessageButton.brokerMessageBarButtonItems.append(WeakBox(item))
    }
    
    static var pointIsHidden = true {
        didSet {
            messageButtons.removeAll(where: { $0.unbox == nil })
            for messageButton in messageButtons {
                if let btn = messageButton.unbox {
                    btn.pointView.isHidden = pointIsHidden
                }
            }
            
            messageBarButtonItems.removeAll(where: { $0.unbox == nil })
            for messageItem in messageBarButtonItems {
                if let item = messageItem.unbox {
                    item.qmui_shouldShowUpdatesIndicator = !pointIsHidden
                }
            }
        }
    }
    
    static var brokerRedIsHidden = true {
        didSet {
            brokerMessageButtons.removeAll(where: { $0.unbox == nil })
            for messageButton in brokerMessageButtons {
                if let btn = messageButton.unbox {
                    btn.pointView.isHidden = brokerRedIsHidden
                }
            }
            
            brokerMessageBarButtonItems.removeAll(where: { $0.unbox == nil })
            for messageItem in brokerMessageBarButtonItems {
                if let item = messageItem.unbox {
                    item.qmui_shouldShowUpdatesIndicator = !brokerRedIsHidden
                }
            }
        }
    }
    
    private lazy var pointView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.isHidden = YXMessageButton.pointIsHidden
        return view
    }()

    public init() {
        super.init(type: .normal)
        adjustsImageTintColorAutomatically = false
        self.setImage(UIImage(named: "com_message"), for: .normal)
        self.addSubview(pointView)
        pointView.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(4)
            make.top.equalTo(self.snp.centerY).offset(-12)
            make.size.equalTo(CGSize(width: 8, height: 8))
        }
       // self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
    }
    
    private override init(type: QMUINavigationButtonType) {
        super.init(type: type)
    }
    
    private override init(type: QMUINavigationButtonType, title: String?) {
        super.init(type: type, title: title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willDealloc() -> Bool {
        false
    }
}
