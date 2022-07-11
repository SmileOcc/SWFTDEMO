//
//  YXSlideUpDownViewController.swift
//  PhiSpeaker
//
//  Created by ZhiYun Huang on 11/09/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
//

import UIKit

class YXSlideUpDownViewController: UIViewController {
    
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

extension YXSlideUpDownViewController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SliderTransition(transitionType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SliderTransition(transitionType: .dismiss)
    }
}

class SliderTransition : NSObject, UIViewControllerAnimatedTransitioning {
    
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
            
            guard let toViewCtrl = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? YXSlideUpDownViewController , let visibleArea = toViewCtrl.visibleArea() else {
                return
            }
            
            containerView.addSubview(toViewCtrl.view)
            toViewCtrl.view.alpha = 0
            
            visibleArea.frame = visibleArea.frame.offsetBy(dx: 0, dy: visibleArea.bounds.height)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                toViewCtrl.view.alpha = 1
                visibleArea.frame = visibleArea.frame.offsetBy(dx: 0, dy: -visibleArea.bounds.height)
                
            }, completion: { (completed) in
                transitionContext.completeTransition(true)
            })
            
        }
        else {
            
            guard let fromViewCtrl = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? YXSlideUpDownViewController , let visibleArea = fromViewCtrl.visibleArea()else {
                return
            }
            
            containerView.addSubview(fromViewCtrl.view)
            
            fromViewCtrl.view.alpha = 1
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                fromViewCtrl.view.alpha = 0
                visibleArea.frame = visibleArea.frame.offsetBy(dx: 0, dy: visibleArea.bounds.height)
                
            }, completion: { (completed) in
                transitionContext.completeTransition(true)
            })        }
        
        
        
    }
}
