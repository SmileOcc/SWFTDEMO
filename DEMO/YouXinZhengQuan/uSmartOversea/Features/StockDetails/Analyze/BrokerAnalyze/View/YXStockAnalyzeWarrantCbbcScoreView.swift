//
//  YXStockAnalyzeWarrantCbbcScoreView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2020/10/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockAnalyzeWarrantCbbcScoreView: YXStockAnalyzeBaseView {

    @objc var model: YXStockAnalyzeWarrantCbbcScoreModel? {
        didSet {
            refreshUI()
        }
    }

    func refreshUI() {

        if let model = model {

            scoreLabel.text = "\(model.score)"

            let rankString = "\(model.rank)/\(model.rankBase)"
            let prefix = rankString.components(separatedBy: "/").first ?? ""
            let suffix = rankString.components(separatedBy: "/").last ?? ""
            let attributeString = NSMutableAttributedString(string: prefix, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .medium), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()])
            attributeString.append(NSAttributedString(string: " /\(suffix)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3()]))
            rankLabel.attributedText = attributeString


            let arr1 = [ self.getDoubleValue(model.maturityDateScore),
                         self.getDoubleValue(model.moneynessScore),
                         self.getDoubleValue(model.spreadScore),
                         self.getDoubleValue(model.outstandingScore)]

            self.radarView.scoreArray = arr1
        }

    }


    func getDoubleValue(_ value: Int?) -> NSNumber {
        if let value = value {

            return NSNumber.init(value: Double(value))
        }
        return NSNumber.init(value: 0)
    }



    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        self.backgroundColor = QMUITheme().foregroundColor()

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(24)
        }

        addSubview(promptButton)
        promptButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel).offset(-0.5)
            make.left.equalTo(titleLabel.snp.right).offset(6)
            make.width.height.equalTo(16)
        }

        let width = (YXConstant.screenWidth) / 2.0

        addSubview(scoreDesLabel)
        scoreDesLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(62)
            make.left.equalToSuperview()
            make.width.equalTo(width)
            make.height.equalTo(16)
        }

        addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(scoreDesLabel.snp.top).offset(-8)
            make.left.right.equalTo(scoreDesLabel)
            make.height.equalTo(26)
        }


        addSubview(rankDesLabel)
        rankDesLabel.snp.makeConstraints { (make) in
            make.top.equalTo(scoreDesLabel.snp.top)
            make.left.equalTo(scoreDesLabel.snp.right)
            make.width.equalTo(width)
            make.height.equalTo(16)
        }

        addSubview(rankLabel)
        rankLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(rankDesLabel.snp.top).offset(-8)
            make.left.right.equalTo(rankDesLabel)
            make.height.equalTo(26)
        }
        
        
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(63)
            make.top.equalToSuperview().offset(76)
        }

        addSubview(radarView)
        radarView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(scoreDesLabel.snp.bottom).offset(49)
            make.height.equalTo(250)
        }


    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "bullbear_yxscore")
        return label
    }()

    lazy var promptButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 5
        button.expandY = 5
        button.setImage(UIImage(named: "stock_about"), for: .normal)
        button.addTarget(self, action: #selector(promptButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func promptButtonAction() {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "warrant_score_prompt"))
        alertView.messageLabel.font = .systemFont(ofSize: 16)
        alertView.messageLabel.textAlignment = .left
        alertView.clickedAutoHide = true
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { [weak alertView](action) in
            alertView?.hide()
        }))
        alertView.showInWindow()
    }

    lazy var rankLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .center
        label.text = "--"
        return label
    }()

    lazy var rankDesLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = YXLanguageUtility.kLang(key: "warrant_score_score")
        return label
    }()

    lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .center
        label.text = "--"
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.05)
        return view
    }()

    lazy var scoreDesLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = YXLanguageUtility.kLang(key: "warrant_score_rank")

        return label
    }()


    lazy var radarView: YXStockAnalyzeWarrantRadarView = {
        let view = YXStockAnalyzeWarrantRadarView()
        return view
    }()

}

