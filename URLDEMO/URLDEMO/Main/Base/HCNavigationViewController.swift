//
//  HCNavigationViewController.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit
import URLNavigator

class HCNavigationViewController: UINavigationController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.view.backgroundColor = UIColor.blue
        
        self.modalPresentationStyle = .fullScreen
        self.navigationBar.isTranslucent = false
        self.navigationBar.barStyle = .default
        
        if #available(iOS 15.0, *) {
            let barApp = UINavigationBarAppearance()
            barApp.configureWithOpaqueBackground()
            barApp.backgroundColor = UIColor.white
//            barApp.shadowImage = UIImage.
            self.navigationBar.scrollEdgeAppearance = barApp
            self.navigationBar.standardAppearance = barApp
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HCNavigationViewController {
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
}
