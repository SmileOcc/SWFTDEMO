//
//  HCMarketViewController.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit

class HCMarketViewController: HCBaseViewController, HCViewModelBased{
    
    var viewModel: HCMarketViewModel!
    
    lazy var navBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemPink
        return view
    }()
    lazy var pkView: HCProductPKView = {
        let view = HCProductPKView(frame: CGRect.zero)
        view.backgroundColor = UIColor.yellow
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_prefersNavigationBarHidden = true
        // Do any additional setup after loading the view.
        self.title = "Market"
        
        view.addSubview(navBar)
        view.addSubview(pkView)
        
        navBar.frame = CGRect(x: 0, y: 0, width: HCConstant.screenWidth, height: 60)
//        pkView.frame = CGRect(x: 0, y: 60, width: HCConstant.screenWidth, height: HCConstant.screenHeight)
        pkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            print("加载222")
            
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {

//                self.pkView.frame = CGRect(x: -HCConstant.screenWidth, y: 0, width: HCConstant.screenHeight, height: HCConstant.screenWidth)

                self.pkView.transform = CGAffineTransform(rotationAngle: 90 * Double.pi / 180.0);

            }, completion: { (completed) in
            })

//            let ani: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.x")
//            ani.toValue = Double.pi*2
//            ani.duration = 3
//            self.pkView.layer.add(ani, forKey: "rotateAnimation")
        })
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
