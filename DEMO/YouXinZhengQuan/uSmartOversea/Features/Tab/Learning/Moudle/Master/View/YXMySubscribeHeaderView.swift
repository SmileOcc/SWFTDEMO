//
//  YXMySubscribeHeaderView.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/14.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXMySubscribeHeaderView: UIView {
    
    var tapKolAction: ((_ item: YXSpecialKOLItem) -> Void)?
    var tapViewAllAction: (() -> Void)?
    
    var dataSource: [YXSpecialKOLItem]? {
        didSet {
            if let list = dataSource {
                scrollView.removeAllSubviews()
                for (index, item) in list.enumerated() {
                    let url = item.photoUrl ?? ""
                    let name = item.nick ?? "--"
                    let itemView = creatItem(photoUrl: url, name: name)
                    itemView.tag = index
                    itemView.frame = CGRect(x: (index*107 + (index + 1)*16), y: 0, width: 112, height: 107)
                    
                    let tap = UITapGestureRecognizer.init { [weak self]_ in
                        self?.tapKolAction?(item)
                    }
                   
                    itemView.addGestureRecognizer(tap)

                    scrollView.addSubview(itemView)
                }
                
                scrollView.contentSize = CGSize(width: list.count*107 + (list.count+1)*16, height: 140)
            }
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = YXLanguageUtility.kLang(key: "nbb_tab_myfollow")
        return label
    }()
    
    lazy var viewAllButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "nbb_viewall"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setImage(UIImage(named: "nb_arrow_more"), for: .normal)
        button.imagePosition = .right
        button.spacingBetweenImageAndTitle = 6
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe { [weak self]_ in
            self?.tapViewAllAction?()
        }

        return button
    }()
    
    lazy var scrollView: UIScrollView = {
        let s = UIScrollView()
        return s
    }()
    
    func creatItem(photoUrl: String, name: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
       
        let imageV = UIImageView()
        imageV.layer.cornerRadius = 35
        imageV.layer.masksToBounds = true
        imageV.sd_setImage(with: URL(string: photoUrl), placeholderImage: UIImage(named: "user_default_photo"), options: [], context: nil)
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .center
        label.text = name
        
        view.addSubview(imageV)
        view.addSubview(label)
        
        imageV.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.top.equalTo(imageV.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }
        
        return view
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(viewAllButton)
        addSubview(scrollView)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        viewAllButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(140)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
//            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
