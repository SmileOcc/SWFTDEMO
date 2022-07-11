//
//  ArrivalAlready.swift
//  Adorawe
//
//  Created by fan wang on 2021/11/19.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift
import YYImage

class ArrivalAlready: UIView {
    
    weak var goodsImageView:YYAnimatedImageView!
    weak var sizeLabel:UILabel!
    weak var goodsName:UILabel!
    
    let disposeBag = DisposeBag()
    var closePub = PublishSubject<Void>()

    override init(frame:CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupSubViews(){
        backgroundColor = UIColor.white
        
        
        let tipLbl = UILabel()
        tipLbl.textColor = OSSVThemesColors.col_696969()
        addSubview(tipLbl)
        ///用attribute
        tipLbl.text = "\(STLLocalizedString_("Arrival_Notify_Already")!)!"
        tipLbl.numberOfLines = 0
        tipLbl.textAlignment = .center
        tipLbl.font = UIFont.systemFont(ofSize: 16)
        tipLbl.snp.makeConstraints { make in
            make.top.equalTo(46)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        
        let goodsImage = YYAnimatedImageView()
        addSubview(goodsImage)
        goodsImageView = goodsImage
        goodsImage.snp.makeConstraints { make in
            make.top.equalTo(tipLbl.snp.bottom).offset(28)
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
        
        
        let notifyButton = UIButton()
        addSubview(notifyButton)
        notifyButton.setTitle(STLLocalizedString_("Arrival_Notify_Continue"), for: .normal)
        notifyButton.backgroundColor = OSSVThemesColors.col_000000(1)
        notifyButton.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(goodsImageView.snp.bottom).offset(40)
            make.height.equalTo(40)
        }
        notifyButton.titleLabel?.font = UIFont.stl_buttonFont(14)
        notifyButton.rx.tap.subscribe(onNext:{[weak self] in
            self?.closePub.onNext(())
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

}
