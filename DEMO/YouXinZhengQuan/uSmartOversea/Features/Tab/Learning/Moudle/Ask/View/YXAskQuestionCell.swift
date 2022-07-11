//
//  YXAskQuestionCell.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import QMUIKit
import SnapKit
import RxSwift

enum YXAskQuestionTagType {
    case forme
    case kol
    case none
}

class YXAskQuestionCell: UITableViewCell{
    var disposeBag: DisposeBag = DisposeBag()

    var canDelete: Bool = false
    /// 头像
    lazy var kolHearderView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    /// 名称
    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 1
        return label
    }()
    
    
    
    /// 日期
    lazy var dateLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = QMUITheme().textColorLevel3()
        label.numberOfLines = 1
        return label
    }()
    
    ///问题内容
    lazy var contentLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 3
        return label
    }()
    
    ///股票
    lazy var stockFloatView: QMUIFloatLayoutView = {
        let float = QMUIFloatLayoutView()
        float.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        float.itemMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        float.minimumItemSize = CGSize(width: 52, height: 16)
        float.clipsToBounds = true
        return float
    }()
    
    //股票
    lazy var stockLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().themeTextColor()
        return label
    }()
    
    lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    /// 总回答数量
    lazy var answerCount: QMUIButton = {
        let view = QMUIButton()
        view.setImage(UIImage(named: "ask_all_answer_count_icon"), for: .normal)
        view.isUserInteractionEnabled = false
        view.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 14)
        view.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        return view
    }()
    
    var questionType: YXAskQuestionTagType = .none {
        didSet {
            switch questionType {
            case .none:
                questionBtn.isHidden = true
                questionBtn.setTitle("", for: .normal)
            case .forme:
                questionBtn.isHidden = false
                questionBtn.setBackgroundImage(UIImage(gradientColors: [UIColor(hexString: "EE7F48")!,UIColor(hexString: "F29B5D")!],isHorizontal: false), for: .normal)
                questionBtn.setTitle(YXLanguageUtility.kLang(key: "nbb_ask_tag_kol_for_me"), for: .normal)
            case .kol:
                questionBtn.isHidden = false
                questionBtn.setBackgroundImage(UIImage(gradientColors: [UIColor(hexString: "4393FA")!,UIColor(hexString: "2E47FE")!],isHorizontal: false), for: .normal)
                questionBtn.setTitle(YXLanguageUtility.kLang(key: "nbb_ask_tag_kol_only"), for: .normal)
            }
        }
    }
    
    lazy private var questionBtn: QMUIButton = {
        let view = QMUIButton()

        view.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMaxXMaxYCorner,.layerMinXMinYCorner]
        view.layer.cornerRadius = 11
        view.layer.masksToBounds = true
        view.setTitle("KOL", for: .normal)
        view.isUserInteractionEnabled = false
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return view
    }()
    
    lazy var longPress: UILongPressGestureRecognizer = {
        let ges = UILongPressGestureRecognizer(target: self, action: #selector(longPressEvent(sender:)))
        ges.minimumPressDuration = 1
        return ges
    }()
    
    var deleteCallback: (()->Void)?
    
    @objc func longPressEvent(sender: UIGestureRecognizer) {
        if canDelete {
            if sender.state == .began {
                if let touchView = sender.view {
                    self.becomeFirstResponder()
                    let deleteItem = UIMenuItem(title:YXLanguageUtility.kLang(key: "nbb_delete"), action: #selector(deleteContent))
                    let menu = UIMenuController.shared
                    menu.menuItems = [deleteItem]
                    menu.update()
                    let point = sender.location(in: touchView)
                    if #available(iOS 13.0, *) {
                        menu.showMenu(from: touchView, rect: CGRect(x: point.x, y: point.y , width:30, height: 20))
                    } else {
                        menu.setTargetRect(CGRect(x: point.x, y: point.y , width:30, height: 20), in: touchView)
                        menu.isMenuVisible = true
                    }
                }
            }
        }
    }
    
    @objc func deleteContent() {
        self.deleteCallback?()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(deleteContent)
    }
    
    /// kol回答数量
    lazy var kolAnswerCount: QMUIButton = {
        let view = QMUIButton()
        view.setImage(UIImage(named: "ask_kol_answer_count_icon"), for: .normal)
        view.isUserInteractionEnabled = false
        view.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 14)
        view.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag =  DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        selectionStyle = .none
        contentView.backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(kolHearderView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(stockFloatView)
        contentView.addSubview(answerCount)
        contentView.addSubview(kolAnswerCount)
        contentView.addSubview(line)
        contentView.addSubview(questionBtn)
        
        contentView.addGestureRecognizer(longPress)
        
        questionBtn.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.top.equalTo(23)
            make.height.equalTo(20)
        }
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.top.equalToSuperview()
            make.height.equalTo(0.3)
        }
        
        kolHearderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(23)
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(kolHearderView.snp.top)
            make.left.equalTo(kolHearderView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalTo(kolHearderView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        
        stockFloatView.snp.makeConstraints { make in
            make.left.equalTo(kolHearderView.snp.right).offset(8)
            make.top.equalTo(kolHearderView.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(20)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(kolHearderView.snp.right).offset(8)
            make.top.equalTo(stockFloatView.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-16)
        }
        
        answerCount.snp.makeConstraints { make in
            make.left.equalTo(kolHearderView.snp.right).offset(8)
            make.top.equalTo(contentLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.lessThanOrEqualTo(150)
        }
        
        kolAnswerCount.snp.makeConstraints { make in
            make.left.equalTo(answerCount.snp.right).offset(8)
            make.top.equalTo(contentLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.lessThanOrEqualTo(150)
        }
        
        questionBtn.setContentHuggingPriority(.required, for: .horizontal)
        questionBtn.setContentCompressionResistancePriority(.required, for: .horizontal)
        
    }
    
    func displayCount(count: Int) -> String {
        if count > 1000 && count < 10000 {
            let s = String(format:"%.2f",Double(count/1000))
            return "\(s) k"
        } else if count > 10000 {
            let s = String(format:"%.2f",Double(count/10000))
            return "\(s) w"
        }
        return "\(count)"
    }
    
    func configure(model: YXAskItemResModel?, businessType: YXAskListType) {
        if let model = model {
            if let urlStr = model.askImg, let url = URL(string: urlStr) {
                kolHearderView.sd_setImage(with: url, placeholderImage: UIImage(named: "user_default_photo"))
            } else {
                kolHearderView.image = UIImage(named: "user_default_photo")
            }
            nameLabel.text = model.askName
            dateLabel.text = model.questionTime

            stockFloatView.removeAllSubviews()
            
            let stockBtns = model.stockInfoDTOList?.map({ s -> QMUIButton in
                let btn = QMUIButton()
                let title = s.stockName != nil ? "$\(s.stockName!)$" : ""
                btn.setTitle(title, for: .normal)
                btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                btn.setTitleColor(UIColor(hexString: "3C76DE"), for: .normal)
                btn.rx.tap.asObservable().subscribe(onNext: {
                    if let market = s.market, let symbol = s.symbol {
                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    NavigatorServices.shareInstance.pushPath(YXModulePaths.stockDetail, context: ["dataSource" : [input], "selectIndex" : 0], animated: true)
                }
                }).disposed(by: self.disposeBag)

                return btn
            })
            
            stockBtns?.forEach({ [weak self] btn in
                self?.stockFloatView.addSubview(btn)
            })
            let size = stockFloatView.sizeThatFits(CGSize(width: YXConstant.screenWidth - 32, height: YXConstant.screenHeight))

            stockFloatView.snp.updateConstraints { make in
                make.height.equalTo(size.height)
            }
            
            contentLabel.text = model.questionDetail
            
            answerCount.setTitle("\(displayCount(count: model.replyAllNum)) \(YXLanguageUtility.kLang(key: "nbb_ask_tips_answer"))", for: .normal)
            kolAnswerCount.setTitle("\(displayCount(count: model.replyKolNum)) \(YXLanguageUtility.kLang(key: "nbb_ask_tips_kol_answer"))", for: .normal)
            if businessType == .kol {
                canDelete = false
            } else {
                canDelete = model.deleteFlag
            }
        }
    }
    
}
