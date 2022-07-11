//
//  YXInfoRecomNoteView.swift
//  uSmartOversea
//
//  Created by Mac on 2020/3/30.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXInfoRecomNoteCell: UITableViewCell {
    
    let bgView:UIView = UIView()

    let leftImgView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "info_recommand_note_bg")
        return view
    }()
    
    lazy var typeLab: UILabel = {
        let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.text = YXLanguageUtility.kLang(key: "stockST_column_internal_reference")
        lab.numberOfLines = 1
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.3
        return lab
    }()
    
    lazy var tipLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.qmui_color(withHexString: "#2B4F80")
        lab.font = .systemFont(ofSize: 8, weight: .medium)
        lab.numberOfLines = 1
        lab.layer.cornerRadius = 7
        lab.layer.masksToBounds = true
        lab.textAlignment = .center
        lab.text = YXLanguageUtility.kLang(key: "news_recommend_pay")
        lab.backgroundColor = UIColor.qmui_color(withHexString: "#FFCD47")
        return lab
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = .systemFont(ofSize: 12)
        lab.numberOfLines = 2
        return lab
    }()
    
    var noteBlock: (() -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initUI() {
        
        
        self.backgroundColor = QMUITheme().backgroundColor()

        addShadowLayer(view: bgView)
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        
        bgView.addSubview(leftImgView)
        leftImgView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
        }
        
        leftImgView.addSubview(typeLab)
        typeLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(7)
        }
        
        leftImgView.addSubview(tipLab)
        tipLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(typeLab.snp.bottom).offset(5)
            if YXUserManager.isENMode() {
                make.width.equalTo(82)
            } else {
                make.width.equalTo(68)
            }
            make.height.equalTo(14)
        }
        
        bgView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(9)
            make.bottom.equalToSuperview().offset(-9)
            make.left.equalTo(leftImgView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        self.rx.tapGesture().subscribe(onNext: {[weak self] (tap:UITapGestureRecognizer) in
            guard let `self` = self else { return }
            if let block = self.noteBlock {
                block()
            }
        }).disposed(by: self.rx.disposeBag)

    }
    
    func addShadowLayer(view: UIView) {
        view.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
        view.layer.cornerRadius = 8
        view.layer.borderColor = QMUITheme().separatorLineColor().cgColor
        view.layer.borderWidth = 1
        
        view.layer.shadowColor = QMUITheme().separatorLineColor().cgColor
        view.layer.shadowOpacity = 1.0
        view.layer.shadowOffset = CGSize.init(width: 0, height: -2)
        view.layer.shadowRadius = 10
    }
}
