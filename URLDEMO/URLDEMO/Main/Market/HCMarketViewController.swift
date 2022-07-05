//
//  HCMarketViewController.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit

class HCMarketViewController: HCBaseViewController, HCViewModelBased{
    
    var viewModel: HCMarketViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Market"
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
