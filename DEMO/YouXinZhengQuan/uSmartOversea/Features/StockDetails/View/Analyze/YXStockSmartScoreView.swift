//
//  YXStockSmartScoreView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockSmartScoreView: YXStockAnalyzeBaseView {


    @objc var pushToAnalysisDetailBlock: (() -> Void)?
    @objc var model: YXStockAnalyzeDiagnoseScoreModel? {
        didSet {

            if model == nil || model?.list == nil {
                noDataView.isHidden = false
                tagBgScrollView.snp.updateConstraints { (make) in
                    make.height.equalTo(30)
                }
                return
            } else {
                noDataView.isHidden = true
            }

            let base1 = fabs(Double(model?.base ?? 0))
            let base = pow(10, base1)
            progressView.model = model
            if let name = model?.list.name, !name.isEmpty {
                stockNameLabel.text = name
            } else {
                stockNameLabel.text = "--"
            }

            if let symbol = model?.list.symbol, !symbol.isEmpty {
                var filterString = symbol.replacingOccurrences(of: kYXMarketHK, with: "")
                filterString = filterString.replacingOccurrences(of: kYXMarketUS, with: "")
                filterString = filterString.replacingOccurrences(of: kYXMarketChinaSH, with: "")
                filterString = filterString.replacingOccurrences(of: kYXMarketChinaSZ, with: "")
                symbolLabel.text = filterString
            } else {
                symbolLabel.text = "--"
            }

            if let winRate = model?.list.ranking_percentage, winRate >= 0 {
                if Double(winRate) / base >= 100 {
                    winRateLabel.text = "100%"
                } else {
                    winRateLabel.text = String(format: "%.02f%%", Double(winRate) / base)
                }

            } else {
                winRateLabel.text = "--"
            }

            if let rankString = model?.list.rankings, rankString.contains("/") {
                let prefix = rankString.components(separatedBy: "/").first ?? ""
                let suffix = rankString.components(separatedBy: "/").last ?? ""
                let attributeString = NSMutableAttributedString(string: prefix, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .medium), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()])
                attributeString.append(NSAttributedString(string: " /\(suffix)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .regular), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3()]))
                rankLabel.attributedText = attributeString
            } else {
                rankLabel.attributedText = NSAttributedString(string: "--", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .medium), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()])
            }

            if let tagString = model?.tag_list {
                tagBgScrollView.removeAllSubviews()
                var tagArray = tagString.components(separatedBy: ";")
                var notExistArray: [Int] = []
                for (index, value) in tagArray.enumerated() {
                    if value.isEmpty || value == ";" || featureDic[value] == nil {
                        notExistArray.append(index)
                    }
                }

                for i in notExistArray.reversed() {
                    if i < tagArray.count {
                        tagArray.remove(at: i)
                    }
                }

                if tagArray.count > 0 {
                    tagBgScrollView.snp.updateConstraints { (make) in
                        make.height.equalTo(30)
                    }
                    let scale = YXConstant.screenWidth / 375.0
                    var preview: UIView? = nil
                    for (index, string) in tagArray.enumerated() {
                        let text = string.replacingOccurrences(of: ";", with: "")
                        let label = QMUILabel()
                        label.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
                        label.font = UIFont.systemFont(ofSize: 14)
                        label.textColor = QMUITheme().themeTextColor()
                        label.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.1)
                        label.layer.cornerRadius = 15
                        label.text = featureDic[text] ?? text
                        label.layer.masksToBounds = true
                        tagBgScrollView.addSubview(label)
                        label.snp.makeConstraints { (make) in
                            make.centerY.equalToSuperview()
                            make.height.equalTo(30)
                            if let view = preview {
                                make.left.equalTo(view.snp.right).offset(5)
                            } else {
                                make.left.equalToSuperview().offset(18 * scale)
                            }
                            if index == tagArray.count - 1 {
                                make.right.equalToSuperview()
                            }
                        }

                        preview = label
                    }
                } else {
                    tagBgScrollView.snp.updateConstraints { (make) in
                        make.height.equalTo(0)
                    }
                }

            } else {
                tagBgScrollView.removeAllSubviews()
                tagBgScrollView.snp.updateConstraints { (make) in
                    make.height.equalTo(0)
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func initUI() {

        let scale: CGFloat = YXConstant.screenWidth / 375.0

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
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
            make.width.equalTo(16)
            make.centerY.equalTo(titleLabel)
        }

//        addSubview(remainingTimesLabel)
//        remainingTimesLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(smartAnalyzeButton.snp.bottom)
//            make.right.equalToSuperview().offset(-12)
//        }


        addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.width.equalTo(106)
            make.height.equalTo(106)
        }

        addSubview(stockNameLabel)
        stockNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(progressView.snp.right).offset(30 * scale)
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.height.equalTo(19)
        }

        addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(stockNameLabel)
            make.left.equalTo(stockNameLabel.snp.right).offset(4)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        symbolLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)

        addSubview(rankDesLabel)
        rankDesLabel.snp.makeConstraints { (make) in
            make.top.equalTo(stockNameLabel.snp.bottom).offset(44)
            make.left.equalTo(stockNameLabel)
        }

        addSubview(rankLabel)
        rankLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(rankDesLabel.snp.top).offset(-4)
            make.left.equalTo(stockNameLabel)
            make.height.equalTo(26)
        }

        addSubview(verticalLineView)
        verticalLineView.snp.makeConstraints { (make) in
            make.top.equalTo(stockNameLabel.snp.bottom).offset(9)
            make.width.equalTo(1)
            make.height.equalTo(63)
            make.right.equalToSuperview().offset(-131 * scale)
        }

        addSubview(winRateDesLabel)
        winRateDesLabel.snp.makeConstraints { (make) in
            make.top.equalTo(rankDesLabel)
            make.left.equalTo(verticalLineView.snp.right).offset(13 * scale)
        }

        addSubview(winRateLabel)
        winRateLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(winRateDesLabel.snp.top).offset(-4)
            make.left.equalTo(winRateDesLabel)
            make.height.equalTo(26)
        }

        addSubview(clickControl)
        clickControl.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalTo(rankDesLabel.snp.bottom).offset(-19)
        }

        addSubview(tagBgScrollView)
        tagBgScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(rankDesLabel.snp.bottom).offset(22)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0)
            make.bottom.equalToSuperview().offset(-15)
        }

        addSubview(noDataView)
        noDataView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview()
        }

    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "smart_ranking")
        return label
    }()

    lazy var promptButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_about"), for: .normal)
        button.addTarget(self, action: #selector(promptButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func promptButtonAction() {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "smart_ranking_toast"))
        alertView.messageLabel.font = .systemFont(ofSize: 16)
        alertView.messageLabel.textAlignment = .left
        alertView.clickedAutoHide = true
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { [weak alertView](action) in
            alertView?.hide()
        }))
        alertView.showInWindow()
    }

    lazy var smartAnalyzeButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "market_more_arrow"), for: .normal)
        button.addTarget(self, action: #selector(smartAnalyzeButtonAction), for: .touchUpInside)
//        button.setTitle(YXLanguageUtility.kLang(key: "webview_detailTitle"), for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
//        button.imagePosition = .right
//        button.spacingBetweenImageAndTitle = 4
        button.contentHorizontalAlignment = .right
        return button
    }()

    @objc func smartAnalyzeButtonAction() {
        pushToAnalysisDetailBlock?()
    }

    @objc lazy var remainingTimesLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .right
        return label
    }()

    lazy var progressView: YXStockAnalyzeProgressView = {
        let view = YXStockAnalyzeProgressView(frame: CGRect(x: 0, y: 0, width: 106, height: 106))
        return view
    }()


    lazy var stockNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .left
        return label
    }()

    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()

    lazy var rankLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .left
        return label
    }()

    lazy var rankDesLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.isUserInteractionEnabled = true

        let attrMutStr =  NSMutableAttributedString.init(string: YXLanguageUtility.kLang(key: "smart_industry_ranking"), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3()])
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "stock_about")
        attachment.bounds = CGRect(x: 1, y: -1.5, width: 14, height: 14)
        attrMutStr.append(NSAttributedString.init(attachment: attachment))
        label.attributedText = attrMutStr


        label.rx.tapGesture().subscribe(onNext: {  ges in

            if ges.state == .ended {
                let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "smart_ranking_toast1"))
                alertView.messageLabel.font = .systemFont(ofSize: 16)
                alertView.messageLabel.textAlignment = .left
                alertView.clickedAutoHide = true
                alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { [weak alertView](action) in
                    alertView?.hide()
                }))
                alertView.showInWindow()
            }

        }).disposed(by: rx.disposeBag)

        return label
    }()

    lazy var winRateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .left
        return label
    }()

    lazy var winRateDesLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = YXLanguageUtility.kLang(key: "smart_win_stocks")
        return label
    }()

    lazy var verticalLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.05)
        return view
    }()

    lazy var tagBgScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        return scrollView
    }()

    lazy var clickControl: UIControl = {
        let control = UIControl()
        control.addTarget(self, action: #selector(smartAnalyzeButtonAction), for: .touchUpInside)
        return control
    }()

    lazy var noDataView: YXStockEmptyDataView = {
        let view = YXStockEmptyDataView()
        view.isHidden = true
        view.textLabel.text = YXLanguageUtility.kLang(key: "smart_score_no_data")
        view.textLabel.textAlignment = .center
        view.setCenterYOffset(-50)
        view.textLabel.numberOfLines = 0
        view.textLabel.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(view.imageView.snp.bottom).offset(16)
        }
        return view
    }()



    /*

     [
     {
     img: 'profit-strong',
     name: '盈利能力强',
     intro: '表示盈利能力得分排名在同行业前20%；'
     },
     {
     img: 'grow-fast',
     name: '增长快',
     intro: '表示成长能力得分在同行业前20%；'
     },
     {
     img: 'operate-nice',
     name: '营运佳',
     intro: '表示营运能力得分在同行业前20%；'
     },
     {
     img: 'dividend-high',
     name: '派息高',
     intro: '表示股息率得分在同行业前20%；'
     },
     {
     img: 'assess-high',
     name: '估值高',
     intro: '表示估值水平得分在同行业前20%；'
     },
     {
     img: 'assess-low',
     name: '估值低',
     intro: '表示估值水平得分在同行业后20%；'
     },
     {
     img: 'trend-strong',
     name: '走势强',
     intro: '表示股价走势得分在同行业前20%；'
     },
     {
     img: 'trend-weak',
     name: '走势弱',
     intro: '表示股价走势得分在同行业后20%；'
     },
     {
     img: 'deal-active',
     name: '成交活跃',
     intro: '表示资金成交得分在同行业前20%；'
     }

     [
     {
     img: 'profit-strong',
     name: 'High Profitability',
     intro: 'Profitability Score is top 20% of the industry.'
     },
     {
     img: 'grow-fast',
     name: 'Fast Growing',
     intro: 'Growth Score is top 20% of the industry.'
     },
     {
     img: 'operate-nice',
     name: 'Great Operation',
     intro: 'Operating performance is top 20% of the industry.'
     },
     {
     img: 'dividend-high',
     name: 'High Dividend Yield',
     intro: 'Dividend yield is top 20% of the industry.'
     },
     {
     img: 'assess-high',
     name: 'High Valuation',
     intro: 'Valuation is top 20% of the industry.'
     },
     {
     img: 'assess-low',
     name: 'Low Valuation',
     intro: 'Valuation is lowest 20% of the industry.'
     },
     {
     img: 'trend-strong',
     name: 'Strong Trend',
     intro: 'Stock trend is top 20% of the industry.'
     },
     {
     img: 'trend-weak',
     name: 'Weak Trend',
     intro: 'Stock trend is lowest 20% of the industry.'
     },
     {
     img: 'deal-active',
     name: 'Most Active',
     intro: 'Transaction volume is top 20% of the industry.'
     }
     ]
     */

    var featureDic: [String : String] {
        switch YXUserManager.curLanguage() {
        case .EN, .ML, .TH:
                return ["profit-strong" : "High Profitability",
                        "grow-fast" : "Fast Growing",
                        "operate-nice" : "Great Operation",
                        "dividend-high" : "High Dividend Yield",
                        "assess-high" : "High Valuation",
                        "assess-low" : "Low Valuation",
                        "trend-strong" : "Strong Trend",
                        "trend-weak" : "Weak Trend",
                        "deal-active" : "Most Active"]
            case .CN:
                return ["profit-strong" : "盈利能力强",
                        "grow-fast" : "增长快",
                        "operate-nice" : "营运佳",
                        "dividend-high" : "派息高",
                        "assess-high" : "估值高",
                        "assess-low" : "估值低",
                        "trend-strong" : "走势强",
                        "trend-weak" : "走势弱",
                        "deal-active" : "成交活跃"]
            case .HK,
                 .unknown:
                return ["profit-strong" : "盈利能力強",
                        "grow-fast" : "增長快",
                        "operate-nice" : "營運佳",
                        "dividend-high" : "派息高",
                        "assess-high" : "估值高",
                        "assess-low" : "估值低",
                        "trend-strong" : "走勢強",
                        "trend-weak" : "走勢弱",
                        "deal-active" : "成交活躍"]
        }
    }


}



class YXStockAnalyzeProgressView: UIView {

    @objc var model: YXStockAnalyzeDiagnoseScoreModel? {
        didSet {

            if let tempScore = model?.list.score, tempScore >= 0 {
                let base1 = fabs(Double(model?.base ?? 0))
                let base = pow(10, base1)
                let score = Double(tempScore)
                var scoreString = String(format: "%.02f", score / base)
                if score / base > 100 {
                    scoreString = "100"
                }

                scoreLabel.text = scoreString

                if score / base > 100 {
                    progressLayer.strokeEnd = 1.0
                } else {
                    progressLayer.strokeEnd = CGFloat(score / base / 100.0)
                }
            } else {
                progressLayer.strokeEnd = 0.0
                scoreLabel.text = "--"
            }

        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func initUI() {

        drawScale()
        drawCircle()

        addSubview(scoreLabel)
        addSubview(titleLabel)
        addSubview(bottomLineView)

        scoreLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
            make.bottom.equalToSuperview().offset(-12)
        }

        bottomLineView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.width.equalTo(52)
        }

        scoreLabel.text = "--"
    }


    let ScaleNumber: Int = 45
    func drawScale() {
        let perAngel: CGFloat = CGFloat(Double.pi * 4.0 / 3.0) / CGFloat(ScaleNumber - 1)
        let maxLayer = CAShapeLayer()
        maxLayer.lineWidth = 5.0
        maxLayer.fillColor = UIColor.clear.cgColor
        maxLayer.strokeColor = QMUITheme().mainThemeColor().withAlphaComponent(0.4).cgColor
        let minLayer = CAShapeLayer()
        minLayer.lineWidth = 3.0
        minLayer.fillColor = UIColor.clear.cgColor
        minLayer.strokeColor = QMUITheme().mainThemeColor().withAlphaComponent(0.4).cgColor

        let maxPath = UIBezierPath()
        let minPath = UIBezierPath()
        for i in 0..<ScaleNumber {
            let startAngel: CGFloat = CGFloat(Double.pi * 5.0 / 6.0) + perAngel * CGFloat(i)
            let endAngel: CGFloat = startAngel +  perAngel / 5.0



            if i == 0 || i == ScaleNumber - 1 || i == (((ScaleNumber - 1) / 2)) {
                let path = UIBezierPath(arcCenter: CGPoint(x: self.width / 2.0, y: self.height / 2.0), radius: self.width / 2.0 - 2.0, startAngle: startAngel, endAngle: endAngel, clockwise: true)
                maxPath.append(path)
            } else {
                let path = UIBezierPath(arcCenter: CGPoint(x: self.width / 2.0, y: self.height / 2.0), radius: self.width / 2.0 - 3.0, startAngle: startAngel, endAngle: endAngel, clockwise: true)
                minPath.append(path)
            }

        }

        maxLayer.path = maxPath.cgPath
        minLayer.path = minPath.cgPath
        self.layer.addSublayer(maxLayer)
        self.layer.addSublayer(minLayer)

    }

    func drawCircle() {

        let backgroundLayer = CAShapeLayer()
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.qmui_color(withHexString: "#F3F3F3")?.cgColor
        backgroundLayer.lineWidth = 10
        backgroundLayer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(progressLayer)
        self.layer.addSublayer(gradientLayer)
        gradientLayer.mask = progressLayer
        let startAngel: CGFloat = CGFloat(Double.pi * 5.0 / 6.0 + Double.pi * 1.0 / 72.0)
        let endAngel: CGFloat = startAngel + CGFloat(Double.pi * 4.0 / 3.0   - Double.pi * 1.0 / 36.0)

        backgroundLayer.path = UIBezierPath(arcCenter: CGPoint(x: self.width / 2.0, y: self.height / 2.0), radius: self.width / 2.0 - 12.0, startAngle: startAngel, endAngle: endAngel, clockwise: true).cgPath

        progressLayer.path = UIBezierPath(arcCenter: CGPoint(x: self.width / 2.0, y: self.height / 2.0), radius: self.width / 2.0 - 12.0, startAngle: startAngel, endAngle: endAngel, clockwise: true).cgPath
        progressLayer.strokeEnd = 0.0

    }

    func radiusToDegresss(_ angel: CGFloat) -> CGFloat {
        return angel * CGFloat(180.0 / Double.pi)
    }

    lazy var progressLayer: CAShapeLayer =  {

        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 10
        layer.lineCap = CAShapeLayerLineCap(rawValue: "round")

        return layer
    }()

    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.qmui_color(withHexString: "#3341F3")!.cgColor, UIColor.qmui_color(withHexString: "#9B5EFF")!.cgColor]
        layer.locations = [0, 1.0]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.frame = self.bounds

        return layer
    }()


    lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = QMUITheme().themeTextColor()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return label
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.text = "综合评分"
        return label
    }()

    lazy var bottomLineView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 52.0, height: 1.0)

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.01, y: 0.5)
        gradientLayer.locations = [0, 0.5, 1.0]
        gradientLayer.colors = [UIColor.qmui_color(withHexString: "#2F79FF")?.withAlphaComponent(0.0).cgColor, UIColor.qmui_color(withHexString: "#2177FF")?.cgColor, UIColor.qmui_color(withHexString: "#2F79FF")?.withAlphaComponent(0.0).cgColor]
        view.layer.addSublayer(gradientLayer)
        return view
    }()

}
