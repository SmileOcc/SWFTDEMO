//
//  YXStockAnalyzeTechnicalView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/5/7.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockAnalyzeTechnicalSubView: UIView {

    init(frame: CGRect, alignment: NSTextAlignment) {
        super.init(frame: frame)
        initUI()
        topLabel.textAlignment = alignment
        bottomLabel.textAlignment = alignment
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(topLabel)
        addSubview(bottomLabel)
        topLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(22)
        }

        bottomLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalTo(topLabel.snp.bottom).offset(4)
        }
    }

    lazy var topLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 18)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()

    lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.qmui_color(withHexString: "#666666")
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
}


class YXStockAnalyzeTechnicalFormView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var ratio: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    let fixMinWidth: CGFloat = 25
    let fixMargin: CGFloat = 0

    let offsetWidth: CGFloat = 10.0

    override func layoutSubviews() {
        var leftWidth: CGFloat = 0
        var rightWidth: CGFloat = 0
        if ratio == 0 {
            leftWidth = fixMinWidth
            rightWidth = self.frame.width - leftWidth - fixMargin
        } else if ratio == 1 {
            rightWidth = fixMinWidth
            leftWidth = self.frame.width - rightWidth - fixMargin
        } else {
            leftWidth = (self.frame.width - fixMargin) * ratio
            if leftWidth < fixMinWidth {
                leftWidth = fixMinWidth
            } else if leftWidth > self.frame.width - fixMargin - fixMinWidth {
                leftWidth = self.frame.width - fixMargin - fixMinWidth
            }
            rightWidth = self.frame.width - fixMargin - leftWidth
        }

        leftLabel.frame = CGRect(x: 0, y: 0, width: leftWidth, height: self.frame.height)
        rightLabel.frame = CGRect(x: leftWidth + fixMargin, y: 0, width: rightWidth, height: self.frame.height)

        updateBezierPath()
    }

    func initUI() {
        backgroundColor = QMUITheme().foregroundColor()

        layer.addSublayer(leftLayer)
        layer.addSublayer(rightLayer)
        
        addSubview(leftLabel)
        addSubview(rightLabel)
        leftLabel.frame = CGRect(x: 0, y: 0, width: (self.frame.width - fixMargin) * 0.5, height: self.frame.height)
        rightLabel.frame = CGRect(x: leftLabel.frame.width + fixMargin, y: 0, width: (self.frame.width - fixMargin) * 0.5, height: self.frame.height)

        updateBezierPath()

        self.layer.cornerRadius = 2.0
        self.layer.masksToBounds = true
    }

    func updateBezierPath() {
        let leftPath = UIBezierPath()
        let rightPath = UIBezierPath()

        let leftWidth: CGFloat = leftLabel.frame.width
        let rightWidth: CGFloat = rightLabel.frame.width

        leftPath.move(to: CGPoint(x: 0, y: 0))
        leftPath.addLine(to: CGPoint(x: leftWidth + offsetWidth / 2.0, y: 0))
        leftPath.addLine(to: CGPoint(x: leftWidth - offsetWidth / 2.0, y: leftLabel.frame.height))
        leftPath.addLine(to: CGPoint(x: 0, y: leftLabel.frame.height))
        leftPath.close()

        let rightX = leftWidth
        rightPath.move(to: CGPoint(x: rightX + offsetWidth, y: 0))
        rightPath.addLine(to: CGPoint(x: rightWidth + rightX + fixMargin, y: 0))
        rightPath.addLine(to: CGPoint(x: rightWidth + rightX + fixMargin, y: rightLabel.frame.height))
        rightPath.addLine(to: CGPoint(x: rightX, y: rightLabel.frame.height))
        rightPath.addLine(to: CGPoint(x: offsetWidth + rightX, y: 0))

        leftLayer.path = leftPath.cgPath
        rightLayer.path = rightPath.cgPath
    }


    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        //label.backgroundColor = QMUITheme().stockRedColor()

        return label
    }()

    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.cornerRadius = 2.0
        label.layer.masksToBounds = true
        //label.backgroundColor = QMUITheme().stockGreenColor()

        return label
    }()

    lazy var leftLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = QMUITheme().stockRedColor().cgColor
        layer.strokeColor = QMUITheme().stockRedColor().cgColor
        layer.cornerRadius = 2.0

        return layer
    }()

    lazy var rightLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = QMUITheme().stockGreenColor().cgColor
        layer.strokeColor = QMUITheme().stockGreenColor().cgColor
        layer.cornerRadius = 2.0
        return layer
    }()

}

class YXStockAnalyzeTechnicalFeatureView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc var statusString: String = "" {
        didSet {
            if let status = Int(statusString) {
                var color = QMUITheme().stockGrayColor()
                if status > 0 {
                    color = QMUITheme().stockRedColor()
                } else if status < 0 {
                    color = QMUITheme().stockGreenColor()
                }
                let absStatus = abs(status)
                for (i, view) in colorViews.enumerated() {
                    view.layer.borderColor = color.cgColor
                    if i < absStatus {
                        view.backgroundColor = color
                    } else {
                        view.backgroundColor = UIColor.white
                    }
                }
            }
        }
    }

    var colorViews: [UIView] = []

    func initUI() {

        for _ in 0..<4 {
            let view = setUpColorView()
            addSubview(view)
            colorViews.append(view)
        }

        colorViews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 6)
        colorViews.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
        }
    }

    func setUpColorView() -> UIView {
        let view = UIView()
        view.layer.borderWidth = 2.0
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        view.layer.borderColor = QMUITheme().stockRedColor().cgColor
        view.backgroundColor = UIColor.white
        return view
    }

}

class YXStockAnalyzeTechnicalView: YXStockAnalyzeBaseView {

    @objc var pushToTechnicalDetailBlock: ((_ canJump: Bool) -> Void)?
    @objc var model: YXStockAnalyzeTechnicalModel? {
        didSet {
            updateUI()
        }
    }

    func updateUI() {
        if let valueModel = model {
          
            featureView.statusString = valueModel.summary_data.normalized_score

            var statusString = YXLanguageUtility.kLang(key: "two_six_weeks") + ": "
            if let status = Int(valueModel.summary_data.normalized_score) {
                let isNegtive = (status < 0)
                let absStatus = abs(status)
                switch absStatus {
                    case 0:
                        statusString += YXLanguageUtility.kLang(key: "neutral_market")
                    case 1:
                        statusString += (isNegtive ? YXLanguageUtility.kLang(key: "weak_bear_market") : YXLanguageUtility.kLang(key: "weak_bull_market"))
                    case 2:
                        statusString += (isNegtive ? YXLanguageUtility.kLang(key: "bear_market") : YXLanguageUtility.kLang(key: "bull_market"))
                    case 3, 4:
                        statusString += (isNegtive ? YXLanguageUtility.kLang(key: "strong_bear_market") : YXLanguageUtility.kLang(key: "strong_bull_market"))
                    default:
                    break
                }

            }

            statusLabel.text = statusString

            formView.leftLabel.text = String(valueModel.summary_data.bullish_count)
            formView.rightLabel.text = String(valueModel.summary_data.bearish_count)
            let div: CGFloat = (valueModel.summary_data.bullish_count + valueModel.summary_data.bearish_count) > 0 ? CGFloat(valueModel.summary_data.bullish_count + valueModel.summary_data.bearish_count) : 1.0
            var ratio = CGFloat(valueModel.summary_data.bullish_count) / div
            if valueModel.summary_data.bullish_count == 0, valueModel.summary_data.bearish_count == 0 {
                ratio = 0.5
            }
            formView.ratio = ratio
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        self.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
            guard let `self` = self else { return }
            if ges.state == .ended  {
                self.smartAnalyzeButtonAction()
            }
        }).disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(24)
        }

        addSubview(promptButton)
        promptButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(5)
            make.width.height.equalTo(16)
        }

        addSubview(smartAnalyzeButton)
        smartAnalyzeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-16)
            make.height.width.equalTo(16)
        }

        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        addSubview(featureView)
        featureView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
            make.height.equalTo(10)
            make.right.equalToSuperview().offset(-16)
        }
        featureView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        addSubview(upLabel)
        addSubview(downLabel)
        addSubview(formView)

        upLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(featureView.snp.bottom).offset(24)
        }

        downLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(upLabel)
        }

        formView.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(upLabel.snp.bottom).offset(7)
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "morphological_insight")
        return label
    }()

    lazy var promptButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_about"), for: .normal)
        button.addTarget(self, action: #selector(promptButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func promptButtonAction() {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "technical_toast"))
        alertView.messageLabel.font = .systemFont(ofSize: 16)
        alertView.messageLabel.textAlignment = .left
        alertView.clickedAutoHide = true
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { [weak alertView](action) in
            alertView?.hide()
        }))
        alertView.showInWindow()
    }

    lazy var smartAnalyzeButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "market_more_arrow"), for: .normal)
        button.addTarget(self, action: #selector(smartAnalyzeButtonAction), for: .touchUpInside)
        button.contentHorizontalAlignment = .right
        return button
    }()

    @objc func smartAnalyzeButtonAction() {
        var canJump = false
        if let flag = self.model?.jump_h5_flag, flag == true {
            canJump = true
        }
        pushToTechnicalDetailBlock?(canJump)
    }

    lazy var upLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "forecase_up_count")
        return label
    }()

    lazy var downLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.text = YXLanguageUtility.kLang(key: "forecase_down_count")
        return label
    }()


    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()

    lazy var featureView: YXStockAnalyzeTechnicalFeatureView = {
        let view = YXStockAnalyzeTechnicalFeatureView()

        return view
    }()


    lazy var formView: YXStockAnalyzeTechnicalFormView = {
        let view = YXStockAnalyzeTechnicalFormView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth - 32, height: 16))

        return view
    }()


}
