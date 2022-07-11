//
//  YXNewStockDeliveredCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import YXKit

class YXNewStockDeliveredCell: UITableViewCell {
    
    //MARK: initialization Method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initializeViews()
        asyncRender()
    }
    
    func initializeViews() {

        let margin: CGFloat = 18
        //let innerMargin: CGFloat = 14
        contentView.addSubview(belowView)
        contentView.backgroundColor = QMUITheme().backgroundColor()
        belowView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.top.equalToSuperview().offset(7)
            make.bottom.equalToSuperview().offset(-7)
        }
        
        belowView.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        backView.addSubview(nameLabel)
        backView.addSubview(countLabel)
        backView.addSubview(arrowImageView)
        backView.addSubview(ecmRedDotView)
       
  
        arrowImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.right.equalTo(arrowImageView.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        ecmRedDotView.snp.makeConstraints { (make) in
            make.right.equalTo(countLabel.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(countLabel.snp.left).offset(-10)
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.belowView.layer.shadowPath = UIBezierPath.init(rect: self.belowView.bounds.offsetBy(dx: 0, dy: 4)).cgPath
    }
    
    func asyncRender() {
        DispatchQueue.main.async {
            self.belowView.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
            self.belowView.layer.cornerRadius = 10
            self.belowView.layer.borderColor = UIColor.qmui_color(withHexString: "#F7F7F7")?.cgColor
            self.belowView.layer.borderWidth = 1
            self.belowView.layer.shadowColor = QMUITheme().separatorLineColor().cgColor
            //self.belowView.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.belowView.layer.shadowOpacity = 1.0
            //self.belowView.layer.shadowRadius = 4
            
            self.backView.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
            self.backView.layer.cornerRadius = 10
            self.backView.layer.masksToBounds = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lazy setter and getter
    
    lazy var belowView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var backView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var ecmRedDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.isHidden = true
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "delivered_company")
        return label
    }()
    
    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "stock_r_arrow")
        imageView.alpha = 0.4
        return imageView
    }()
    
    
}


