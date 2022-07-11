//
//  YXStrongNoticeViewExtension.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

var key: Void?

extension YXStrongNoticeView {
    
    var disposeBag: DisposeBag? {
        get {
            objc_getAssociatedObject(self, &key) as? DisposeBag
        }
        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 关闭指定消息id的消息
    ///
    /// - Parameter msgid: 需要关闭的消息id
    @objc func closeMsgRequest(msgid: String) {
        self.disposeBag = DisposeBag()
        if let disposeBag = self.disposeBag {
            self.services.request(.closeMsg(msgid), response: { (response) in

            } as YXResultResponse<JSONAny>).disposed(by: disposeBag)
        }
    }
}
