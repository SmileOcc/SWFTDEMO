//
//  AddressSearchView.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift

class AddressSearchView: UIStackView {
    
    
    weak var inputField:UITextField?
    weak var cancelBtn:UIButton?
    
    var disposebag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        axis = .horizontal
        spacing = 12
        alignment = .center

        
        
        let backgroundView = UIView()
        addArrangedSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.centerY.equalTo(self.snp.centerY)
        }
        backgroundView.backgroundColor = OSSVThemesColors.col_F5F5F5()
        backgroundView.layer.cornerRadius = 20
        
        let searchIcon = UIImageView(image: UIImage(named: "cascade_search"))
        backgroundView.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.leading.equalTo(backgroundView.snp.leading).offset(12)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        let cancelButton = UIButton()
        addArrangedSubview(cancelButton)
       
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.titleLabel?.setContentHuggingPriority(.required, for: .horizontal)
        cancelButton.titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        if app_type == 3 {
            cancelButton.setTitle(STLLocalizedString_("cancel")?.capitalized, for: .normal)
        } else {
            cancelButton.setTitle(STLLocalizedString_("cancel")?.capitalized.uppercased(), for: .normal)
        }
        cancelButton.setTitleColor(OSSVThemesColors.col_131313(), for: .normal)
        cancelBtn = cancelButton
        cancelButton.isHidden = true
        cancelButton.rx.tap.subscribe {[weak self] _ in
            cancelButton.isHidden = true
            self?.inputField?.text = nil
            self?.inputField?.endEditing(true)
        }.disposed(by: disposebag)
        
        let inputField = UITextField()
        inputField.textAlignment = OSSVSystemsConfigsUtils.isRightToLeftShow() ? .right : .left
        backgroundView.addSubview(inputField)
        inputField.snp.makeConstraints { make in
            make.leading.equalTo(backgroundView).offset(32)
            make.trailing.equalTo(backgroundView)
            make.centerY.equalTo(backgroundView.snp.centerY)
        }
        inputField.tintColor = OSSVThemesColors.col_0D0D0D()
        inputField.placeholder = STLLocalizedString_("search")
        self.inputField = inputField
        inputField.delegate = self
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension AddressSearchView: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.cancelBtn?.isHidden = false
    }
}
