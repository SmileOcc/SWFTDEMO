//
//  HUDViewModelBased.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift

enum HUDType {
    case loading(_ msg: String?, _ inWindow: Bool)
    case message(_ msg: String?, _ inWindow: Bool)
    case error(_ msg: String?, _ inWindow: Bool)
    case success(_ msg: String?, _ inWindow: Bool)
    case hide
    
    public var msg: String? {
        switch self {
        case .loading(let msg, _):
            return msg
        case .message(let msg, _):
            return msg
        case .error(let msg, _):
            return msg
        case .success(let msg, _):
            return msg
        default:
            return nil
        }
    }
    
    public var inWindow: Bool {
        switch self {
        case .loading(_, let inWindow):
            return inWindow
        case .message(_ , let inWindow):
            return inWindow
        case .error(_ , let inWindow):
            return inWindow
        case .success(_ , let inWindow):
            return inWindow
        default:
            return false
        }
    }
}

protocol HUDViewModelBased: ViewModelBased where ViewModelType: HUDServicesViewModel {
    var networkingHUD: YXProgressHUD! {get set}
}

protocol HUDServicesViewModel: ServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! {get set}
}

extension HUDViewModelBased where Self: UIViewController {

    func bindHUD() {
        
        _ = viewModel.hudSubject?.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (hudType) in
            guard let strongSelf = self else { return }
            
            let msg = hudType.msg
            let inWindow = hudType.inWindow;
            
            if inWindow == true {
                switch hudType {
                case .loading:
                    strongSelf.networkingHUD.showLoading(msg)
                case .message:
                    strongSelf.networkingHUD.showMessage(msg)
                case .success:
                    strongSelf.networkingHUD.showSuccess(msg)
                case .error:
                    strongSelf.networkingHUD.showError(msg)
                case .hide:
                    strongSelf.networkingHUD.hideHud()
                }
            } else {
                switch hudType {
                case .loading:
                    strongSelf.networkingHUD.showLoading(msg, in: self?.view)
                case .message:
                    strongSelf.networkingHUD.showMessage(msg, in: self?.view)
                case .success:
                    strongSelf.networkingHUD.showSuccess(msg, in: self?.view)
                case .error:
                    strongSelf.networkingHUD.showError(msg, in: self?.view)
                case .hide:
                    strongSelf.networkingHUD.hideHud()
                }
            }
        })
    }
}
