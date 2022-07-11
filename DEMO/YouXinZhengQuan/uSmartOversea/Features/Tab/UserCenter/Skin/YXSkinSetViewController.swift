//
//  YXSkinSetViewController.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2022/3/21.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit


class SkinSetModel: NSObject {
    var title = ""
    var isSelect = false
    var desTitle = ""
}

class SkinSetCell: UITableViewCell {
    
    
    var model: SkinSetModel? {
        
        didSet {
            if let model = model {
                titleLabel.text = model.title
                descLabel.text = model.desTitle
                if model.isSelect {
                    iconView.image = UIImage(named: "dot_selected")
                } else {
                    iconView.image = UIImage(named: "unselected_new")
                }
            }
        }
    }
    
    let titleLabel = UILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "")
    let descLabel = UILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: "")
    var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = QMUITheme().separatorLineColor()
        return line
    }()
    let iconView = UIImageView.init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        backgroundColor = QMUITheme().foregroundColor()
        iconView.image = UIImage(named: "unselected_new")
        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(lineView)
        addSubview(iconView)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(20)
        }
        descLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.height.equalTo(20)
        }
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
        }
        iconView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.width.height.equalTo(20)
            make.centerY.equalTo(titleLabel)
        }
    }
}

class YXSkinSetViewController: YXHKTableViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXSkinSetViewModel!
    
    lazy var dataSource: [[SkinSetModel]] = {
        return self.getList()
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        bindViewModel()
        reloadData()
    }
    override var pageName: String {
        return "Skin"
    }
    func initUI() {
        
        tableView.separatorStyle = .none

        self.view.backgroundColor = QMUITheme().foregroundColor()
        self.tableView.backgroundColor = QMUITheme().foregroundColor()
        self.title = YXLanguageUtility.kLang(key: "theme_title")
    }
    
    func bindViewModel() {

    }
    
    func getList() -> [[SkinSetModel]] {
        let model1 = SkinSetModel()
        model1.title = YXLanguageUtility.kLang(key: "theme_follow_system")
        model1.desTitle = YXLanguageUtility.kLang(key: "theme_follow_system_des")
        
        let model2 = SkinSetModel()
        model2.title = YXLanguageUtility.kLang(key: "theme_white")
        
        let model3 = SkinSetModel()
        model3.title = YXLanguageUtility.kLang(key: "theme_dark")
        
        let skin = YXThemeTool.currentSkin()
        if skin == .follow {
            model1.isSelect = true
        } else if skin == .light {
            model2.isSelect = true
        } else {
            model3.isSelect = true
        }
                        
        return [[model1, model2, model3]]
    }
    
    func reloadData() {
        dataSource = getList()
        self.tableView.reloadData()
    }
        
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateNavigationBarAppearance()
    }

}

extension YXSkinSetViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = SkinSetCell(style: .default, reuseIdentifier: "SkinSetCell")
        cell.model = dataSource[indexPath.section][indexPath.row]
        cell.lineView.isHidden = false
        if indexPath.row == dataSource[indexPath.section].count - 1 {
            cell.lineView.isHidden = true
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = dataSource[indexPath.section][indexPath.row]
        if model.isSelect {
            return
        } else {
            let type = SkinType.init(rawValue: UInt32(indexPath.row)) ?? .follow
            YXThemeTool.setSkinWith(type)
            self.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiSkinChange), object: nil)
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 84
        }
        return 52
    }
    
    
    
    
}


