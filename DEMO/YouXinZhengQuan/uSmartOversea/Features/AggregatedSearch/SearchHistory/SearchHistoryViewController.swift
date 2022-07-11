//
//  SearchHistoryViewController.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/8.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchHistoryViewController: YXViewController {

    private let itemHeight: CGFloat = 32

    var didSelectKeyword: ((String) -> Void)?

    private var dataSource: NSArray = []

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .mediumFont16()
        label.textColor = QMUITheme().textColorLevel1()
        label.text = YXLanguageUtility.kLang(key: "search_history")
        return label
    }()

    private lazy var clearButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "search_delete"), for: .normal)
        button.addTarget(self, action: #selector(clickClearButton), for: .touchUpInside)
        button.adjustsImageTintColorAutomatically = true
        button.tintColor = QMUITheme().textColorLevel3()
        return button
    }()

    private lazy var historyView: QMUIFloatLayoutView = {
        let view = QMUIFloatLayoutView.init()
        view.padding = .zero
        view.itemMargins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        view.minimumItemSize = CGSize(width: itemHeight, height: itemHeight)
        view.clipsToBounds = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = QMUITheme().foregroundColor()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    override func preferredNavigationBarHidden() -> Bool {
        true
    }
    
    override func initSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(clearButton)
        view.addSubview(historyView)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(24)
        }

        clearButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(22)
        }

        historyView.snp.makeConstraints { make in
            make.top.equalTo(62)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }

    @objc private func clickClearButton() {
        let alertView = YXAlertView.alertView(message: YXLanguageUtility.kLang(key: "delete_search_history_tip"))
        let alertController = YXAlertController.init(alert: alertView)
        alertView.clickedAutoHide = false

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] _ in
            alertView?.hide()
        }))

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { [weak self, weak alertView] _ in
            self?.view?.trackViewClickEvent(customPageName: "Search_page", name: "Delete_search_history")
            SearchHistoryManager.sharedManager.removeAll()
            self?.reloadData()
            alertView?.hide()
        }))

        present(alertController!, animated: true, completion: nil)
    }

    func reloadData() {
        self.dataSource = SearchHistoryManager.sharedManager.getHistories()

        historyView.removeAllSubviews()

        for history in self.dataSource {
            let btn = QMUIButton()
            btn.layer.cornerRadius = 4
            btn.layer.borderColor = QMUITheme().separatorLineColor().cgColor
            btn.layer.borderWidth = 1
            btn.layer.masksToBounds = true
            btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            btn.backgroundColor = QMUITheme().foregroundColor()
            btn.titleLabel?.font = .systemFont(ofSize: 14)
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            btn.snp.makeConstraints { make in
                make.height.equalTo(itemHeight)
            }

            if var text = history as? String {
                let maxCount = 18 // 最多显示 9 个汉字或者 18 个英文字母
                let count = text.qmui_lengthWhenCountingNonASCIICharacterAsTwo
                if count > maxCount {
                    text = ((text as NSString).qmui_substringAvoidBreakingUpCharacterSequences(
                        with: NSRange(location: 0, length: maxCount),
                        lessValue: true,
                        countingNonASCIICharacterAsTwo: true
                    ) ?? "") as String
                    text.append("...")
                }
                btn.setTitle(text, for: .normal)
            }

            _ = btn.rx.tap.subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                if let text = history as? String {
                    self.didSelectKeyword?(text)
                    self.view?.trackViewClickEvent(
                        customPageName: "Search_page",
                        name: "Search_history",
                        other: ["search_history" : text]
                    )
                }
            })

            historyView.addSubview(btn)
        }

        var height: CGFloat = 0

        if self.dataSource.count > 0 {
            height += 62

            var historyViewHeight = historyView.sizeThatFits(CGSize(width: YXConstant.screenWidth - 32, height: CGFloat.greatestFiniteMagnitude)).height
            let maxLineNumber: CGFloat = 3 // 最大3行
            let maxHeight = itemHeight * maxLineNumber + UIEdgeInsetsGetVerticalValue(historyView.itemMargins) * (maxLineNumber - 1)
            historyViewHeight = min(historyViewHeight, maxHeight)

            height += historyViewHeight
        }

        self.view.snp.updateConstraints { make in
            make.height.equalTo(height)
        }

        self.view.isHidden = self.dataSource.count == 0
    }

}
