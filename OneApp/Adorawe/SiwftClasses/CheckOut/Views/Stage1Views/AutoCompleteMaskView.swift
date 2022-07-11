//
//  AutoCompleteMaskView.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/8.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AutoCompleteMaskView: UIView {
    let disposeBag = DisposeBag()
    
    lazy var isShow:PublishSubject<Bool> = {
        let isShow = PublishSubject<Bool>()
        isShow.subscribe(onNext:{ show in
            self.isHidden = !show
        }).disposed(by: disposeBag)
        return isShow
    }()
    
    weak var navBtn:UIButton!
    weak var inputBtn:UIButton!

    override init(frame: CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    ///搜索图标  说明文字  定位按钮
    func setupViews(){
        backgroundColor = OSSVThemesColors.col_FFFFFF()
        let searchIcon = UIImageView()
        searchIcon.image = UIImage(named: "checkout_search")
        addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.leading.equalTo(10)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        let navButton = UIButton()
        navButton.setImage( UIImage(named: "checkout_nav"), for: .normal)
        addSubview(navButton)
        navButton.snp.makeConstraints { make in
            make.trailing.equalTo(0)
            make.centerY.equalTo(self.snp.centerY)
        }
        self.navBtn = navButton
        
        let displayLbl = UILabel()
        displayLbl.text = STLLocalizedString_("StartTypingAddress")
        displayLbl.font = UIFont.boldSystemFont(ofSize: 14)
        displayLbl.textColor = OSSVThemesColors.col_000000(0.5)
        addSubview(displayLbl)
        displayLbl.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon.snp.trailing).offset(6)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        let touchButton = UIButton()
        addSubview(touchButton)
        touchButton.snp.makeConstraints { make in
            make.leading.equalTo(0)
            make.trailing.equalTo(navButton.snp.trailing)
            make.bottom.equalTo(0)
        }
        self.inputBtn = touchButton
    }

}
