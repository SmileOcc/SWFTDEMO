//
//  YXPreferenceSetTableViewCell.swift
//  uSmartOversea
//
//  Created by Mac on 2019/8/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

class YXPreferSetSmartTableViewCell: UITableViewCell {
    
    var titleLab: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = YXLanguageUtility.kLang(key: "initial_settings_smart_sorting")
        return label
    }()
    var switchView: UISwitch = {
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = QMUITheme().mainThemeColor()
//        switchView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        return switchView
    }()
    
    var descLab: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "initial_settings_smart_sorting_desc")
        return label
    }()

    var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        return lineView
    }()
    
    //MARK: initialization Method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.translatesAutoresizingMaskIntoConstraints = true
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initializeViews() {
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(19)
            make.height.equalTo(16)
        }
        
        contentView.addSubview(switchView)
        switchView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalTo(titleLab)
        }
        
        contentView.addSubview(descLab)
        descLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
           // make.bottom.equalToSuperview().offset(-12)
            make.top.equalTo(titleLab.snp.bottom).offset(9)
        }
        
        
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self).offset(18)
            make.right.equalTo(self).offset(-18)
            make.height.equalTo(0.5)
        }
    }

//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        var size = super.sizeThatFits(size)
//        size.height = 19 + 9 + 12
//        size.height += titleLab.sizeThatFits(size).height
//        size.height += descLab.sizeThatFits(size).height
//        return size
//    }
    
    func reloadData(_ title: String, desc: String) {
        titleLab.text = title
        descLab.text = desc
    }
}

class YXPreferSetQuoteTableViewCell: UITableViewCell {
    let disposeBag = DisposeBag()
    //选中的block
    var selectBlock: ((_ type: YXQuoteChartHkType) -> Void)?
    
    var simpliLineView: UIView!
    var simpliKView: UIView!
    var advancedKView: UIView!
    
    var titleLab: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = YXLanguageUtility.kLang(key: "initial_settings_stock_quote")
        return label
    }()
    
    var kItemHeight: CGFloat = 130
    
    var lastSelectView: UIView?

    //MARK: initialization Method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.translatesAutoresizingMaskIntoConstraints = true
        initializeViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initializeViews() {
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(17)
            make.top.equalToSuperview().offset(19)
            make.right.equalToSuperview().offset(-17)
        }
        
        let horMargin: CGFloat = uniHorLength(35)
        let spaceMargin: CGFloat = uniHorLength(25)
        let itemWidth = (YXConstant.screenWidth - horMargin * 2 - spaceMargin) / 2.0
        kItemHeight = itemWidth * 120 / 140.0
        kItemHeight += 15
        
        simpliLineView = buildCellView(with: "settings_simplified_line", YXLanguageUtility.kLang(key: "initial_settings_simplified_line"), type: .simplifiedLine)
        
        simpliKView = buildCellView(with: "settings_simplified_k", YXLanguageUtility.kLang(key: "initial_settings_simplified_k"), type: .simplifiedK)
        
        advancedKView = buildCellView(with: "settings_advanced_k", YXLanguageUtility.kLang(key: "initial_settings_advanced"), type: .advanced)
        
        simpliLineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin)
            make.top.equalTo(titleLab.snp.bottom).offset(20)
            make.width.equalTo(itemWidth)
            make.height.equalTo(kItemHeight)
        }
        simpliKView.snp.makeConstraints { (make) in
            make.left.equalTo(simpliLineView.snp.right).offset(spaceMargin)
            make.right.equalToSuperview().offset(-horMargin)
            make.top.equalTo(simpliLineView)
            make.width.equalTo(itemWidth)
            make.height.equalTo(kItemHeight)
        }
        advancedKView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin)
            make.top.equalTo(simpliLineView.snp.bottom).offset(spaceMargin)
            make.bottom.equalToSuperview().offset(-52)
            make.width.equalTo(itemWidth)
            make.height.equalTo(kItemHeight)
        }
    }
    
    fileprivate func buildCellView(with imgName: String, _ title: String, type: YXQuoteChartHkType) -> UIView {
        let backView = UIView()
        backView.backgroundColor = QMUITheme().foregroundColor()
        // 140.0x97.0
        let imgView = UIImageView(image: UIImage(named: imgName))
        backView.addSubview(imgView)
        imgView.snp.makeConstraints {[weak imgView] (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-11)
            make.width.equalTo(imgView!.snp.height).multipliedBy(140.0/97.0)
        }
        
        let label = UILabel()
        label.text = title
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel2()
        label.textAlignment = .center
        backView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(imgView.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        backView.tag = type.rawValue
        contentView.addSubview(backView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickAction))
        backView.addGestureRecognizer(tap)
        backView.isUserInteractionEnabled = true
        return backView
    }
    @objc func clickAction(tapGesture: UITapGestureRecognizer) {
        guard let view = tapGesture.view else { return }
        self.selectBlock?(YXQuoteChartHkType(rawValue: view.tag) ?? .simplifiedLine)
        self.asyncRender(select: view, unselect: self.lastSelectView)
    }
    //异步渲染
    fileprivate func asyncRender(select: UIView, unselect: UIView?) {
        DispatchQueue.main.async {
            select.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
            select.layer.cornerRadius = 6
            select.layer.borderColor = UIColor.qmui_color(withHexString: "#0083FF")?.cgColor
            select.layer.borderWidth = 1
            select.layer.masksToBounds = true
            
            self.lastSelectView = select
            
            if let unselectView = unselect, unselectView != select {
                unselectView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = 19
        size.height += titleLab.sizeThatFits(size).height
        
        size.height += 20
        size.height += kItemHeight
        size.height += 25
        size.height += kItemHeight
        size.height += 52
        return size
    }
    
    func reloadData(_ quoteChartHk: YXQuoteChartHkType) {
        switch quoteChartHk {
        case .simplifiedLine,
             .unknown:
            asyncRender(select: simpliLineView, unselect: self.lastSelectView)
        case .simplifiedK:
            asyncRender(select: simpliKView, unselect: self.lastSelectView)
        case .advanced:
            asyncRender(select: advancedKView, unselect: self.lastSelectView)
        }
        
    }
}
