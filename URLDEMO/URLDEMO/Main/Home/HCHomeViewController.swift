//
//  HCHomeViewController.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit

class HCHomeViewController: HCBaseViewController , HCViewModelBased{

    var viewModel: HCHomeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Home"
        
        #if DEV || SIT
        self.view.backgroundColor = UIColor.link
        #elseif UAT
        self.view.backgroundColor = UIColor.green
        #else
        self.view.backgroundColor = UIColor.purple
        #endif
        
        self.view.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { make in
            make.left.equalTo(self.view).offset(60)
            make.top.equalTo(self.view.snp.top).offset(120)
            make.size.equalTo(CGSize(width: 100, height: 40))
        }
        loginBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }

            let orgLoginViewModel = HCLoginViewModel()
            let context = HCNavigatable(viewModel: orgLoginViewModel, userInfo: nil)
            self.viewModel.navigator.push(HCModulePaths.userCenterCollect.url, context: context)
        }.disposed(by: self.disposeBag)

    }
    

    lazy var loginBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.green
        btn.setTitle("xxx", for: .normal)
        return btn
    }()
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
