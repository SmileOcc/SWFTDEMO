//
//  YXReminderFrequencyView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/7/15.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit


class YXReminderFrequencyView: UIView {

    @objc var selectIndexClosure: ((_ selectIndex: Int) -> Void)?

    @objc var selectIndex: Int = 0 {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var num3: Int?? = 10

    struct FrequencyDataSource {
        let mainTitle: String
        let subTitle: String
    }

    var dataSource: [FrequencyDataSource] = []

    var cellHeightArr: [CGFloat] = []

    let maxWidth = YXConstant.screenWidth - 60

    @objc var tableViewHeight: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        
        var tempDataSource: [FrequencyDataSource] = []
        let mainTitles: [String] = [YXLanguageUtility.kLang(key: "remind_once"), YXLanguageUtility.kLang(key: "remind_everyday"), YXLanguageUtility.kLang(key: "remind_keeping")]
        let subTitles: [String] = [YXLanguageUtility.kLang(key: "remind_once_desc"), YXLanguageUtility.kLang(key: "remind_everyday_desc"), YXLanguageUtility.kLang(key: "remind_keeping_desc")]
        for (index, mainTitle) in mainTitles.enumerated() {
            let subTitle = subTitles[index]
            let info = FrequencyDataSource(mainTitle: mainTitle, subTitle: subTitle)
            tempDataSource.append(info)
        }
        self.dataSource = tempDataSource

        var heightArr: [CGFloat] = []
        self.tableViewHeight = 0
        for subTitle in subTitles {
            let height = (subTitle as NSString).boundingRect(with: CGSize(width: maxWidth, height: 300), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)], context: nil).height + 55
            heightArr.append(height)
            self.tableViewHeight += height
        }
        self.cellHeightArr = heightArr

        initUI()
    }



    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        self.backgroundColor = QMUITheme().foregroundColor()
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(self.tableViewHeight)
            make.bottom.equalToSuperview()
        }
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.register(YXReminderFrequencyCell.self, forCellReuseIdentifier: "YXReminderFrequencyCell")
        tableView.separatorStyle = .none
        return tableView
    }()
}

extension YXReminderFrequencyView: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YXReminderFrequencyCell", for: indexPath) as! YXReminderFrequencyCell
        if indexPath.row == selectIndex {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        if indexPath.row < self.dataSource.count {
            cell.model = self.dataSource[indexPath.row]
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectIndex = indexPath.row
        self.selectIndexClosure?(indexPath.row)
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < cellHeightArr.count {
            return cellHeightArr[indexPath.row]
        } else {
            return 69
        }
    }
}



class YXReminderFrequencyCell: UITableViewCell {


    var model: YXReminderFrequencyView.FrequencyDataSource? {
        didSet {
            if let info = model {
                mainTitleLabel.text = info.mainTitle
                subTitleLabel.text = info.subTitle
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = QMUITheme().foregroundColor()
        initUI()
    }

    required init?(coder: NSCoder) {
        //super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        
        contentView.addSubview(mainTitleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(selectImageView)

        mainTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(22)
        }

        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(mainTitleLabel)
            make.top.equalTo(mainTitleLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(17)
        }

        selectImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
    }

    override var isSelected: Bool {
        didSet {
            selectImageView.isHidden = !isSelected
        }
    }

    lazy var mainTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()

    lazy var selectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "settings_select")
        imageView.isHidden = true
        return imageView
    }()

}

