//
//  BaseInfoView.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/8.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

///邮箱 姓名
class BaseInfoView: UIView {
    ///引用直接更改
    weak var model:OSSVAddresseBookeModel?
    
    let disposeBag = DisposeBag()
    
    weak var emailInput:NormalInputFiled!
    weak var firstNameInput:NormalInputFiled!
    weak var lastNameInput:NormalInputFiled!
    
    
    var emailValid = BehaviorSubject<Bool>(value: false)
    var firstNameValid:Observable<Bool>?
    var lastNameValid:Observable<Bool>?
    
    

    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 15, left: 15, bottom: 5, right: 15))
        }
        let emailInput = NormalInputFiled(frame: .zero)
        emailInput.errorStyle = .Border
        emailInput.placeholder = "*\(STLLocalizedString_("Email")!)"
        emailInput.keyBoardType = .emailAddress
        emailInput.inputFiled?.autocapitalizationType = .none
        emailInput.inputFiled?.rx.controlEvent([.editingChanged,.editingDidEnd]).subscribe(onNext:{[weak self] in
            let (result,message) = CheckTools.checkEmail(text: emailInput.text)
            emailInput.errorMessage = message
            self?.emailValid.onNext(result)
            if result{
                self?.model?.email = emailInput.text
            }
        }).disposed(by: disposeBag)
        
        addSubview(emailInput)
        stackView.addArrangedSubview(emailInput)
        
        self.emailInput = emailInput
//        emailInput.errorMessage = "1232432"
        
        let nameView = UIView()
        stackView.addArrangedSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        
        let firstNameInput = NormalInputFiled(frame: .zero)
        firstNameInput.errorStyle = .Border
        firstNameInput.placeholder = STLLocalizedString_("FirstName")!
        nameView.addSubview(firstNameInput)
        firstNameInput.snp.makeConstraints { make in
            make.leading.equalTo(0)
            make.trailing.equalTo(nameView.snp.centerX).offset(-8)
        }
        self.firstNameInput = firstNameInput
        
        firstNameValid = firstNameInput.inputFiled?.rx.controlEvent([.editingChanged,.editingDidEnd]).map({[weak self] text in
            let (result,message) = CheckTools.checkFirstName(text: firstNameInput.text)
            firstNameInput.errorMessage = message
            if result{
                self?.model?.firstName = firstNameInput.text
            }
            return result
        })
        
        let lastNameInput = NormalInputFiled(frame: .zero)
        lastNameInput.errorStyle = .Border
        lastNameInput.placeholder = STLLocalizedString_("LastName")!
        nameView.addSubview(lastNameInput)
        lastNameInput.snp.makeConstraints { make in
            make.leading.equalTo(nameView.snp.centerX).offset(8)
            make.trailing.equalTo(0)
        }
        self.lastNameInput = lastNameInput
        lastNameValid = lastNameInput.inputFiled?.rx.controlEvent([.editingChanged,.editingDidEnd]).map({[weak self] text in
            let (result,message) = CheckTools.checkLastName(text: lastNameInput.text)
            lastNameInput.errorMessage = message
            if result{
                self?.model?.lastName = lastNameInput.text
            }
            return result
        })
    }

}
