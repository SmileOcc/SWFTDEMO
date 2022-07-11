//
//  YXElementTableViewCell.swift
//  uSmartOversea
//
//  Created by suntao on 2021/3/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXElementTableViewCell: UITableViewCell {
    
    lazy var nameLab: UILabel = {
       let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = QMUITheme().textColorLevel2()
        lab.text = ""
        lab.textAlignment = .left
        
        return lab
    }()
    
    lazy var colorView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().themeTextColor()
        view.layer.cornerRadius = 2.0
        return view
    }()
    
    lazy var gradienaLayer: CAGradientLayer = {
       let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.locations = [0,1]
        layer.colors = [UIColor.qmui_color(withHexString: "#535AF0")!.cgColor, UIColor.qmui_color(withHexString: "#0EC0F1")!.cgColor];
        
        return layer
    }()
    
    lazy var rationLab: UILabel = {
       let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lab.textColor = QMUITheme().textColorLevel1()
        lab.text = ""
        lab.textAlignment = .left
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.5
        
        return lab
    }()
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.selectionStyle = .none
        contentView.backgroundColor = QMUITheme().foregroundColor()
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(nameLab)
        contentView.addSubview(colorView)
        contentView.addSubview(rationLab)
        
        nameLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview()
            make.height.equalTo(18)
        }

        colorView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(nameLab.snp.bottom).offset(2)
            make.width.equalTo(0)
            make.height.equalTo(10)
        }

        rationLab.snp.makeConstraints { (make) in
            make.left.equalTo(colorView.snp.right).offset(4)
            make.centerY.equalTo(colorView)
            make.height.equalTo(16)
        }
    }


   
    func refreshUI(indexPath: IndexPath, model:YXUSElementItemModel, maxValue: Double) {

        var symbol = ""
        if let code = model.secuCodeElement, !code.isEmpty {
            symbol = "(\(code))"
        }
        self.nameLab.text = symbol + (model.secuElement ?? "")

        let ration: String = String(format: "%.2f%%", model.investmentRationElement)
        self.rationLab.text = ration
        
        let colorSumWidth: Double = Double(YXConstant.screenWidth - 76)
        let base = maxValue == 0 ? 100.0 : maxValue
        var colorWidth: UInt = UInt((colorSumWidth * model.investmentRationElement/base))
        if colorWidth < 2 {
            colorWidth = 1
        }

        colorView.snp.updateConstraints { (make) in
            make.width.equalTo(colorWidth)
        }
        
    }
    

         
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
