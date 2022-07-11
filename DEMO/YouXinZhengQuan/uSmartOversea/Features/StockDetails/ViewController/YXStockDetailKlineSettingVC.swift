//
//  YXStockDetailKlineSettingVC.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXStockDetailKlineSettingVC: YXHKTableViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXStockDetailKlineSettingViewModel! = YXStockDetailKlineSettingViewModel()
    let reuseIdentifier = "YXNewStockMarketedCell"

    var isChangeSore: Bool = false
    var selectAdjustBtn: UIButton = UIButton()
    var selectStyleBtn: UIButton = UIButton()


    let kKlineSettingNowPriceTag = 3300
    let kKlineSettingHoldPriceTag = 3301
    let kKlineSettingBuySellPointTag = 3302
    var lineSettingCellHeight: CGFloat = 44.0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = YXLanguageUtility.kLang(key: "kline_set")
        bindHUD()
        initNavigationBar()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        YXKLineConfigManager.shareInstance().saveSoreArr()

        if isChangeSore {
            NotificationCenter.default.post(name: NSNotification.Name("KLineSettingChanged"), object: nil)
        }
    }

    fileprivate func initNavigationBar() {
        let recordItem = UIBarButtonItem.qmui_item(withTitle: YXLanguageUtility.kLang(key: "restore_default"), target: self, action: nil)
        recordItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()], for: .normal)
        recordItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()], for: .highlighted)
        recordItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()], for: .disabled)
        navigationItem.rightBarButtonItems = [recordItem]

        recordItem.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            let alertView = YXAlertView.init(message: YXLanguageUtility.kLang(key: "kline_setting_restore"))
            alertView.messageLabel.font = .systemFont(ofSize: 16)
            alertView.messageLabel.textAlignment = .left
            alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { (action) in

            }))

            alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { (action) in

                YXKLineConfigManager.shareInstance().clean()
                YXKLineConfigManager.shareInstance().saveData()

                self.isChangeSore = true
                YXQuoteManager.sharedInstance.removeKlinePool()
                for btn in self.adjustView.subviews {
                    if let button = btn as? UIButton {
                        if button.tag == YXKLineConfigManager.shareInstance().adjustType.rawValue {
                            button.isSelected = true
                            self.selectAdjustBtn = button
                        } else {
                            button.isSelected = false
                        }
                    }
                }

                for btn in self.styleView.subviews {
                    if let button = btn as? UIButton {
                        if button.tag == YXKLineConfigManager.shareInstance().styleType.rawValue {
                            button.isSelected = true
                            self.selectStyleBtn = button
                        } else {
                            button.isSelected = false
                        }
                    }
                }

                self.viewModel.dataSource = [YXKLineConfigManager.shareInstance().mainSettingTitleArr, YXKLineConfigManager.shareInstance().subSettingTitleArr]
                self.tableView.reloadData()
            }))
            alertView.showInWindow()
        }.disposed(by: disposeBag)
    }

    func initUI() {
        self.tableView.isEditing = true
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.separatorStyle = .none
        self.tableView.register(YXStockDetailKlineSettingCell.self, forCellReuseIdentifier: NSStringFromClass(YXStockDetailKlineSettingCell.self))

    }

    lazy var adjustView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var styleView: UIView = {
        let view = UIView()
        return view
    }()

    var adjustHeight: CGFloat {
        return self.kSectionHeaderHeight + 50
    }

    var lineSettingHeight: CGFloat {
        return self.kSectionHeaderHeight + 3.0 * self.lineSettingCellHeight
    }

    var klineStyleHeight: CGFloat {
        return self.kSectionHeaderHeight + 50
    }


    func setUpAdjustView(superview view: UIView) {
        let titleView = self.getSecontionViewWithTitle(YXLanguageUtility.kLang(key: "stock_detail_adjust_type"))
        view.addSubview(titleView)

        let btnView = UIView()
        btnView.frame = CGRect(x: 0, y: 30, width: YXConstant.screenWidth, height: 50)
        self.adjustView = btnView
        btnView.backgroundColor = QMUITheme().foregroundColor()
        let arr = [YXLanguageUtility.kLang(key: "stock_detail_adjusted_none"),
                   YXLanguageUtility.kLang(key: "stock_detail_adjusted_forward"),
                   YXLanguageUtility.kLang(key: "stock_detail_adjusted_backward")]
        let padding: CGFloat = 18
        let margin: CGFloat = 10
        let width: CGFloat = (YXConstant.screenWidth - 2 * padding - 2 * margin) / CGFloat(arr.count)
        for (i, title) in arr.enumerated() {
            let button = QMUIButton()
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(UIColor.qmui_color(withHexString: "#191919"), for: .normal)
            button.imagePosition = .left
            button.spacingBetweenImageAndTitle = 6
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.3
            button.frame = CGRect(x: padding + (width + margin) * CGFloat(i), y: 0, width: width, height: 50)
            button.tag = i
            button.contentHorizontalAlignment = .left
            button.setImage(UIImage(named: "edit_uncheck"), for: .normal)
            button.setImage(UIImage(named: "normal_selected"), for: .selected)
            button.addTarget(self, action: #selector(adjustBtnDidClick(_:)), for: .touchUpInside)
            if YXKLineConfigManager.shareInstance().adjustType.rawValue == i {
                button.isSelected = true
                self.selectAdjustBtn = button
            } else {
                button.isSelected = false
            }
            btnView.addSubview(button)
        }

        view.addSubview(btnView)
    }


    func setUpKlineStyleView(superview view: UIView) {
        let titleView = self.getSecontionViewWithTitle(YXLanguageUtility.kLang(key: "kline_style"))
        titleView.mj_y = adjustHeight
        view.addSubview(titleView)

        let btnView = UIView()
        btnView.frame = CGRect(x: 0, y: titleView.frame.maxY, width: YXConstant.screenWidth, height: 50)
        self.styleView = btnView
        btnView.backgroundColor = QMUITheme().foregroundColor()
        let arr = [YXLanguageUtility.kLang(key: "kline_style_solid_candle"),
                   YXLanguageUtility.kLang(key: "kline_style_hollow_candle"),
                   YXLanguageUtility.kLang(key: "kline_style_ohlc")]
        let padding: CGFloat = 18
        let margin: CGFloat = 10
        let width: CGFloat = (YXConstant.screenWidth - 2 * padding - 2 * margin) / CGFloat(arr.count)
        for (i, title) in arr.enumerated() {
            let button = QMUIButton()
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(UIColor.qmui_color(withHexString: "#191919"), for: .normal)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.3
            button.imagePosition = .left
            button.spacingBetweenImageAndTitle = 6
            button.frame = CGRect(x: padding + (width + margin) * CGFloat(i), y: 0, width: width, height: 50)
            button.tag = i
            button.contentHorizontalAlignment = .left
            button.setImage(UIImage(named: "edit_uncheck"), for: .normal)
            button.setImage(UIImage(named: "normal_selected"), for: .selected)
            button.addTarget(self, action: #selector(klineStyleBtnDidClick(_:)), for: .touchUpInside)
            if YXKLineConfigManager.shareInstance().styleType.rawValue == i {
                button.isSelected = true
                self.selectStyleBtn = button
            } else {
                button.isSelected = false
            }
            btnView.addSubview(button)
        }

        view.addSubview(btnView)
    }

    func setUpLineSettingView(superview view: UIView) {
        let titleView = self.getSecontionViewWithTitle(YXLanguageUtility.kLang(key: "kline_set"))
        titleView.mj_y = adjustHeight + klineStyleHeight
        view.addSubview(titleView)

        let nowPriceView = self.lineSettingView(YXLanguageUtility.kLang(key: "now_price_line"), switchTag: self.kKlineSettingNowPriceTag, isOn: YXKLineConfigManager.shareInstance().showNowPrice)
        let holdPriceView = self.lineSettingView(YXLanguageUtility.kLang(key: "hold_cost_price_line"), switchTag: self.kKlineSettingHoldPriceTag, isOn: YXKLineConfigManager.shareInstance().showHoldPrice)
        let buySellPointView = self.lineSettingView(YXLanguageUtility.kLang(key: "buy_sell_point"), switchTag: self.kKlineSettingBuySellPointTag, isOn: YXKLineConfigManager.shareInstance().showBuySellPoint)

        view.addSubview(nowPriceView)
        view.addSubview(holdPriceView)
        view.addSubview(buySellPointView)

        nowPriceView.frame = CGRect(x: 0, y: titleView.frame.maxY, width: YXConstant.screenWidth, height: self.lineSettingCellHeight)
        holdPriceView.frame = CGRect(x: 0, y: nowPriceView.frame.maxY, width: YXConstant.screenWidth, height: self.lineSettingCellHeight)
        buySellPointView.frame = CGRect(x: 0, y: holdPriceView.frame.maxY, width: YXConstant.screenWidth, height: self.lineSettingCellHeight)
    }

    func getSecontionViewWithTitle(_ title: String) -> UIView {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: kSectionHeaderHeight))
        view.backgroundColor = QMUITheme().backgroundColor()
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.frame = CGRect(x: 16, y: 0, width: YXConstant.screenWidth - 32, height: kSectionHeaderHeight)
        label.text = title
        view.addSubview(label)
        return view
    }

    func lineSettingView(_ title: String, switchTag: Int, isOn: Bool) -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: self.lineSettingCellHeight)
        view.backgroundColor = UIColor.white

        let switchButton = UISwitch()
        switchButton.onTintColor = QMUITheme().mainThemeColor()
        //switchButton.backgroundColor = UIColor.qmui_color(withHexString: "#E9E9EB")
        switchButton.setOn(isOn, animated: false)
        switchButton.tag = switchTag
        switchButton.layer.cornerRadius = 15
        switchButton.layer.masksToBounds = true

        switchButton.addTarget(self, action: #selector(switchButtonAction(_:)), for: UIControl.Event.valueChanged)
        view.addSubview(switchButton)
        switchButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(50)
        }

        let label = UILabel()
        label.text = title
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(switchButton.snp.left).offset(-10)
        }

        return view
    }


    @objc func adjustBtnDidClick(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        self.selectAdjustBtn.isSelected = false
        sender.isSelected = true
        self.selectAdjustBtn = sender
        if let type = YXKlineAdjustType(rawValue: sender.tag) {
            YXKLineConfigManager.shareInstance().adjustType = type
        }
    }


    @objc func klineStyleBtnDidClick(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        self.selectStyleBtn.isSelected = false
        sender.isSelected = true
        self.selectStyleBtn = sender
        if let type = YXKlineStyleType(rawValue: sender.tag) {
            YXKLineConfigManager.shareInstance().styleType = type

            var propViewName = "实心蜡烛"
            if type == .solid {
                propViewName = "实心蜡烛"
            } else if type == .hollow {
                propViewName = "空心蜡烛"
            } else if type == .OHLC {
                propViewName = "美国线"
            }
        }
    }


    @objc func switchButtonAction(_ sender: UISwitch) {
        let isOn = sender.isOn
        if sender.tag == self.kKlineSettingNowPriceTag {
            YXKLineConfigManager.shareInstance().showNowPrice = isOn
        } else if sender.tag == self.kKlineSettingHoldPriceTag {
            YXKLineConfigManager.shareInstance().showHoldPrice = isOn
        } else if sender.tag == self.kKlineSettingBuySellPointTag {
            YXKLineConfigManager.shareInstance().showBuySellPoint = isOn
        }
    }

}

extension YXStockDetailKlineSettingVC {

    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        50
    }

    var kSectionHeaderHeight: CGFloat {
        40
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = self.viewModel.dataSource[section] as? NSMutableArray {
            return array.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        kSectionHeaderHeight
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.getSecontionViewWithTitle(YXLanguageUtility.kLang(key: "main_tech"))
        } else {
            return self.getSecontionViewWithTitle(YXLanguageUtility.kLang(key: "sub_tech"))
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXStockDetailKlineSettingCell.self), for: indexPath)
        if let settingCell = cell as? YXStockDetailKlineSettingCell {
            if indexPath.section < self.viewModel.dataSource.count,  let arr = self.viewModel.dataSource[indexPath.section] as? NSMutableArray, let str = arr[indexPath.row] as? String {
                settingCell.titleLabel.text = str
                settingCell.lineView.isHidden = true
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section != destinationIndexPath.section {
            self.tableView.reloadData()
        } else {
            var arr: NSMutableArray = NSMutableArray()

            if sourceIndexPath.section == 0 {
                arr = YXKLineConfigManager.shareInstance().mainArr
            } else {
                arr = YXKLineConfigManager.shareInstance().subArr
            }

            let obj1 = arr[sourceIndexPath.row]
            arr.removeObject(at: sourceIndexPath.row)
            arr.insert(obj1, at: destinationIndexPath.row)

            self.viewModel.dataSource = [YXKLineConfigManager.shareInstance().mainSettingTitleArr, YXKLineConfigManager.shareInstance().subSettingTitleArr]

            self.isChangeSore = true
            self.tableView.reloadData()
        }
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var tempNumber: NSNumber?
        if indexPath.section == 0 {
            if let number = YXKLineConfigManager.shareInstance().mainArr[indexPath.row] as? NSNumber {
                let type = YXStockMainAcessoryStatus.init(rawValue: number.intValue) ?? .MA
                if type == .usmart {
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "trend_signal_setting"))
                    return;
                }
 
                tempNumber = number
            }
        } else {
            if let number = YXKLineConfigManager.shareInstance().subArr[indexPath.row] as? NSNumber {
                tempNumber = number
            }
        }

        if let number = tempNumber {
            let params: [AnyHashable : Any] = [
                "indexType": number
            ]

            let detailViewModel = YXKlineSubIndexViewModel.init(services: viewModel.navigator, params: params)
            viewModel.navigator.push(detailViewModel, animated: true)
        }

    }

}
