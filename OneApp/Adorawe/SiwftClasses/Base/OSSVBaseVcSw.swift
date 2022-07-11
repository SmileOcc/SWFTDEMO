//
//  STLBaseController.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/30.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift

class OSSVBaseVcSw: UIViewController {

    var firstEnter: Bool = true
    var operations: NSMutableArray = NSMutableArray.init()
    
    ///为了统计
    var currentButtonKey: NSString?
    var currentPageCode: NSString?

    var lastButtonKey: NSString?
    var lastSku_code: NSString?
    ///传递字段
    var transmitMutDic: NSMutableDictionary = NSMutableDictionary.init()
    var isModalPresent: Bool = false {
        didSet {
            if let window = kKeyWindow() {
                window.backgroundColor = isModalPresent ?  OSSVThemesColors.stlBlackColor() : OSSVThemesColors.stlWhiteColor()
            }
        }
    }
    
    // 当bag销毁(deinit)时，会自动调用Disposable实例的dispose，observe订阅也跟着销毁
    var disposeBag = DisposeBag()

    deinit {
        print("-----------dealloc deinit: \(String(cString: object_getClassName(self)))")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = OSSVThemesColors.col_F5F5F5()
    }

    
    @objc func stopRequest() {
        for item in self.operations {
            if let item = item as? OSSVBasesRequests {
                item.stop()
            }
        }
        self.operations.removeAllObjects()
    }

    @objc func stlInitView() {}
    
    @objc func stlAutoLayoutView() {}
}

extension OSSVBaseVcSw {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        OSSVAnalyticPagesManager.shared().currentPageName = String(cString: object_getClassName(self))
        if self.isModalPresent {
            if let window = kKeyWindow() {
                window.backgroundColor = OSSVThemesColors.stlBlackColor()
            }
        }
        
        //此方法是为了防止控制器的title发生偏移，造成这样的原因是因为返回按钮的文字描述占位
        if let subsControlllersArray = self.navigationController?.viewControllers as NSArray?,subsControlllersArray.contains(self) {
            let previousViewControllerIndex = subsControlllersArray.index(of: self)
            if previousViewControllerIndex >= 0 {
                if let previousContorller = subsControlllersArray.object(at: previousViewControllerIndex) as? UIViewController {
                    previousContorller.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
                }
            }
        } else if let subsControlllersArray = self.navigationController?.viewControllers as NSArray? {
            if let lastCtrl = subsControlllersArray.lastObject as? WMPageController {
                let previousViewControllerIndex = subsControlllersArray.index(of: lastCtrl) - 1
                if previousViewControllerIndex >= 0 {
                    
                    if let previousContorller = subsControlllersArray.object(at: previousViewControllerIndex) as? UIViewController {
                        previousContorller.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)

                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !self.isModalPresent {
            if let window = kKeyWindow() {
                window.backgroundColor = OSSVThemesColors.stlWhiteColor()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print(NSStringFromClass(type(of: self)))
        print(String(describing: type(of: self)))

        OSSVAnalyticPagesManager.shared().currentPageName = String(describing: type(of: self))
        OSSVAnalyticPagesManager.shared().lastPageCode = OSSVAnalyticPagesManager.shared().currentPageCode
        OSSVAnalyticPagesManager.shared().currentPageCode = (self.currentPageCode ?? "") as String
        
        if !isModalPresent {
            if let window = kKeyWindow() {
                window.backgroundColor = OSSVThemesColors.stlWhiteColor()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    //MARK: - 导航栏左上角返回按钮事件
    @objc func goBackAction() {
        if let subControllers = self.navigationController?.viewControllers, subControllers.count > 1 {
            if subControllers[subControllers.count - 1] == self {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }
}
