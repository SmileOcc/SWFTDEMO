//
//  YXSmartDateView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2021/12/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit



@objcMembers class YXConditionValidtimeRequestModel: YXJYBaseRequestModel {
    
    var market: String = "HK"
    
    override func yx_requestUrl() -> String {
        "/condition-center-sg/api/condition-validtime/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXConditionValidtimeResponeseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    func yx_requestTimeoutInterval() -> TimeInterval {
        10
    }
}

@objcMembers class YXConditionValidtimeResponeseModel: YXResponseModel {
    var datas: [YXSmartDateItem]?
    
    class func modelCustomPropertyMapper() -> [String : Any]? {
        ["datas": "data.datas"]
    }
    
    class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["datas": YXSmartDateItem.self]
    }
}

@objcMembers class YXSmartDateItem: NSObject {
    var msg: String?
    var type: String?
    var validTime: String?
    var validTimeAfterHours: String?
    
    class func item(msg: String?, type: String?) -> YXSmartDateItem {
        let item = YXSmartDateItem()
        item.msg = msg
        item.type = type
        return item
    }
    
    static func defaultDateItems() -> [YXSmartDateItem] {
        return [YXSmartDateItem.item(msg: "90 Days", type: "10"),
                YXSmartDateItem.item(msg: "60 Days", type: "9"),
                YXSmartDateItem.item(msg: "30 Days", type: "6"),
                YXSmartDateItem.item(msg: "2 Weeks", type: "5"),
                YXSmartDateItem.item(msg: "1 Weeks", type: "4"),
                YXSmartDateItem.item(msg: "3 Days", type: "3"),
                YXSmartDateItem.item(msg: "2 Days", type: "2"),
                YXSmartDateItem.item(msg: "Valid until market closes", type: "1")]
    }
    
    func transformValidTime(_ tradePeriod: TradePeriod) -> String? {
        var validTimeString = validTime
        if tradePeriod == .preAfter {
            validTimeString = validTimeAfterHours ?? validTime
        }
        if let string = validTimeString, string.count > 0 {
            let dateString = YXDateHelper.commonDateString(string, format: .DF_MDYHM)
            let formatString = YXLanguageUtility.kLang(key: "end_time_template")
            return String(format: formatString, dateString)
        }
        return nil
    }
    
    func transformPickerItem(_ tradePeriod: TradePeriod) -> YXPickerItem {
        return YXPickerItem(title: msg ?? "--", type: type ?? "", desc: transformValidTime(tradePeriod))
    }
}

class YXSmartDateView: UIView, YXTradeHeaderSubViewProtocol {

    
    private var dateItems: [YXSmartDateItem]! {
        didSet {
            refreshItems()
        }
    }
    
    var tradePeriod: TradePeriod! {
        didSet {
            refreshItems()
        }
    }
    
    private(set) var selectView: YXSelectPickerView!
    convenience init(dateItems: [YXSmartDateItem] = YXSmartDateItem.defaultDateItems(), selectedType: String? = nil, tradePeriod: TradePeriod = .normal, selectedBlock:((YXSmartDateItem) -> Void)?) {
        self.init()

        self.dateItems = dateItems
        self.tradePeriod = tradePeriod
        let pickerArr = dateItems.map { item in
            return item.transformPickerItem(tradePeriod)
        }
        selectView = YXSelectPickerView(pickerArr: pickerArr, selectedType:selectedType, contentHorizontalAlignment: .left, selectedBlock: { [weak self] _, index in
            guard let strongSelf = self else { return }
            
            selectedBlock?(strongSelf.dateItems[index])
        })
        addSubview(selectView)

        selectView.snp.makeConstraints { (make) in
            make.bottom.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        contentHeight = 70
    }
    
    private func refreshItems() {
        let pickerArr = dateItems.map { item in
            return item.transformPickerItem(tradePeriod)
        }
        selectView.updateType(pickerArr)
    }
    
    func getConditionValidtime(_ market: String) {
        let requestModel = YXConditionValidtimeRequestModel()
        requestModel.market = market
        let request = YXRequest(request: requestModel)
        request.startWithBlock { [weak self] responeModel in
            if responeModel.code == .success {
                if let items = (responeModel as? YXConditionValidtimeResponeseModel)?.datas {
                    self?.dateItems = items.reversed()
                }
            }
        } failure: { _ in
            
        }

    }
}

struct YXPickerItem: Equatable {
    var title: String
    var type: String
    var desc: String?
}

class YXSelectPickerView: UIView {
    
    private(set) lazy var inputBGView: YXInputBaseView = {
        let view = YXInputBaseView()
        view.backgroundColor = .clear
        return view
    }()
    
     lazy var typeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .disabled)
        btn.contentHorizontalAlignment = contentHorizontalAlignment
        btn.titleLabel?.highlightedTextColor = QMUITheme().textColorLevel4()
        btn.setTitle(selectedItem.title, for: .normal)
        
        btn.rx.controlEvent(.touchUpInside).subscribe { [weak self] (_) in
            self?.showMenu()
        }.disposed(by: btn.rx.disposeBag)
        
        return btn
    }()
    
    lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    lazy var pickerContentView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 348 + YXConstant.safeAreaInsetsBottomHeight()))
        view.backgroundColor = QMUITheme().foregroundColor()
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        
        let label = UILabel()
        label.textAlignment = .center
        label.text = YXLanguageUtility.kLang(key: "trade_smart_order_effective_time")
        label.textColor = QMUITheme().textColorLevel3()
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(58)
        }
        
        view.addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(label.snp.bottom)
            make.height.equalTo(240)
        }
        
        let button = UIButton()
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(pickerView.snp.bottom)
            make.height.equalTo(50)
        }
        
        button.qmui_tapBlock = { [weak self] _ in
            guard let strongSelf = self else { return }
            
            if let index = strongSelf.tempSelectedIndex {
                strongSelf.selectedIndex = index
            }
            strongSelf.selectedBlock?(strongSelf.selectedType, strongSelf.selectedIndex)
            strongSelf.hideMenu()
        }
        
        return view
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = arrowImage
        imageView.highlightedImage = arrowImage?.qmui_image(withTintColor: QMUITheme().textColorLevel4())
        imageView.contentMode = .center
        return imageView
    }()
    
    private var tempSelectedIndex: Int?
    
    var isEnabled: Bool = true {
        didSet {
            typeButton.titleLabel?.isHighlighted = !isEnabled
            arrowImageView.isHighlighted = !isEnabled
            typeButton.isEnabled = isEnabled
        }
    }
    
    private(set) var selectedItem: YXPickerItem! {
        didSet {
            if oldValue != selectedItem {
                selectedType = typeArr[selectedIndex]
                typeButton.setTitle(selectedItem.title, for: .normal)
                bottomLabel.text = selectedItem.desc
            }
        }
    }
    
    private var pickerArr: [YXPickerItem]! {
        didSet {
            if oldValue != pickerArr {
                typeArr = pickerArr.map{ $0.type }
                updateUI()
            }
        }
    }
    private var typeArr: [String]!
    private var selectedType: String! {
        didSet {
            selectedIndex = typeArr.firstIndex(of: selectedType)
        }
    }
    private var selectedIndex: Int! {
        didSet {
            selectedItem = pickerArr[selectedIndex]
            pickerView.selectRow(selectedIndex, inComponent: 0, animated: true)
        }
    }
    
    private var selectedBlock: ((String, Int) -> Void)?
    private var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment!
    private var arrowImage: UIImage!
    convenience init(pickerArr: [YXPickerItem], selectedType: String? = nil,
                     contentHorizontalAlignment: UIControl.ContentHorizontalAlignment = .right,
                     arrowImage: UIImage? = nil,
                     selectedBlock:((String, Int) -> Void)?) {
        self.init()
        
        self.pickerArr = pickerArr
        self.contentHorizontalAlignment = contentHorizontalAlignment
        self.arrowImage = arrowImage ?? UIImage(named: "pull_down_arrow_20")
        self.selectedBlock = selectedBlock
        
        typeArr = pickerArr.map{ $0.type }
        if let type = selectedType, typeArr.contains(type) {
            selectedIndex = typeArr.firstIndex(of: type) ?? 0
            selectedItem = pickerArr[selectedIndex]
            self.selectedType = selectedType
        } else {
            selectedIndex = 0
            selectedItem = pickerArr.first
            self.selectedType = typeArr.first
        }
        
        initUI()
        updateUI()
        
        bottomLabel.text = selectedItem.desc

        DispatchQueue.main.async {
            selectedBlock?(self.selectedType, self.selectedIndex)
        }
    }
    
    private func initUI() {
        addSubview(inputBGView)
        addSubview(typeButton)
        addSubview(arrowImageView)
        addSubview(bottomLabel)

        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.addActionBlock { [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.typeButton.isEnabled {
                strongSelf.showMenu()
            }
        }
        addGestureRecognizer(tap)
  
        inputBGView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(48)
        }
        
        bottomLabel.snp.makeConstraints { make in
            make.left.right.equalTo(inputBGView)
            make.top.equalTo(inputBGView.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
        
        typeButton.snp.makeConstraints { (make) in
            make.left.top.equalTo(inputBGView)
            make.bottom.equalTo(inputBGView).offset(-1)
            make.right.equalTo(arrowImageView.snp.left)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalTo(inputBGView)
            make.centerY.equalTo(inputBGView)
            make.height.equalTo(inputBGView)
            make.width.equalTo(arrowImage.size.width)
        }
    }
    
    private func updateUI() {
        if typeArr.count <= 1 {
            arrowImageView.isHidden = true
            typeButton.isEnabled = false
            arrowImageView.snp.updateConstraints { make in
                make.width.equalTo(0)
            }
            
            typeButton.titleEdgeInsets = .zero
        } else {
            arrowImageView.isHidden = false
            typeButton.isEnabled = true
            arrowImageView.snp.updateConstraints { make in
                make.width.equalTo(arrowImage.size.width)
            }
            
            typeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        }
        
        pickerView.reloadAllComponents()
    }
    
    private func showMenu() {
        pickerContentView.show(in: UIViewController.current(), preferredStyle: .actionSheet, backgoundTapDismissEnable: true)
        
        pickerView.selectRow(selectedIndex, inComponent: 0, animated: true)
    }
    
    private func hideMenu() {
        pickerContentView.hide()
    }
    
    func updateType(_ pickerArr: [YXPickerItem]? = nil, selected: String? = nil) {
        if let array = pickerArr, self.pickerArr != array {
            self.pickerArr = array
            
            if typeArr.count > 0 {
                if let selected = selected {
                    selectedType = selected
                }
                if !typeArr.contains(selectedType) {
                    selectedType = typeArr.first
                } else {
                    selectedIndex = typeArr.firstIndex(of: selectedType)
                }
            }
        } else {
            if let selected = selected, selected != selectedType {
                if typeArr.contains(selected) {
                    selectedType = selected
                }
            }
        }
        selectedBlock?(selectedType, selectedIndex)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension YXSelectPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typeArr.count
    }
}

extension YXSelectPickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let item = pickerArr[row]
                
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4.0
        paragraph.alignment = .center
    
        let attributedString = NSMutableAttributedString(string: item.title,
                                                         attributes: [.paragraphStyle : paragraph,
                                                                      .font : UIFont.systemFont(ofSize: 16, weight: .medium),
                                                                      .foregroundColor : QMUITheme().textColorLevel1()])
        if let desc = item.desc {
            attributedString.append(NSAttributedString(string: "\n" + desc,
                                                       attributes: [.paragraphStyle : paragraph,
                                                                    .font : UIFont.systemFont(ofSize: 12),
                                                                    .foregroundColor : QMUITheme().textColorLevel3()]))
        }
        
        let label = view as? UILabel ?? UILabel()
        label.numberOfLines = 2
        label.attributedText = attributedString
    
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tempSelectedIndex = row
    }
}
