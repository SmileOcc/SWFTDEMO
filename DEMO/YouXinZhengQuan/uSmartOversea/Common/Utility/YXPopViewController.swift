//
//  YXPopViewController.swift
//  PhiSpeaker
//
//  Created by ZhiYun Huang on 11/09/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
//

import UIKit

class YXPopViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self
    }
    
    func visibleArea() -> UIView? {
        nil
    }
}

extension YXPopViewController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        PopTransition(transitionType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        PopTransition(transitionType: .dismiss)
    }
}

class PopTransition : NSObject, UIViewControllerAnimatedTransitioning {
    
    enum TransitionType {
        case present
        case dismiss
    }
    
    var transitionType : TransitionType = .present
    
    init(transitionType : TransitionType) {
        super.init()
        self.transitionType = transitionType
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        
        if transitionType == .present {
            
            guard let toViewCtrl = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? YXPopViewController , let visibleArea = toViewCtrl.visibleArea() else {
                return
            }
            
            containerView.addSubview(toViewCtrl.view)
            visibleArea.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            visibleArea.alpha = 0
            
            UIAlertView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                visibleArea.alpha = 1
                visibleArea.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
            }, completion: { (completed) in
                transitionContext.completeTransition(true)
            })
            
        }
        else {
            
            guard let fromViewCtrl = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? YXPopViewController , let visibleArea = fromViewCtrl.visibleArea()else {
                return
            }
            
            containerView.addSubview(fromViewCtrl.view)
            
            visibleArea.alpha = 1
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                visibleArea.alpha = 0
                
            }, completion: { (completed) in
                transitionContext.completeTransition(true)
            })
            
        }
        
        
        
    }
}
