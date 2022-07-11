//
//  YXSearchRecommendView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator

class YXSearchRecommendView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().itemBorderColor()
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var itemStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    var navigator: NavigatorServicesType?
    
    var recommend: YXRecommend? {
        didSet {
            if let recommend = recommend {
                titleLabel.text = recommend.title
                subTitleLabel.text = recommend.subTitle
                
                itemStackView.subviews.forEach { (subView) in
                    subView.removeFromSuperview()
                }
                recommend.items?.forEach({ (item) in
                    let itemView = YXSearchRecommendItemView()
                    itemView.titleLabel.text = item.title
                    itemView.subTitleLabel.text = item.subTitle
                    itemStackView.addArrangedSubview(itemView)
                    
                    itemView.snp.makeConstraints { (make) in
                        make.height.equalTo(86)
                    }
                    
                    itemView.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
                        guard let strongSelf = self else { return }
                        if ges.state == .ended, let navigator = strongSelf.navigator  {
                            let banner = BannerList(bannerID: nil,
                                                    adType: nil,
                                                    adPos: nil,
                                                    pictureURL: nil,
                                                    originJumpURL: item.jumpURL,
                                                    newsID: nil,
                                                    bannerTitle: nil,
                                                    tag: "0",
                                                    jumpType: YXInfomationType(rawValue: item.jumpType ?? 0)?.converNewType()
                                                    )
                            YXBannerManager.goto(withBanner: banner, navigator: navigator)
                        }
                    }).disposed(by: rx.disposeBag)
                    
                    DispatchQueue.main.async {
                        itemView.iconView.sd_setImage(with: URL(string: item.icon ?? ""), placeholderImage: UIImage(named: "multi_asset_default"), options: [], context: [:])
                    }
                })
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(itemStackView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalTo(10)
            make.height.equalTo(22)
        }
        
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        
        itemStackView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(subTitleLabel.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

class YXSearchRecommendItemView: UIView {
    
    lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        return iconView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    lazy var belowView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var bgView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(belowView)
        belowView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalTo(10)
            make.height.equalTo(76)
        }
        
        belowView.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bgView.addSubview(iconView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(subTitleLabel)
        
        iconView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(18)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-18)
            make.top.equalTo(10)
            make.height.equalTo(20)
        }
        
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        
        asyncRender()
    }
    
    func asyncRender() {
        DispatchQueue.main.async {
            self.belowView.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
            self.belowView.layer.cornerRadius = 10
            self.belowView.layer.borderColor = QMUITheme().separatorLineColor().cgColor
            self.belowView.layer.borderWidth = 1
            self.belowView.layer.shadowColor = QMUITheme().separatorLineColor().cgColor
            self.belowView.layer.shadowOpacity = 1.0
            
            self.bgView.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
            self.bgView.layer.cornerRadius = 10
            self.bgView.layer.masksToBounds = true
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.belowView.layer.shadowPath = UIBezierPath.init(rect: self.belowView.bounds.offsetBy(dx: 0, dy: 4)).cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
