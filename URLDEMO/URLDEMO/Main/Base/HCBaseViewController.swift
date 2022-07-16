//
//  HCBaseViewController.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit
import URLNavigator
import RxSwift
import RxCocoa
import NSObject_Rx

class HCBaseViewController: UIViewController, HasDisposeBag {

    deinit {
        print(">>>>>>> \(NSStringFromClass(type(of: self)).split(separator: ".").last!) deinit")

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.init(hexColorString: "0#eeeeee")
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
