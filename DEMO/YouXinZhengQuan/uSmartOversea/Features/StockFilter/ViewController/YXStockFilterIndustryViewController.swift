//
//  YXStockFilterIndustryViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXStockFilterIndustryViewController: YXHKTableViewController, HUDViewModelBased {

    typealias ViewModelType = YXStockFilterIndustryViewModel
    var viewModel: YXStockFilterIndustryViewModel!
    var networkingHUD: YXProgressHUD! = YXProgressHUD()

    let industryCodeViewCellID = "industryCodeViewCellID"
    let industryCodeSecHeaderViewID = "industryCodeSecHeaderViewID"

    lazy var codeSearchBar: YXAreaCodeSearchBar = {
        let bar = YXAreaCodeSearchBar(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 44))
        return bar
    }()

    lazy var emptyLab: QMUILabel = {
        let lab = QMUILabel()
        lab.text = YXLanguageUtility.kLang(key: "common_no_result")
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = QMUITheme().textColorLevel2()
        lab.isHidden = true
        return lab
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        setupNavigationBar()
        bindHUD()

        self.viewModel.parseIndustryData()

        if self.viewModel.totalIndustryDic.isEmpty {
            YXStockDetailRequestHelper.checkIndustryUpdate {
                [weak self] in
                guard let `self` = self else { return }
                self.viewModel.parseIndustryData()

                if self.viewModel.dataSource.count == 0 {
                    self.emptyLab.isHidden = false
                } else {
                    self.emptyLab.isHidden = true
                }

                self.tableView.reloadData()
            }
        }
        bindViewModel()
    }
    //重写tableView布局，
    override func layoutTableView() {

    }

    func initUI() {
        self.title = YXLanguageUtility.kLang(key: "industry")

        self.view.backgroundColor = QMUITheme().backgroundColor()

        self.view.addSubview(codeSearchBar)
        codeSearchBar.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(YXConstant.navBarHeight())
            make.height.equalTo(44)
        }


        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        tableView.separatorStyle = .none
        tableView.register(YXIndustryCodeTableViewCell.self, forCellReuseIdentifier: industryCodeViewCellID)
        tableView.register(YXIndustrySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: industryCodeSecHeaderViewID)
        tableView.snp.remakeConstraints {[weak self] (make) in
            guard let strongSelf = self else {return}
            make.left.right.equalTo(strongSelf.view)
            make.bottom.equalToSuperview()
            make.top.equalTo(strongSelf.codeSearchBar.snp.bottom)
            //make.top.equalTo(YXConstant.navBarHeight())
        }

        self.emptyLab.isHidden = true
        view.addSubview(self.emptyLab)
        self.emptyLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.tableView).offset(80)
        }

        // 索引
        // 设置索引值颜色
        self.tableView.sectionIndexColor = QMUITheme().holdMark()   //#1E93F3
        // 设置选中时的索引背景颜色
        self.tableView.sectionIndexTrackingBackgroundColor = .clear
        // 设置索引的背景颜色
        self.tableView.sectionIndexBackgroundColor = .clear
    }

    func bindViewModel() {
        _ = codeSearchBar.textField.rx.text.throttle(RxTimeInterval.seconds(0), scheduler: MainScheduler.instance).distinctUntilChanged().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](searchText) in
            guard let `self` = self, let text = searchText else {
                return
            }

            self.viewModel.filterIndustryDic(text)

            if self.viewModel.dataSource.count == 0 {
                self.emptyLab.isHidden = false
            } else {
                self.emptyLab.isHidden = true
            }

            self.tableView.reloadData()
        })
    }

    //MARK: - 导航栏
    func setupNavigationBar() {
        //导航栏右按钮

        let rightBarItem = UIBarButtonItem.init(customView: sureButton)
        self.navigationItem.rightBarButtonItems = [rightBarItem]
    }

    lazy var sureButton: UIButton = {
        let button = UIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "common_confirm2"), for: .normal)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](e) in
            guard let `self` = self else { return }
            if let item = self.viewModel.industryItem {
                self.viewModel.didSelectedAction?(item, self.viewModel.selectItems)
            }

            self.navigationController?.popViewController(animated: true)
        })
        return button
    }()

}

extension YXStockFilterIndustryViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: industryCodeViewCellID) as! YXIndustryCodeTableViewCell
        if indexPath.section < self.viewModel.dataSource.count  {

            let arr = self.viewModel.dataSource[indexPath.section]
            if indexPath.row < arr.count, let dic = arr[indexPath.row] as? [String : Any] {
                if let name = dic["industry_name"] as? String {

                    cell.nameLabel.text = name
                } else {
                    cell.nameLabel.text = "--"
                }

                cell.selectedIcon.isHidden = !self.viewModel.isSelectItem(dic)
            } else {
                cell.nameLabel.text = "--"
                cell.selectedIcon.isHidden = true
            }

        }

        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < viewModel.dataSource.count {
            return viewModel.dataSource[section].count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: industryCodeSecHeaderViewID) as! YXIndustrySectionHeaderView
        if section < self.viewModel.titleArr.count {
            let title = self.viewModel.titleArr[section]
            header.update(with: title)
        }
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        53

    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section < self.viewModel.dataSource.count {
            let arr = self.viewModel.dataSource[indexPath.section]
            if let dic = arr[indexPath.row] as? [String : Any] {
                self.viewModel.handleSelectItem(dic)
            }

            self.tableView.reloadData()
        }

    }

    // 索引值数组
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        self.viewModel.titleArr
    }

    // 索引值与列表关联点击事件
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {

        return index
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //滚动时收起键盘
        codeSearchBar.textField.resignFirstResponder()
    }
}



class YXIndustrySectionHeaderView: UITableViewHeaderFooterView {
    private lazy var titleLab: QMUILabel = {
        let lab = QMUILabel()
        lab.textColor = QMUITheme().holdMark()   //#1E93F3
        lab.font = UIFont.systemFont(ofSize: 12)
        return lab
    }()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initUI()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initUI() {
        self.contentView.backgroundColor = QMUITheme().foregroundColor()

        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-18)
        }
    }
    func update(with text:String) {
        titleLab.text = text
    }
}

class YXIndustryCodeTableViewCell: QMUITableViewCell {

    lazy var nameLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return lab
    }()

    lazy var selectedIcon: UIImageView = {
        let imageV = UIImageView()
        let image = UIImage(named: "normal_selected")?.qmui_image(withTintColor: QMUITheme().themeTextColor())
        imageV.image = image
        imageV.isHidden = true
        return imageV
    }()

    private lazy var bottomLine:UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        //QMUITheme().textColorLevel2()
        return view
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func initialUI()  {
        self.selectionStyle = .none
        self.backgroundColor = QMUITheme().foregroundColor()

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(selectedIcon)
        selectedIcon.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }

        //bottomLine
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(18)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.trailing.equalToSuperview().offset(-18)
        }

    }
}
