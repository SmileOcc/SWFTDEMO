//
//  HCLoginViewController.swift
//  URLDEMO
//
//  Created by odd on 7/4/22.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa

class HCLoginViewController: HCBaseViewController, HCViewModelBased {

    var viewModel: HCLoginViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        self.viewModel.mobileLogin()
    }
    

    func bindViewModel() {
        
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


extension HCLoginViewController {
    func viewModelResponse() {
        viewModel.loginSuccessSubject.subscribe(onNext: {[weak self] (success) in
            guard let `self` = self else {return}
            
        }).disposed(by: disposeBag)
    }
}
