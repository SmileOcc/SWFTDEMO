//
//  HCNavigatorServices.swift
//  URLDEMO
//
//  Created by odd on 7/4/22.
//

import UIKit
import URLNavigator

typealias NavigatorServicesType = NavigatorProtocol

class HCNavigatorServices: Navigator{

    static let shareInstance = HCNavigatorServices()
}

//@objcMembers class HCNavigatorServices: NSObject, NavigatorProtocol{
//
//    static let shareInstance = HCNavigatorServices()
//
//    public let matcher = URLMatcher()
//    weak var delegate: NavigatorDelegate?
//    
//    private var viewControllerFactories = [URLPattern: ViewControllerFactory]()
//    private var handlerFactories = [URLPattern: URLOpenHandlerFactory]()
//    
//    
//    func register(_ pattern: URLPattern, _ factory: @escaping ViewControllerFactory) {
//        self.viewControllerFactories[pattern] = factory
//    }
//    
//    func handle(_ pattern: URLPattern, _ factory: @escaping URLOpenHandlerFactory) {
//        self.handlerFactories[pattern] = factory
//    }
//    
//    open func viewController(for url: URLConvertible, context: Any? = nil) -> UIViewController? {
//        let urlPatterns = Array(self.viewControllerFactories.keys)
//        guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
//        guard let factory = self.viewControllerFactories[match.pattern] else { return nil }
//        return factory(url, match.values, context)
//    }
//    
//    open func handler(for url: URLConvertible, context: Any?) -> URLOpenHandler? {
//        let urlPatterns = Array(self.handlerFactories.keys)
//        guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
//        guard let handler = self.handlerFactories[match.pattern] else { return nil }
//        return { handler(url, match.values, context) }
//    }
//    
//}
