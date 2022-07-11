//
//  OSSVDetailsTranAnim.swift
// XStarlinkProject
//
//  Created by odd on 2021/7/29.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVDetailsTranAnim: NSObject {

    var type: UINavigationController.Operation?
    var sourceView: YYAnimatedImageView?
    
    init(transitionType type:UINavigationController.Operation, sourceView:UIView) {
        super.init()
        self.type = type
        self.sourceView = sourceView as? YYAnimatedImageView
    }
    
    func pushAnimation(transitionContext: UIViewControllerContextTransitioning) {
        let toVC: OSSVDetailsVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! OSSVDetailsVC
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        if toVC.fd_prefersNavigationBarHidden {
            toView?.frame = UIScreen.main.bounds
        }
        
//        var toFrame:CGRect = UIScreen.main.bounds
//        var sourceFrame:CGRect = UIScreen.main.bounds
//        
//        if self.sourceView != nil {
//            
//            sourceFrame = self.sourceView!.convert(self.sourceView!.frame, to: keyWindow())
//            
//            let transformFrame:CGRect = toVC.transformView.imageView?.frame ?? CGRect.zero
//            
//            if transformFrame.size.width > 0 && sourceFrame.width > 0{
//                
//                toFrame = CGRect.init(x: transformFrame.minX ?? 0, y: 0, width: transformFrame.width ?? 0, height: (transformFrame.width ?? 0) * (sourceFrame.height ?? 0) / sourceFrame.width)
//            }
//        }
//        
//        toVC.transformView.imageView?.image = self.sourceView?.image
//        toVC.transformView.imageView?.frame = sourceFrame
//        transitionContext.containerView.addSubview(toVC.view)
//     
//        let duration = self.transitionDuration(using: transitionContext)
//        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
//            
//            toVC.transformView.imageView?.frame = toFrame
//        } completion: { finished in
//            toVC.transformView.finishedTransition()
//            transitionContext.completeTransition(true)
//        }

    }
    
    func popAnimation(transitionContext: UIViewControllerContextTransitioning) {
        
    }
    
    func keyWindow() -> UIWindow? {
        var window: UIWindow? = nil
        if #available(iOS 13.0, *) {
            for windowScene:UIWindowScene in (UIApplication.shared.connectedScenes as? Set<UIWindowScene>)! {
                if windowScene.activationState == .foregroundActive {
                    window = windowScene.windows.first
                }
                break
            }
        } else {
            window = UIApplication.shared.keyWindow
        }
        return window
    }
}


extension OSSVDetailsTranAnim: UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch self.type {
        case .pop:
            self.popAnimation(transitionContext: transitionContext)
           break
        case .push:
            self.pushAnimation(transitionContext: transitionContext)
           break
        default:
            break
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
}

