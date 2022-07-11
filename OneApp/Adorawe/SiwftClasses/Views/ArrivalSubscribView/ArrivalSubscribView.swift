//
//  ArrivalSubscribView.swift
//  Adorawe
//
//  Created by fan wang on 2021/11/16.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ArrivalSubscribView: UIView {
    
    var closePub = PublishSubject<Void>()
    //(email,goodsSn)
    var actionPub = PublishSubject<(String?,String?)>()
    
    weak var goodsImageView:YYAnimatedImageView!
    weak var sizeLabel:UILabel!
    weak var goodsName:UILabel!
    weak var emailInput:NormalInputFiled!
    var goodsSn:String!
    
    let disposeBag = DisposeBag()

    override init(frame:CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupSubViews(){
        backgroundColor = OSSVThemesColors.col_FFFFFF()
        let titleLbl = UILabel()
        addSubview(titleLbl)
        titleLbl.text = STLLocalizedString_("Arrival_Notify_Text_NotLogin")
        titleLbl.font = UIFont.boldSystemFont(ofSize: 16)
        titleLbl.numberOfLines = 0
        titleLbl.textAlignment = .center
        titleLbl.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(46)
        }
        
        let goodsImage = YYAnimatedImageView()
        addSubview(goodsImage)
        goodsImageView = goodsImage
        goodsImage.snp.makeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(28)
            make.leading.equalTo(45)
            make.width.height.equalTo(90)
        }
        
        let stack = UIStackView()
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.equalTo(goodsImage.snp.trailing).offset(15)
            make.trailing.equalTo(-18)
            make.centerY.equalTo(goodsImage.snp.centerY)
        }
        stack.axis = .vertical
        
        let nameLbl = UILabel()
        nameLbl.font = UIFont.systemFont(ofSize: 14)
        goodsName = nameLbl
        stack.addArrangedSubview(nameLbl)
        
        let sizeLbl = UILabel()
        sizeLbl.font = UIFont.systemFont(ofSize: 14)
        sizeLabel = sizeLbl
        stack.addArrangedSubview(sizeLbl)
        
        let emailInput = NormalInputFiled(frame: .zero)
        emailInput.keyBoardType = .emailAddress
        self.emailInput = emailInput
        emailInput.placeholder = STLLocalizedString_("Arrival_Notify_Email_Address")
        addSubview(emailInput)
        emailInput.snp.makeConstraints { make in
            make.top.equalTo(goodsImageView.snp.bottom).offset(40)
            make.leading.equalTo(6)
            make.trailing.equalTo(-6)
        }
        
        let notifyButton = UIButton()
        addSubview(notifyButton)
        notifyButton.setTitle(STLLocalizedString_("Arrival_Notify"), for: .normal)
        notifyButton.backgroundColor = OSSVThemesColors.col_000000(1)
        notifyButton.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(emailInput.snp.bottom).offset(28)
            make.height.equalTo(40)
        }
        notifyButton.titleLabel?.font = UIFont.stl_buttonFont(14)
        notifyButton.rx.tap.subscribe(onNext:{[weak self] in
            if let checkResult = self?.checkEmail(),
               let email = self?.emailInput.text,
               let goodsSn = self?.goodsSn,
                checkResult{
                self?.actionPub.onNext((email,goodsSn))
            }
        }).disposed(by: disposeBag)
        
        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "detail_close_black_zhijiao"), for: .normal)
       
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.top.equalTo(0)
            make.trailing.equalTo(0)
        }
        closeButton.rx.tap.subscribe(onNext:{[weak self] in
            self?.closePub.onNext(())
        }).disposed(by: disposeBag)
        
    }
    
    func checkEmail()->Bool{
        if let email = self.emailInput.text {
            if(!OSSVNSStringTool.isValidEmailString(email)){
                self.emailInput.errorMessage = STLLocalizedString_("Arrival_Notify_Email_Err")
                return false
            }
            self.emailInput.errorMessage = nil
            return true
        }else{
            self.emailInput.errorMessage = STLLocalizedString_("emailEmptyMsg")
            return false
        }
    }


}
