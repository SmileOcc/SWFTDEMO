//
//  YXAreaCodeAlertView.swift
//  uSmartOversea
//
//  Created by Mac on 2019/11/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YXAreaCodeAlertView: UIView {
        
    let hotAreaArr: [Country]? = {
        YXGlobalConfigManager.shareInstance.countryAreaModel?.commonCountry
    }()

    var didSelected: (String)->() = { index in
        
    }
    
    var selectCode = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, selectCode: String) {
        self.init(frame: frame)
        self.selectCode = selectCode
        initView()
    }
    //原来的view
    func initView() {
        
        self.layer.cornerRadius = 30
        self.clipsToBounds = true
        let h: CGFloat = 48.0 //高度固定48
        if let arr = hotAreaArr {
            for i in 0 ..< arr.count {
                let areaModel = arr[i]
                var areaName: String? = areaModel.hk
                switch YXUserManager.curLanguage() {
                case .CN:
                    areaName = areaModel.cn
                case .HK:
                    areaName = areaModel.hk
                case .EN:
                    areaName = areaModel.en
                case .ML:
                    areaName = areaModel.my
                case .TH:
                    areaName = areaModel.th
                default:
                    break
                }
                if let areaName = areaName, let area = areaModel.area {
                    let btn = UIButton(type: .custom)
                    btn.backgroundColor = UIColor.white
                    btn.frame = CGRect(x: 0, y: h*CGFloat(i), width: self.frame.width, height: h)
                    btn.setTitle(String(format: "%@ %@", areaName, area) , for: .normal)
                    if area == selectCode {
                        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
                    }else {
                        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
                    }
                    btn.titleLabel?.font = .systemFont(ofSize: 16)
                    
                    btn.rx.tap.asObservable().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (_) in
                        guard let `self` = self else { return }
                        
                        self.didSelected( area.replacingOccurrences(of: "+", with: "") )
                        
                    }).disposed(by: rx.disposeBag)
                    self.addSubview(btn)
                    
                    //横线
                    let lineView = UIView()
                    lineView.backgroundColor = QMUITheme().separatorLineColor()
                    lineView.frame = CGRect(x: 0.0, y: h - 1, width: btn.frame.width, height: 1.0)
                    btn.addSubview(lineView)
                }
                
            }
            
            //更多国家/地区
            let btn = UIButton(type: .custom)
            btn.backgroundColor = UIColor.white
            btn.frame = CGRect(x: 0.0, y: h * CGFloat(arr.count), width: self.frame.width, height: h)
            btn.setTitle(YXLanguageUtility.kLang(key: "common_more_countries_or_regions") , for: .normal)
            btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 16)
            
            btn.rx.tap.asObservable().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                
                self.didSelected("")
                
            }).disposed(by: rx.disposeBag)
            self.addSubview(btn)
            
            
        }
        
        
    }
    
}
