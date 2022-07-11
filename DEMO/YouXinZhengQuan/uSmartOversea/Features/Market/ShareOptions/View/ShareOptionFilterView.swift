//
//  ShareOptionFilterView.swift
//  uSmartOversea
//
//  Created by lennon on 2022/6/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class OptionSectionDataModel:NSObject{
    var title:String
    var rawValue:Any?
    init(title:String,rawValue:Any? = nil) {
        self.title = title
        self.rawValue = rawValue
    }
}

class OptionSectionModel:NSObject {
    var sectionTitle:String
    var datas:[OptionSectionDataModel]
    var index:Int
    
    init(sectionTitle:String,datas:[OptionSectionDataModel],index:Int,rawValues:[Any] = []) {
        self.sectionTitle = sectionTitle
        self.datas = datas
        self.index = index
    }
    
    func selectItem() -> OptionSectionDataModel? {
        return  self.datas.indices.contains(index) ? self.datas[index] : nil
    }
}

class ShareOptionSectionHeader:UIView {
    
    lazy var titleLabl:UILabel = {
        let lab = UILabel.init(frame: .zero)
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = .systemFont(ofSize: 14)
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabl)
        titleLabl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ShareOptionSectionGridView: UIView,YXStockDetailSubHeaderViewProtocol {
        
    var selectCallBack: ((_ model: OptionSectionModel) -> ())?

    var  selectTypeBtn:QMUIButton? = nil
    
    var defaultSelectIndex:Int = 0
        
    let columnCount = 4
    
    var model: OptionSectionModel
    
    lazy var headerView:ShareOptionSectionHeader = {
        let view = ShareOptionSectionHeader.init(frame: .zero)
        return view
    }()
    
    lazy var gridView:QMUIGridView = {
        let view = QMUIGridView.init(column: columnCount, rowHeight: 30)!
        view.backgroundColor = .clear
        view.padding = UIEdgeInsets.init(top: 12, left: 17, bottom: 12, right: 17)
        view.separatorWidth = 10
        view.separatorColor = .clear
        return view
    }()
    
    init(frame: CGRect, section:OptionSectionModel) {
        self.defaultSelectIndex = section.index
        self.model = section
        super.init(frame: frame)
                
        for (i, data) in section.datas.enumerated() {
            let btn = QMUIButton.init()
            btn.setTitle(data.title, for: .normal)
            btn.layer.cornerRadius = 4
            btn.clipsToBounds = true
            btn.titleLabel?.font = .systemFont(ofSize: 12)
            btn.titleLabel?.adjustsFontSizeToFitWidth = true
            btn.titleLabel?.minimumScaleFactor = 0.6
            btn.layer.borderColor = UIColor.themeColor(withNormal: UIColor.qmui_color(withHexString: "#EAEAEA")!, andDarkColor: UIColor.qmui_color(withHexString: "#8C8D99")!).cgColor
            btn.layer.borderWidth = 1.0
            btn.setTitleColor(UIColor.themeColor(withNormal: UIColor.qmui_color(withHexString: "#414FFF")!, andDarkColor: UIColor.qmui_color(withHexString: "#D3D4E6")!), for: .selected)
            btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
            btn.setBackgroundImage(UIImage.yx_registDynamicImage(with: .white, darkColor: QMUITheme().popupLayerColor()), for: .normal)
            btn.setBackgroundImage(UIImage.yx_registDynamicImage(with: UIColor.qmui_color(withHexString: "#ECEDFF")!, darkColor: QMUITheme().mainThemeColor()), for: .selected)
            
            if i == defaultSelectIndex {
                self.selectTypeBtn = btn;
                btn.layer.borderColor = UIColor.clear.cgColor
                btn.isSelected = true
            }
            btn.tag = i;
            btn.titleLabel?.adjustsFontSizeToFitWidth = true

            btn.qmui_tapBlock = { [weak self] sender in
                guard let `self` = self, let b = sender, let btn = b as? QMUIButton, !btn.isSelected else { return }
                btn.isSelected = true
                btn.layer.borderColor = UIColor.clear.cgColor
                
                self.selectTypeBtn?.isSelected = false
                self.selectTypeBtn?.layer.borderColor = UIColor.themeColor(withNormal: UIColor.qmui_color(withHexString: "#EAEAEA")!, andDarkColor: UIColor.qmui_color(withHexString: "#8C8D99")!).cgColor
                self.selectTypeBtn? = btn
                self.model.index = btn.tag
                self.selectCallBack?(self.model)
            }
            gridView.addSubview(btn)
        }
        
        addSubview(headerView)
        addSubview(gridView)
        
        var row = 0
        if section.datas.count >= columnCount {
            row = section.datas.count / columnCount + (section.datas.count % columnCount > 0 ? 1 : 0)
        } else {
            row = 1
        }
        

        let gridViewHeight =  row * 30 +  (row - 1) * 10 + 24
        let headerViewHeight = 28
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(headerViewHeight)
        }
        headerView.titleLabl.text = section.sectionTitle
        
        gridView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(gridViewHeight)
        }
        contentHeight = CGFloat(gridViewHeight + headerViewHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//期权pop设置
class ShareOptionSettingView: UIView,YXStockDetailHeaderViewProtocol {
        
    var heightDidChange: (() -> Void)?
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    var sections:[OptionSectionModel]
    
    init(frame: CGRect,sections:[OptionSectionModel]) {
        self.sections = sections
        super.init(frame: frame)
        backgroundColor = QMUITheme().popupLayerColor()
        let scrollView = UIScrollView.init()
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
      
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.width.equalTo(YXConstant.screenWidth)
            make.bottom.equalToSuperview().offset(-self.bottomMargin)
            make.top.equalToSuperview().offset(self.topMargin)
        }
        
        for section in sections {
            let sectionView = ShareOptionSectionGridView.init(frame: .zero, section: section)
            stackView.addArrangedSubview(sectionView)
        }
        configStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSelectStyle() -> YXShareOptionsListStyle? {
        guard sections.count >= 2 else { return nil }
        if let style = sections[0].selectItem(), let value = style.rawValue as? YXShareOptionsListStyle {
           return  value
        }
        return nil
    }
    
    func getSelectStrike() -> YXShareOptinosCount? {
        guard sections.count >= 2 else { return nil }
        if let strike = sections[1].selectItem(), let value = strike.rawValue as? YXShareOptinosCount {
            return value
        }
        return nil
    }
    
}

//期权底部设置toolbar
class ShareOptionFilterView: UIView {
    
    let titles:[String] = [YXShareOptionsType.all.title,YXShareOptionsType.call.title,YXShareOptionsType.put.title]
    
    var  selectTypeBtn:QMUIButton? = nil
    
    var defaultSelectIndex:Int
    
     var selectCallBack: ((_ type: YXShareOptionsType) -> ())?

    var changeStyleCallBack: (() -> ())?
    
    lazy var showStyleBtn:QMUIButton = {
        let btn = QMUIButton.init(frame: .zero)
        btn.setImage(UIImage.init(named: "optionStyle"), for: .normal)
        btn.qmui_tapBlock = { [weak self] _ in
            self?.changeStyleCallBack?()
        }
        return btn
    }()
    
    lazy var filterGridView:QMUIGridView = {
        let view = QMUIGridView.init(column: 3, rowHeight: 30)!
        view.backgroundColor = .clear
        view.padding = UIEdgeInsets.init(top: 12, left: 17, bottom: 12, right: 17)
        view.separatorWidth = 11
        view.separatorColor = .clear
        return view
    }()
    
    init(frame: CGRect,defaultSelectIndex:Int) {
        self.defaultSelectIndex = defaultSelectIndex
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = QMUITheme().foregroundColor()
        for (i, title) in titles.enumerated() {
            let btn = QMUIButton.init()
            btn.setTitle(title, for: .normal)
            btn.layer.cornerRadius = 4
            btn.clipsToBounds = true
            btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            btn.titleLabel?.adjustsFontSizeToFitWidth = true
            btn.titleLabel?.minimumScaleFactor = 0.6
            btn.layer.borderColor = QMUITheme().pointColor().cgColor
            btn.layer.borderWidth = 1.0
            btn.setTitleColor(UIColor.themeColor(withNormal: UIColor.qmui_color(withHexString: "#414FFF")!, andDarkColor: UIColor.qmui_color(withHexString: "#D3D4E6")!), for: .selected)
            btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
            btn.setBackgroundImage(UIImage.tabItemNoramalDynamicImage(), for: .normal)
            btn.setBackgroundImage(UIImage.tabItemSelectedDynamicImage(), for: .selected)
            
            if i == defaultSelectIndex {
                self.selectTypeBtn = btn;
                btn.layer.borderColor = UIColor.clear.cgColor
                btn.isSelected = true
            }
            btn.tag = i;
            btn.titleLabel?.adjustsFontSizeToFitWidth = true

            btn.qmui_tapBlock = { [weak self] sender in
                guard let `self` = self, let b = sender, let btn = b as? QMUIButton, !btn.isSelected else { return }
                btn.isSelected = true
                btn.layer.borderColor = UIColor.clear.cgColor
                self.selectTypeBtn?.isSelected = false
                self.selectTypeBtn?.layer.borderColor = QMUITheme().pointColor().cgColor
                self.selectTypeBtn? = btn
                if let type = YXShareOptionsType.init(rawValue: btn.tag) {
                    self.selectCallBack?(type)
                }
            }
            filterGridView.addSubview(btn)
        }
        
        addSubview(filterGridView)
        addSubview(showStyleBtn)
        
        filterGridView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-37)
        }
        
        showStyleBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
    }
}
