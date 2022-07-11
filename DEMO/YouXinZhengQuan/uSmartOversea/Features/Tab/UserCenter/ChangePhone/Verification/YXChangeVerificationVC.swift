//
//  YXChangePhoneVerificationVC.swift
//  uSmartOversea
//
//  Created by ysx on 2021/7/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXChangeVerificationVC:YXHKViewController,HUDViewModelBased{

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXChangeVertifViewModel!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        self.view.backgroundColor = QMUITheme().foregroundColor()
        self.title = self.viewModel.title
        
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalTo(self.view.safeArea.top)
        }
        
        
        let titleLab = UILabel()
        titleLab.font = .systemFont(ofSize: 14)
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.text = self.viewModel.title
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(16)
        }
        
        let descLab = UILabel()
        descLab.text = YXLanguageUtility.kLang(key: "common_reset")
        descLab.textColor = QMUITheme().textColorLevel3()
        descLab.font = .systemFont(ofSize: 14)
        contentView.addSubview(descLab)
        
        descLab.snp.makeConstraints { (make) in
            make.right.equalTo(-40)
            make.centerY.equalTo(titleLab)
            make.height.equalTo(16)
        }
        
        let arrowView = UIImageView.init(image: UIImage.init(named: "user_next"))
        contentView.addSubview(arrowView)
        arrowView.snp.makeConstraints { (make) in
            make.centerY.equalTo(descLab)
            make.right.equalTo(-16)
        }
        
        let  tap = UITapGestureRecognizer()
        tap.addActionBlock {[weak self] (_) in
            if self?.viewModel.type == .phone{
                self?.viewModel.navigator.push(YXModulePaths.changePhoneOld.url)
            }else if self?.viewModel.type == .email{
                let context = YXNavigatable(viewModel: YXChangeEmailViewModel(.change, sourceVC: nil, callBack: nil))
                self?.viewModel.navigator.push(YXModulePaths.changeEmail.url, context: context)
            }
            
        }
        
        contentView.addGestureRecognizer(tap)
        
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
