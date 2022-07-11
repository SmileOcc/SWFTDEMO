//
//  YXHKStockDetailBrokerView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


class YXStockDetailBrokerSingleCell: UITableViewCell {

    lazy var idLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "--"
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel3()
        lab.textAlignment = .left
        return lab
    }()

    lazy var nameLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "--"
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel1()
        lab.textAlignment = .left
        return lab
    }()

    var isBid = true {
        didSet {
//            if self.isBid {
//                self.idLabel.textColor = QMUITheme().mainThemeColor()
//                self.contentView.backgroundColor = QMUITheme().mainThemeColor().withAlphaComponent(0.1)
//            } else {
//                self.idLabel.textColor = QMUITheme().financialRedColor()
//                self.contentView.backgroundColor = QMUITheme().financialRedColor().withAlphaComponent(0.1)
//            }

            idLabel.snp.updateConstraints { (make) in
                make.leading.equalToSuperview().offset(isBid ? 0 : 15)
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func initUI() {
        contentView.addSubview(idLabel)
        contentView.addSubview(nameLabel)

        idLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(idLabel.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

class YXStockDetailBrokerSingleView: UIView {

    var tableView: UITableView

    var list: [BrokerDetail]? {
        didSet {
            self.tableView.reloadData()
        }
    }

    var isBid = false

    var rowNum: Int = 5

    convenience init(frame: CGRect, isBid: Bool) {
        self.init(frame: frame)
        self.isBid = isBid
        initUI()
    }

    override init(frame: CGRect) {
        tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.rowHeight = 34

        super.init(frame: frame)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.register(YXStockDetailBrokerSingleCell.self, forCellReuseIdentifier: "YXStockDetailBrokerSingleCell")

        tableView.backgroundColor = QMUITheme().foregroundColor()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        let topView = UIView.init()

        addSubview(topView)
        addSubview(tableView)

        if self.isBid {
            topView.backgroundColor = bidColor
            topView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            topView.layer.cornerRadius = 2.0
        } else {
            topView.backgroundColor = askColor
            topView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            topView.layer.cornerRadius = 2.0
        }

        topView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(16)
        }
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom).offset(6)
        }
    }
}

extension YXStockDetailBrokerSingleView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.rowNum
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: YXStockDetailBrokerSingleCell = tableView.dequeueReusableCell(withIdentifier: "YXStockDetailBrokerSingleCell") as! YXStockDetailBrokerSingleCell
        cell.isBid = self.isBid
        let count = self.list?.count ?? 0
        if indexPath.row < count {
            let model = self.list?[indexPath.row]

            cell.nameLabel.text = model?.Name
            if let idStr = model?.Id, idStr.contains("s") {
                cell.idLabel.text = idStr.replacingOccurrences(of: "s", with: "")
//                cell.contentView.backgroundColor = self.isBid ? QMUITheme().mainThemeColor().withAlphaComponent(0.2) : QMUITheme().financialRedColor().withAlphaComponent(0.2)
//                cell.idLabel.textColor = .black
            } else {
                cell.idLabel.text = model?.Id
//                cell.contentView.backgroundColor = self.isBid ? QMUITheme().mainThemeColor().withAlphaComponent(0.1) : QMUITheme().financialRedColor().withAlphaComponent(0.1)
//                cell.idLabel.textColor = self.isBid ? QMUITheme().mainThemeColor() : QMUITheme().financialRedColor()
            }
        } else {
            cell.idLabel.text = ""
            cell.nameLabel.text = ""
//            cell.contentView.backgroundColor = self.isBid ? QMUITheme().mainThemeColor().withAlphaComponent(0.1) : QMUITheme().financialRedColor().withAlphaComponent(0.1)
//            cell.idLabel.textColor = self.isBid ? QMUITheme().mainThemeColor() : QMUITheme().financialRedColor()
        }


        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView.init()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0.01
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView.init()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.01
    }
}

class YXHKStockDetailBrokerView: UIView, YXStockDetailSubHeaderViewProtocol {

    var brokerMenuCallBack: ((_ number: Int) -> ())?

    private var pop: YXStockPopover?

    var number: Int = 5 {
        didSet {
            tickGradeButton.setTitle("\(number)", for: .normal)
            self.contentHeight = 82 + 34.0 * CGFloat(number)
        }
    }

    //model
    var posBroker: PosBroker? {

        didSet {
            self.askView.rowNum = self.number
            self.bidView.rowNum = self.number
            self.askView.list = self.posBroker?.brokerData?.askBroker
            self.bidView.list = self.posBroker?.brokerData?.bidBroker
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initUI()
        tickGradeButton.setTitle("\(number)", for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func initUI() {

        addSubview(buyTitleLabel)
        addSubview(sellTitleLabel)
        addSubview(self.tickGradeButton)

        self.buyTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(tickGradeButton.snp.leading).offset(-5)
            make.height.equalTo(16)
        }

        self.sellTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-16)
            make.leading.equalTo(tickGradeButton.snp.trailing).offset(5)
            make.height.equalTo(16)
        }

        self.tickGradeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.sellTitleLabel)
            make.width.height.equalTo(20)
            make.centerX.equalToSuperview()
        }

        addSubview(bidView)
        addSubview(askView)

        bidView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(self.snp.centerX)
            make.bottom.equalToSuperview().offset(-10)
            make.top.equalTo(buyTitleLabel.snp.bottom).offset(6)
        }

        askView.snp.makeConstraints { (make) in
            make.top.width.bottom.equalTo(bidView)
            make.trailing.equalToSuperview().offset(-16)
        }
    }

    //MARK: 懒加载视图
    lazy var buyTitleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = YXLanguageUtility.kLang(key: "stock_broker_buy")
        label.textAlignment = .left
        return label
    }()

    lazy var sellTitleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = YXLanguageUtility.kLang(key: "stock_broker_sell")
        label.textAlignment = .right
        return label
    }()

    lazy var tickGradeButton: YXStockDetailPopBtn = {
        let button = YXStockDetailPopBtn.init()
        button.isSelected = true
        //button.setImage(UIImage(named: "tick_pull_down"), for: .normal)
        //button.imagePosition = .right
        button.addTarget(self, action: #selector(self.tickGradeButtonDidClick(_:)), for: .touchUpInside)
        return button
    }()

    lazy var bidView: YXStockDetailBrokerSingleView = {
        let view = YXStockDetailBrokerSingleView.init(frame: .zero, isBid: true)
        return view
    }()

    lazy var askView: YXStockDetailBrokerSingleView = {
        let view = YXStockDetailBrokerSingleView.init(frame: .zero, isBid: false)
        return view
    }()
}

extension YXHKStockDetailBrokerView {

    @objc func tickGradeButtonDidClick(_ sender: YXStockDetailPopBtn) {

        self.pop = YXStockPopover()
        self.pop?.show(self.getMenuView(), from: sender)
    }



    func getMenuView() -> UIView {
        let arr = ["5", "10", "40"]

        var maxWidth: CGFloat = 0
        for title in arr {
            let width = (title as NSString).boundingRect(with: CGSize(width: 1000, height: 30), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil).size.width
            if maxWidth < width {
                maxWidth = width
            }
        }
        let menuView = YXStockLineMenuView.init(frame: CGRect(x: 0, y: 0, width: maxWidth + 48, height: CGFloat(48 * arr.count)), andTitles: arr)
        menuView.clickCallBack = {
            [weak self] sender in
            guard let `self` = self else { return }
            
            self.pop?.dismiss()
            if sender.isSelected {
                return
            }
            
            var number = 5
            if sender.tag == 1 {
                number = 10
            } else if sender.tag == 2 {
                number = 40
            }
            self.tickGradeButton.setTitle("\(number)", for: .normal)
            self.number = number
            self.askView.rowNum = number
            self.bidView.rowNum = number
            self.askView.tableView.reloadData()
            self.bidView.tableView.reloadData()
        }
        let selectValue = self.tickGradeButton.titleLabel?.text ?? "5"
        for (index, title) in arr.enumerated() {
            if title == selectValue {
                menuView.selectIndex = index
                break;
            }
        }

        return menuView

    }

}

