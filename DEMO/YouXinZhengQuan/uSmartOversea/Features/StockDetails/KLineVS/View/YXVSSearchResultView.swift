//
//  YXVSSearchResultView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/2/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


class YXVSSearchResultView: UIView {

    @objc enum KLineVSResultType: Int {
        case result  //搜索结果
        case select  //选中
        case own     //自选
    }

    @objc var closeActionBlock: (() -> Void)?

    @objc var rightActionBlock: ((_ model: YXSecu?) -> Void)?

    var type: KLineVSResultType = .result

    @objc var list: [YXSecu] = [] {
        didSet {
            if list.count == 0 {
                self.tableView.contentOffset = CGPoint(x: 0, y: 0)
            }
            self.tableView.reloadData()
        }
    }

    @objc func refreshUI() {
        self.tableView.reloadData()
    }

    let cellHeight: CGFloat = 59

    @objc init(frame: CGRect, type: KLineVSResultType) {
        super.init(frame: frame)

        self.type = type
        initUI()

        if type == .result {
            titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_kine_compar_search")
            subTitleLabel.text = ""
        } else if type == .own {
            titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_kine_compar_select")
            subTitleLabel.text = ""
        } else {
            titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_kine_compar_selected")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        if self.type == .select {
            self.backgroundColor = QMUITheme().foregroundColor()
        } else {
            self.backgroundColor = QMUITheme().foregroundColor()
        }
        addSubview(titleLabel)
        addSubview(lineView)
        addSubview(tableView)

        if self.type == .result || self.type == .own {
            addSubview(subTitleLabel)
            titleLabel.snp.makeConstraints { (make) in

                make.left.equalToSuperview().offset(12)
                make.top.equalToSuperview().offset(16)
                make.height.equalTo(20)
            }

            subTitleLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-12)
                make.top.equalToSuperview().offset(16)
                make.height.equalTo(20)
            }
        } else {
            titleLabel.snp.makeConstraints { (make) in

                make.left.equalToSuperview().offset(17)
                make.top.equalToSuperview().offset(20)
                make.height.equalTo(20)
            }

            addSubview(closeButton)
            closeButton.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-16)
                make.top.equalToSuperview().offset(20)
                make.height.width.equalTo(20)
            }
        }

        lineView.snp.makeConstraints { (make) in

            make.height.equalTo(0.5)
            if self.type == .select {
                make.left.equalToSuperview().offset(17)
                make.right.equalToSuperview().offset(-17)
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
            } else {
                make.left.equalToSuperview().offset(12)
                make.right.equalToSuperview().offset(-12)
                make.top.equalTo(titleLabel.snp.bottom).offset(4)
            }
        }

        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom).offset(10)
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()

    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.45)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()

    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.register(YXVSSearchCell.self, forCellReuseIdentifier: "YXVSSearchCell")
        tableView.separatorStyle = .none
        if self.type == .select {
            tableView.backgroundColor = QMUITheme().foregroundColor().withAlphaComponent(0.03)
        } else {
            tableView.backgroundColor = QMUITheme().foregroundColor()
        }

        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

        return tableView
    }()

    @objc func closeDidClick() {
        self.closeActionBlock?()
    }

    lazy var closeButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 10
        button.expandY = 10
        button.setImage(UIImage(named: "regist_close"), for: .normal)
        button.addTarget(self, action: #selector(closeDidClick), for: .touchUpInside)
        return button
    }()
}

extension YXVSSearchResultView: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        59
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "YXVSSearchCell") as? YXVSSearchCell

        if cell == nil {
            cell = YXVSSearchCell.init(style: .default, reuseIdentifier: "YXVSSearchCell", type: self.type)
        }

        if let cell = cell {

            let model = list[indexPath.row]

            cell.model = model

            if type == .own || type == .result {
                var contain = false
                for item in YXKlineVSTool.shared.selectList {
                    if item.secu.market == model.market, item.secu.symbol == model.symbol  {
                        contain = true
                        break
                    }
                }

                cell.rightButton.isSelected = contain
            }

            cell.rightActionBlock = { [weak self] (type, model) in
                guard let `self` = self else { return }

                self.rightActionBlock?(model)
            }
        }


        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        //self.viewModel?.cellTapAction(at: indexPath.row)

        if self.type == .result || self.type == .own {
            let model = list[indexPath.row]
            self.rightActionBlock?(model)
        }
    }
}

extension YXVSSearchResultView: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if self.type == .result || self.type == .own {
            return UIImage(named: "empty_noData")
        } else {
            return UIImage(named: "empty_noData")
        }
       
    }
   

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if self.type == .result || self.type == .own {
            return NSAttributedString(string: YXLanguageUtility.kLang(key: "klinevs_seach_non_result"), attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: QMUITheme().textColorLevel1().withAlphaComponent(0.45)])
        } else {
            return NSAttributedString(string: YXLanguageUtility.kLang(key: "klinevs_non_compar"), attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: QMUITheme().textColorLevel1().withAlphaComponent(0.45)])
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
//        if self.type == .result || self.type == .own {
//            return -40
//        } else {
//            return -20
//        }
//        
        return 40
    }
}


class YXVSSearchCell: UITableViewCell {

   @objc var rightActionBlock: ((_ type: YXVSSearchResultView.KLineVSResultType, _ model: YXSecu?) -> Void)?

    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, type: YXVSSearchResultView.KLineVSResultType) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.type = type
        self.selectionStyle = .none
        if self.type == .select {
            self.backgroundColor = QMUITheme().foregroundColor().withAlphaComponent(0.03)
        } else {
            self.backgroundColor = QMUITheme().foregroundColor()
        }
        initUI()
    }

    required init?(coder: NSCoder) {
        //super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    var type: YXVSSearchResultView.KLineVSResultType = .result

    var model: YXSecu? {
        didSet {
            refreshUI()
        }
    }

    func refreshUI() {

        self.symbolLabel.text = model?.name

        self.nameLabel.text = model?.symbol ?? ""

//        self.iconImageView.image = UIImage(named: model?.market.lowercased() ?? kYXMarketHK.lowercased())
        self.iconLabel.market = model?.market.lowercased() ?? ""

    }

    func initUI() {

        self.contentView.addSubview(self.iconLabel)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.symbolLabel)
        self.contentView.addSubview(self.rightButton)


        self.rightButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
            if self.type == .select {
                make.right.equalToSuperview().offset(-16)
            } else {
                make.right.equalToSuperview().offset(-23)
            }
        }
        
        self.symbolLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(22)
            make.right.lessThanOrEqualTo(self.rightButton.snp.left).offset(-5)
        }

        self.iconLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(17)
            make.height.equalTo(13)
            make.centerY.equalTo(self.nameLabel)
        }

        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.iconLabel.snp.right).offset(2)
            make.top.equalTo(self.symbolLabel.snp.bottom).offset(1)
            make.height.equalTo(15)
            make.right.lessThanOrEqualTo(self.rightButton.snp.left).offset(-5)
        }
    }

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    @objc lazy var iconLabel: YXMarketIconLabel = {
        return YXMarketIconLabel()
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor =  QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    lazy var rightButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 10
        button.expandY = 10
        if self.type == .select {
            button.setImage(UIImage(named: "edit_delete"), for: .normal)
        } else {
            button.setImage(UIImage(named: "add_oversea"), for: .normal)
            button.setImage(UIImage(named: "stockcompare_selected"), for: .selected)
        }

        button.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            self.rightActionBlock?(self.type, self.model)
        }).disposed(by: rx.disposeBag)

        return button
    }()
}
