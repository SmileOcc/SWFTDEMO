//
//  NavigatorServices.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/12/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator

typealias NavigatorServicesType = NavigatorType & YXViewModelServices

@objcMembers class NavigatorServices: NSObject, NavigatorType {

    
    static let shareInstance = NavigatorServices()

    public let matcher = URLMatcher()
    open weak var delegate: NavigatorDelegate?
    
    private var viewControllerFactories = [URLPattern: ViewControllerFactory]()
    private var handlerFactories = [URLPattern: URLOpenHandlerFactory]()
    
    
    open func register(_ pattern: URLPattern, _ factory: @escaping ViewControllerFactory) {
        self.viewControllerFactories[pattern] = factory
    }
    
    open func handle(_ pattern: URLPattern, _ factory: @escaping URLOpenHandlerFactory) {
        self.handlerFactories[pattern] = factory
    }
    
    open func viewController(for url: URLConvertible, context: Any? = nil) -> UIViewController? {
        let urlPatterns = Array(self.viewControllerFactories.keys)
        guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
        guard let factory = self.viewControllerFactories[match.pattern] else { return nil }
        return factory(url, match.values, context)
    }
    
    open func handler(for url: URLConvertible, context: Any?) -> URLOpenHandler? {
        let urlPatterns = Array(self.handlerFactories.keys)
        guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
        guard let handler = self.handlerFactories[match.pattern] else { return nil }
        return { handler(url, match.values, context) }
    }
}

extension NavigatorServices: YXViewModelServices {
    @objc public func present(_ viewModel: YXViewModel, animated: Bool, completion: VoidBlock?) {
        let viewController = YXRouter.sharedInstance().viewController(for: viewModel)
        presentViewController(viewController, wrap: YXNavigationController.self, from: nil, animated: animated, completion: completion)
    }
    
    @objc public func push(_ viewModel: YXViewModel, animated: Bool) {
        let viewController = YXRouter.sharedInstance().viewController(for: viewModel)
        push(viewController)
    }

    @objc public func popViewModel(animated: Bool) {
        guard let navigationController = UIViewController.topMost?.navigationController else { return }
        navigationController.popViewController(animated: true)
    }

    @objc public func pop(to viewModel: YXViewModel, animated: Bool) {
        guard let navigationController = UIViewController.topMost?.navigationController else { return }
        var viewController: UIViewController?
        navigationController.viewControllers.forEach { (vc) in
            if let vc = vc as? YXViewController {
                if vc.viewModel == viewModel {
                    viewController = vc;
                }
            }
        }
        if let vc = viewController as? YXViewController {
            navigationController.popToViewController(vc, animated: animated)
        } else {
            navigationController.popToRootViewController(animated: animated)
        }
    }

    @objc public func popToRootViewModel(animated: Bool) {
        guard let navigationController = UIViewController.topMost?.navigationController else { return }
        navigationController.popToRootViewController(animated: animated)
    }

    @objc public func dismissViewModel(animated: Bool, completion: VoidBlock?) {
        guard let navigationController = UIViewController.topMost?.navigationController else { return }
        navigationController.dismiss(animated: animated, completion: completion)
    }

    @objc public func resetRootViewModel(_ viewModel: YXViewModel) {
        
    }
    
    @objc func pushPath(_ path: YXModulePaths, context: Any?, animated: Bool) {
        pushURL(path.url, context: context, from: nil, animated: animated)
    }
    
    @objc func presentPath(_ path: YXModulePaths, context: Any?, animated: Bool, completion: (() -> Void)? = nil) {
        present(path.url, context: context, wrap: YXNavigationController.self, from: nil, animated: animated, completion: completion)
    }
}
