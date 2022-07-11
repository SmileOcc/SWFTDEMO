//
//  ArrivalSubScribeSuccess.swift
//  Adorawe
//
//  Created by fan wang on 2021/11/16.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import YYImage

class ArrivalSubScribeSuccess: UIView {
    
    weak var thumImage:YYAnimatedImageView!
    weak var tipInfo:UILabel!
    
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
        
        let titleLbl = UILabel()
        addSubview(titleLbl)
        titleLbl.text = "\(STLLocalizedString_("Arrival_Notify_Done")!)!"
        titleLbl.font = UIFont.vivaiaRegularFont(24)
        titleLbl.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(40)
            make.height.equalTo(32)
        }
        
        let tipLbl = UILabel()
        tipLbl.textColor = OSSVThemesColors.col_484848()
        addSubview(tipLbl)
        ///用attribute
        tipLbl.text = STLLocalizedString_("Arrival_Notify_Done_Text")
        tipLbl.numberOfLines = 0
        tipLbl.textAlignment = .center
        tipLbl.snp.makeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(14)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        self.tipInfo = tipLbl
        
        let thumImage = YYAnimatedImageView()
        addSubview(thumImage)
        thumImage.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(tipLbl.snp.bottom).offset(28)
            make.height.width.equalTo(90)
        }
        self.thumImage = thumImage
        
        
        let notifyButton = UIButton()
        addSubview(notifyButton)
        notifyButton.setTitle(STLLocalizedString_("Arrival_Notify_Continue"), for: .normal)
        notifyButton.backgroundColor = OSSVThemesColors.col_000000(1)
        notifyButton.snp.makeConstraints { make in
            make.leading.equalTo(48)
            make.trailing.equalTo(-48)
            make.top.equalTo(thumImage.snp.bottom).offset(40)
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
