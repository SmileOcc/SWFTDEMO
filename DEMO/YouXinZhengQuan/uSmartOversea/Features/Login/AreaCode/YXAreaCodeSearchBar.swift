//
//  YXAreaCodeSearchBar.swift
//  uSmartOversea
//
//  Created by Mac on 2019/11/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
//44的高度
class YXAreaCodeSearchBar: UIView {
    lazy var textField :UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf.textColor = QMUITheme().textColorLevel1()
        tf.clearButtonMode = .whileEditing
        tf.placeholder = "Search"
        return tf
    }()
    
    lazy var searchBtn: UIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setImage(UIImage(named: "area_code_search"), for: .normal)
        btn.rx.tap.asObservable().subscribe(onNext: {[weak self] (_) in
            self?.textField.becomeFirstResponder()
        }).disposed(by: self.rx.disposeBag)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = QMUITheme().blockColor()
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        let horiSpace: CGFloat = 12
        
        addSubview(searchBtn)
        addSubview(textField)
        
        searchBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horiSpace)
            make.width.equalTo(22)
            make.centerY.equalToSuperview()
        }
        
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(searchBtn.snp.right).offset(4)
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-horiSpace)
            make.bottom.equalToSuperview()
        }
        

        _ = textField.rx.text.throttle(RxTimeInterval.seconds(0), scheduler: MainScheduler.instance).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](text) in
//            guard let `self` = self else { return }
//            if !(text?.isEmpty ?? true) {//text?.count ?? 0 > 0
//                self.searchBtn.isHidden = true
//                self.textField.snp.updateConstraints { (make) in
//                    make.trailing.equalToSuperview().offset( -horiSpace )
//                }
//            }else {
 //               self.searchBtn.isHidden = false
//                self.textField.snp.updateConstraints { (make) in
//                    make.trailing.equalToSuperview().offset( -(frame.size.height + horiSpace) )
//                }
 //           }
            
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
