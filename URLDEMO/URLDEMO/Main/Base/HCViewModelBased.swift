//
//  ViewModelBased.swift
//  URLDEMO
//
//  Created by odd on 7/4/22.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import URLNavigator

protocol ViewModel {
}

protocol ServicesViewModel: ViewModel {
    associatedtype Services
    var services: Services! { get set }
    var navigator: NavigatorServicesType! { get set }
}

protocol HCViewModelBased: AnyObject {
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType! { get set }
}
extension HCViewModelBased where Self: UIViewController, ViewModelType: ServicesViewModel {
    static func instantiate<ViewModelType, ServicesType> (withViewModel viewModel: ViewModelType, andServices services: ServicesType, andNavigator navigator: NavigatorServicesType) -> Self
        where ViewModelType == Self.ViewModelType, ServicesType == Self.ViewModelType.Services {
            let viewController = Self()
            viewController.viewModel = viewModel
            viewController.viewModel.services = services
            viewController.viewModel.navigator = navigator
            return viewController
    }
}

extension HCViewModelBased where Self: UIViewController & StoryboardBased, ViewModelType: ServicesViewModel {
    static func instantiate<ViewModelType, ServicesType> (withViewModel viewModel: ViewModelType, andServices services: ServicesType, andNavigator navigator: NavigatorServicesType) -> Self
        where ViewModelType == Self.ViewModelType, ServicesType == Self.ViewModelType.Services {
            let viewController = Self.instantiate()
            viewController.viewModel = viewModel
            viewController.viewModel.services = services
            viewController.viewModel.navigator = navigator
            return viewController
    }
}
extension HCViewModelBased where Self: StoryboardBased & UIViewController {
    static func instantiateFromStoryboard<ViewModelType> (withViewModel viewModel: ViewModelType) -> Self
        where ViewModelType == Self.ViewModelType {
        let viewController = Self.instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}
