//
//  YXBrokerSelectView.swift
//  uSmartOversea
//
//  Created by ysx on 2021/11/9.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

extension YXBrokersBitType{
    var logoImage : String{
        switch self {
        case .nz:
            return "uSmartNZ"
        case .sg:
            return "uSmartSG"
        default:
            return ""
        }
    }
    
    var text : String{
        switch self {
        case .nz:
            return "uSMART(NZ)"
        case .sg:
            return "uSMART(SG)"
        default:
            return ""
        }
    }
    
}

class YXBrokerSelectView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var didChoose:((_ type:YXBrokersBitType)->())?
    var selectBroker : YXBrokersBitType = .nz {
        didSet{
            selectView.image = UIImage.init(named: selectBroker.logoImage)
            selectView.size = selectView.image?.size ?? .zero
        }
    }
    
    
    lazy var selectView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    func showPop(from:UIView) {
        UIApplication.shared.keyWindow?.endEditing(true)
        for view in self.newMenuView.subviews {
            if let subBtn = view as? UIButton {
                if let title = subBtn.currentTitle, title == self.selectBroker.text {
                    subBtn.isSelected = true
                } else {
                    subBtn.isSelected = false
                }
            }
        }
        if YXConstant.appTypeValue == .OVERSEA {
           // self.popover.show(self.newMenuView, from: from)
            self.popover.show(self.newMenuView, from: self)
        }
    }
    
    func initUI(){
        addSubview(selectView)
        selectView.frame = self.bounds
//        selectView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rowView(_ title:String) -> QMUIButton {
        let btn = QMUIButton()
        btn.imagePosition = .right
       // btn.setImage(UIImage.init(named: "icon_next"), for: .normal)
       // btn.setImage(UIImage.init(named: "icon_next"), for: .selected) //icon_select
        btn.setTitle(title, for: .normal)
        btn.setTitle(title, for: .selected)
        btn.setTitleColor(QMUITheme().mainThemeColor(), for: .selected)
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.spacingBetweenImageAndTitle = 16
        return btn
    }

    
    
    private lazy var popover: YXStockPopover = {
        let popover = YXStockPopover()
        
        return popover
    }()
    
    private lazy var newMenuView: UIView = {
        let menuView = UIView.init()
        menuView.clipsToBounds = true
        menuView.backgroundColor = QMUITheme().popupLayerColor()
        let typeArr:[YXBrokersBitType] = [.nz, .sg]
        menuView.frame = CGRect.init(x: 0, y: 0, width: 121, height: typeArr.count * 48+1)
        
       
        for i in 0..<typeArr.count {
            let type = typeArr[i]
            let btn = self.rowView(type.text)
            btn.tag = i
            btn.frame = CGRect.init(x: 0, y: i*48, width: 121, height: 48)
            btn.addBlock(for: .touchUpInside) {[weak self] _ in
                self?.popover.dismiss()
            //    self?.selectBroker = type
                self?.didChoose?(type)
            }
            menuView.addSubview(btn)
            if i < (typeArr.count - 1) {
                let lineView = UIView.init(frame: CGRect.init(x: 7, y: (i + 1) * 48, width: 109, height: 1))
                lineView.backgroundColor = QMUITheme().pointColor()
                menuView.addSubview(lineView)
            }
        }
        
        return menuView
    }()
    
    
}

