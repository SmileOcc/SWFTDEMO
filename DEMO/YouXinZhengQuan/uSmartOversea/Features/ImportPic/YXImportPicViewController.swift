//
//  YXImportPicViewController.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/6/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import QCloudCore
import RxDataSources

extension ImportSecu: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        (market ?? "") + (symbol ?? "")
    }
}

class _QMUILabel: QMUILabel {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var result = super.sizeThatFits(size)
        
        let finalSize = max(result.width, 20)
        if result.width < finalSize  {
            result = CGSize(width: finalSize, height: finalSize)
        }
        
        return result;
    }
}

class YXImportPicViewController: YXHKViewController, ViewModelBased {
    typealias ViewModelType = YXImportPicViewModel
    
    var viewModel: YXImportPicViewModel! = YXImportPicViewModel()
    
    lazy var contentView: UIImageView = {
        let imageView = UIImageView()
        let type = YXUserManager.curLanguage()
        let resource = "import_launch_" + type.identifier
        let path = Bundle.main.path(forResource: resource, ofType: ".jpg")
        imageView.image = UIImage(contentsOfFile: path ?? "")
        return imageView
    }()
    
    lazy var leftTopView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "left_top"))
        return imageView
    }()
    
    lazy var rightBottomView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "right_bottom"))
        return imageView
    }()
    
    lazy var tipsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "import_tips")
        return imageView;
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.text = "       " + YXLanguageUtility.kLang(key: "addstock_photo_upload_tips")
        label.textColor = QMUITheme().textColorLevel2()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var uploadButton: QMUIButton = {
        let button = QMUIButton()
        button.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().mainThemeColor()), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "addstock_photo_upload_btn"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    
    lazy var middleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var middleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.isHidden = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var tableView: QMUITableView  = {
        let tableView = QMUITableView(frame: view.bounds, style: .plain)
        tableView.isHidden = true
        return tableView
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#F5F5F5")
        view.isHidden = true
        return view
    }()
    
    lazy var allSelectButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "import_select"), for: .normal)
        button.setImage(UIImage(named: "import_selected"), for: .selected)
        button.setTitle(YXLanguageUtility.kLang(key: "addstock_photo_select_all"), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.imagePosition = .left
        button.titleLabel?.font = .systemFont(ofSize: 16)
        return button
    }()
    
    lazy var importButton: QMUIButton = {
        let title: String = YXLanguageUtility.kLang(key: "addstock_photo_import_btn")
        let size = (title as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        let button = QMUIButton()
        button.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().themeTextColor()), for: .selected)
        button.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().textColorLevel2()), for: .normal)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: size.width/2 + 5)
        return button
    }()
    
    lazy var selectedNumLabel: _QMUILabel = {
        let label = _QMUILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 1
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        label.text = "0"
        return label
    }()

//    var selectedImagePath: String?
//    var selectedImage: UIImage?
    
    let dataSource = BehaviorRelay<[ImportSecu]>(value: [])
    let selectedStock = BehaviorRelay<[ImportSecu]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = YXLanguageUtility.kLang(key: "addstock_photo_upload_title")
        
        setupContent()
        setupMiddle()
        setupResult()
        
        viewModel.importResult.asDriver().skip(1).drive(onNext: { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            if let code = result?.code {
                if code == 0 {
                    if let data = result?.data, let list = data.arrList {
                        strongSelf.showResult(list)
                    } else {
                        strongSelf.showImportEmpty()
                    }
                } else if code == 910005 || code == 910001 {
                    strongSelf.showImportEmpty()
                } else {
                    strongSelf.showImportNetworkError()
                }
            } else {
                strongSelf.showImportNetworkError()
            }
        }).disposed(by: disposeBag)
        
        let CellIdentifier = "Cell"
        
        dataSource.bind(to: tableView.rx.items) { [weak self] (tableView, row, item) in
            guard let strongSelf = self else { return YXImportStockCell(style: .subtitle, reuseIdentifier: CellIdentifier) }
            
            var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
            if cell == nil {
                cell = YXImportStockCell(style: .subtitle, reuseIdentifier: CellIdentifier)
                let importCell = cell as! YXImportStockCell
                importCell.rightBtn.rx.tap.subscribe(onNext: { [weak self] () in
                    guard let strongSelf = self else { return }
                    
                    importCell.rightBtn.isSelected = !importCell.rightBtn.isSelected
                    
                    if importCell.rightBtn.isSelected == true {
                        if let importStock = importCell.importStock {
                            strongSelf.selectedStock.accept(strongSelf.selectedStock.value + [importStock])
                        }
                    } else {
                        var array = strongSelf.selectedStock.value
                        if let item = importCell.importStock {
                            if let index = array.firstIndex(of: item) {
                                array.remove(at: index)
                            }
                        }
                        strongSelf.selectedStock.accept(array)
                    }
                    
                }).disposed(by: strongSelf.disposeBag)
            }
            (cell as? YXImportStockCell)?.importStock = item
            cell?.textLabel?.setStockName(item.stockName)
            cell?.detailTextLabel?.text = item.symbol
            if let market = item.market, let symbol = item.symbol, market != "us"{
                cell?.detailTextLabel?.text = symbol + "." + market.uppercased()
            }
            
            if let importCell = cell as? YXImportStockCell {
                if strongSelf.selectedStock.value.contains(item) {
                    importCell.rightBtn.isSelected = true
                } else {
                    importCell.rightBtn.isSelected = false
                }
            }
            return cell!
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asDriver().drive(onNext: { [weak self] (indexPath) in
            guard let strongSelf = self else { return }
            
            strongSelf.tableView.deselectRow(at: indexPath, animated: true)
            if let importCell = strongSelf.tableView.cellForRow(at: indexPath) as? YXImportStockCell {
                importCell.rightBtn.isSelected = !importCell.rightBtn.isSelected
                let item = strongSelf.dataSource.value[indexPath.row]
                if importCell.rightBtn.isSelected == true {
                    strongSelf.selectedStock.accept(strongSelf.selectedStock.value + [item])
                } else {
                    var array = strongSelf.selectedStock.value
                    if let item = importCell.importStock {
                        if let index = array.firstIndex(of: item) {
                            array.remove(at: index)
                        }
                    }
                    strongSelf.selectedStock.accept(array)
                }
            }
        }).disposed(by: disposeBag)
        
        selectedStock.asDriver().drive(onNext: { [weak self] (stocks) in
            guard let strongSelf = self else { return }
            
            strongSelf.selectedNumLabel.text = "\(stocks.count)"
            if stocks.count > 0 {
                strongSelf.importButton.isSelected = true
            } else {
                strongSelf.importButton.isSelected = false
            }
            
            if stocks.count > 0,
                stocks.sorted(by: {$0.identity > $1.identity}) == strongSelf.dataSource.value.sorted(by: {$0.identity > $1.identity}) {
                strongSelf.allSelectButton.isSelected = true
            } else {
                strongSelf.allSelectButton.isSelected = false
            }
        }).disposed(by: disposeBag)
    }
    
    func showResult(_ list: [ImportSecu]) {
        middleImageView.isHidden = true
        middleLabel.isHidden = true
        
        tableView.isHidden = false
        bottomView.isHidden = false
        
        dataSource.accept(list)
        selectedStock.accept(list)
    }
    
    func showImportNetworkError() {
        middleImageView.isHidden = false
        middleLabel.isHidden = false
        
        middleImageView.image = UIImage(named: "import_network")
        middleLabel.text = YXLanguageUtility.kLang(key: "common_net_error")
        
        uploadButton.isHidden = false
        uploadButton.setTitle(YXLanguageUtility.kLang(key: "addstock_photo_upload_again"), for: .normal)
    }
    
    func showImportEmpty() {
        middleImageView.isHidden = false
        middleLabel.isHidden = false
        
        middleImageView.image = UIImage(named: "import_error")
        middleLabel.text = YXLanguageUtility.kLang(key: "addstock_photo_not_clear")
        
        uploadButton.isHidden = false
        uploadButton.setTitle(YXLanguageUtility.kLang(key: "addstock_photo_upload_again"), for: .normal)
    }
    
    func setupResult() {
        view.addSubview(tableView)
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(YXConstant.tabBarHeight())
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(YXConstant.navBarHeight())
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        bottomView.addSubview(allSelectButton)
        bottomView.addSubview(importButton)
        importButton.addSubview(selectedNumLabel)
        
        allSelectButton.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.top.equalTo(bottomView)
            make.height.equalTo(48)
        }
        
        importButton.snp.makeConstraints { (make) in
            make.right.top.equalTo(bottomView)
            make.width.equalTo(127)
            make.height.equalTo(48)
        }
        
        selectedNumLabel.snp.makeConstraints { (make) in
            make.left.equalTo(importButton.snp.centerX).offset(importButton.titleEdgeInsets.right - 15)
            make.centerY.equalTo(importButton)
            make.height.equalTo(20)
        }
        
        allSelectButton.rx.tap.takeUntil(rx.deallocated).subscribe(onNext: { [weak self] () in
            guard let strongSelf = self else { return }
            strongSelf.allSelectButton.isSelected = !strongSelf.allSelectButton.isSelected
            
            if strongSelf.allSelectButton.isSelected == true {
                strongSelf.selectedStock.accept(strongSelf.dataSource.value)
            } else {
                strongSelf.selectedStock.accept([])
            }
            strongSelf.dataSource.accept(strongSelf.dataSource.value)
        }).disposed(by: disposeBag)
        
        importButton.rx.tap.takeUntil(rx.deallocated).subscribe(onNext: { [weak self] () in
            guard let strongSelf = self else { return }
            
            if strongSelf.importButton.isSelected == true {
                let secuIds = strongSelf.selectedStock.value.map({ (obj) -> YXOptionalSecu in
                    let secu = YXOptionalSecu()
                    secu.name = obj.stockName ?? ""
                    secu.market = obj.market ?? ""
                    secu.symbol = obj.symbol ?? ""
                    return secu
                })
                if YXSecuGroupManager.shareInstance().append(secuIds) == true {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil)
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "addstock_photo_imported"))
                } else {
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "addstock_photo_too_much"))
                }
            } else {
                YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "addstock_photo_not_selected"))
            }
        }).disposed(by: disposeBag)
        
    }
    
    func setupContent() {
        view.addSubview(tipsLabel)
        tipsLabel.addSubview(tipsImageView)
        
        view.addSubview(contentView)
        contentView.addSubview(leftTopView)
        contentView.addSubview(rightBottomView)
        
        view.addSubview(uploadButton)
        
        tipsLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(contentView.snp.bottom).offset(24)
            make.height.equalTo(20)
            make.left.greaterThanOrEqualTo(view).offset(10)
            make.right.lessThanOrEqualTo(view).offset(-10)
        }
        
        tipsImageView.snp.makeConstraints { (make) in
            make.left.equalTo(tipsLabel)
            make.centerY.equalTo(tipsLabel)
        }
        
        var width = 300
        if YXConstant.screenWidth == 320 {
            width = 240
        }
        contentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24 + YXConstant.navBarHeight())
            make.centerX.equalTo(view)
            make.width.equalTo(width)
            make.height.equalTo(contentView.snp.width).multipliedBy(680.0/600.0)
        }
        
        leftTopView.snp.makeConstraints { (make) in
            make.top.left.equalTo(contentView)
        }
        
        rightBottomView.snp.makeConstraints { (make) in
            make.bottom.right.equalTo(contentView)
        }
        
        uploadButton.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(48)
            make.top.equalTo(tipsLabel.snp.bottom).offset(12)
        }
        
        uploadButton.rx.tap.takeUntil(rx.deallocated).subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.showAlert()
        }).disposed(by: disposeBag)
    }
    
    func setupMiddle() {
        view.addSubview(middleImageView)
        view.addSubview(middleLabel)
        
        middleImageView.snp.makeConstraints { (make) in
            make.top.equalTo(YXConstant.navBarHeight() + 100)
            make.size.equalTo(CGSize(width: 100, height: 100))
            make.centerX.equalTo(view)
        }
        
        middleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(middleImageView.snp.bottom).offset(30)
            make.left.equalTo(view).offset(34)
            make.right.equalTo(view).offset(-34)
        }
    }
    
    func showAlert() {
        let cancelAlertAction = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .default) { (alertController, action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        cancelAlertAction.buttonAttributes =  [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        //相机
        let cameraAlertAction = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "addstock_photo_take_photo"), style: .default) { [weak self] (alertController, action) in
            self?.showCamera()
        }
        cameraAlertAction.buttonAttributes = [NSAttributedString.Key.foregroundColor: QMUITheme().textColorLevel1(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        //相册
        let albumAlertAction = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "addstock_photo_album"), style: .default, handler: { [weak self] (alertController, action) in
            
            self?.showImageLibrary()
        })

        albumAlertAction.buttonAttributes = [NSAttributedString.Key.foregroundColor: QMUITheme().textColorLevel1(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        //弹框
        let alertController = QMUIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.sheetContentMargin = UIEdgeInsets(top: 0, left: 20, bottom: YXConstant.deviceScaleEqualToXStyle() ? 0 : 34, right: 20)
        alertController.sheetCancelButtonMarginTop = 0
        alertController.sheetSeparatorColor = QMUITheme().separatorLineColor()
        alertController.sheetButtonBackgroundColor = QMUITheme().foregroundColor()
        alertController.sheetButtonHeight = 59
        alertController.sheetContentCornerRadius = 20
        alertController.addAction(albumAlertAction)
        alertController.addAction(cameraAlertAction)
        alertController.addAction(cancelAlertAction)
        alertController.showWith(animated: true)
    }
    
    func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera;
            imagePickerController.cameraDevice = .rear;
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func showImageLibrary() {
        let language: String? = YXUserManager.curLanguage().identifier
        
        TZImagePickerConfig.sharedInstance()?.preferredLanguage = language
        let imagePickerViewController = TZImagePickerController(maxImagesCount: 1, columnNumber: 3, delegate: self)
        imagePickerViewController?.preferredLanguage = language
        imagePickerViewController?.naviTitleColor = QMUITheme().textColorLevel1()
        imagePickerViewController?.barItemTextColor = QMUITheme().textColorLevel1()
        imagePickerViewController?.naviBgColor = QMUITheme().foregroundColor()
        //imagePickerViewController?.iconThemeColor = QMUITheme().darkThemeColor()
        imagePickerViewController?.showSelectedIndex = false
        imagePickerViewController?.showSelectBtn = false
        
        imagePickerViewController?.navLeftBarButtonSettingBlock = { (leftButton) in
            leftButton?.setImage(UIImage(named: "nav_back"), for: .normal)
            leftButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -32, bottom: 0, right: 0)
            }
        imagePickerViewController?.sortAscendingByModificationDate = false
        imagePickerViewController?.allowPickingOriginalPhoto = false
        imagePickerViewController?.allowPickingVideo = false
        imagePickerViewController?.allowTakePicture = false

        imagePickerViewController?.oKButtonTitleColorNormal = QMUITheme().themeTextColor().withAlphaComponent(0.4)
        imagePickerViewController?.didFinishPickingPhotosHandle = { [weak self] (photos, assets, isSelectOriginalPhoto) in
            guard let strongSelf = self else { return }
            
            if let image = photos?.first {
                strongSelf.didSelect(image)
            }
        }
        
        imagePickerViewController?.photoPreviewPageDidLayoutSubviewsBlock = {
            (collectionView, naviBar, backButton, selectButton, indexLabel, toolBar, originalPhotoButton, originalPhotoLabel, doneButton, numberImageView, numberLabel) in
            naviBar?.backgroundColor = UIColor.white
            toolBar?.backgroundColor = UIColor.white
            backButton?.setImage(UIImage(named: "nav_back"), for: .normal)
            
            let label = UILabel()
            label.text = YXLanguageUtility.kLang(key: "common_preview")
            label.textColor = QMUITheme().textColorLevel1()
            label.font = UIFont.systemFont(ofSize: 16)
            label.sizeToFit()
            label.center = CGPoint(x: naviBar?.center.x ?? 0, y: YXConstant.statusBarHeight() + 20)
            naviBar?.addSubview(label)
            backButton?.imageEdgeInsets = UIEdgeInsets(top: 10, left: -10, bottom: 0, right: 0)
            doneButton?.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
            var rect = toolBar?.bounds ?? .zero
            rect.size.height = 48
            doneButton?.frame = rect
            doneButton?.backgroundColor = QMUITheme().themeTextColor()
            doneButton?.setTitleColor(.white, for: .normal)
        }
        self.present(imagePickerViewController!, animated: true, completion: nil)
    }
    
    func didSelect(_ image: UIImage) {
        contentView.isHidden = true
        tipsLabel.isHidden = true
        title = YXLanguageUtility.kLang(key: "addstock_photo_result")
        uploadButton.isHidden = true
        
        middleLabel.isHidden = false
        middleImageView.isHidden = false
        middleLabel.text = YXLanguageUtility.kLang(key: "addstock_photo_loading")
        middleImageView.image = UIImage(named: "import_loading")
        
        DispatchQueue.global().async { [weak self] in
            let data = image.compressQualityLessMaxLength(1000 * 1000)
            DispatchQueue.main.async {
                self?.viewModel.upload(imageData: data)
            }
        }
    }
}

extension YXImportPicViewController: TZImagePickerControllerDelegate {
    
}

extension YXImportPicViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[.originalImage] as? UIImage {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.didSelect(image)
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
