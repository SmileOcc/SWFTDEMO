//
//  YXWarrantsSearchListController.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/8/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import YXKit

class YXWarrantsSearchListController: UITableViewController {

//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var headerRightBtn: UIButton!
//    @IBOutlet weak var allBtn: UIButton!
    
    lazy var arrowRightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrow_right_light")
        return imageView
    }()
    
    lazy var allButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.addSubview(arrowRightImageView)
        button.setTitle(YXLanguageUtility.kLang(key: "warrants_look_all"), for: .normal)
        button.backgroundColor = QMUITheme().foregroundColor()
        _ = button.rx.tap.asControlEvent().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (btn) in
            guard let `self` = self else { return }
            self.viewModel?.allDidSelected.onNext(true)
        })
        return button
    }()
    
    lazy var cleaAllButton: UIButton = {
        let button = UIButton()
        let imageName = viewModel?.headerRightNormalImage ?? ""
        button.setImage(UIImage(named: imageName), for: .normal)
        _ = button.rx.tap.asControlEvent().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (btn) in
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "warrants_remove"))
            self?.viewModel?.headerRightAction(sender: self?.cleaAllButton)
        })
        return button
    }()
    
    lazy var tableHeader: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 56))
        view.addSubview(arrowRightImageView)
        view.addSubview(allButton)
        arrowRightImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        allButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        return view
    }()
    
    lazy var sectionHeader: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = viewModel?.title
        
        view.addSubview(label)
        view.addSubview(cleaAllButton)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-10)
        }
        cleaAllButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(label)
        }
        return view
    }()
    
    var viewModel: YXSearchListViewModel?
    
    var warrantType: YXStockWarrantsType = .bullBear {
        didSet {
            if warrantType == .bullBear {
                allButton.setTitle(YXLanguageUtility.kLang(key: "warrants_look_all"), for: .normal)
                self.tableView.tableHeaderView = tableHeader
            } else if warrantType == .inlineWarrants {
                allButton.setTitle(YXLanguageUtility.kLang(key: "warrants_all_inline_warrant"), for: .normal)
                self.tableView.tableHeaderView = tableHeader
            } else if warrantType == .CBBC {
                self.tableView.tableHeaderView = UIView()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        _ = viewModel?.list.asObservable().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (list) in
            
            if let count = self?.viewModel?.list.value?.count(), count > 0 {
                self?.sectionHeader.isHidden = false
            } else {
                self?.sectionHeader.isHidden = true
            }
        })
        
        initiateUI()
    }
    
    func initiateUI() {
        
        _ = viewModel?.list.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (list) in
            self?.tableView.reloadData()
        })
    }
    
    func hideAllBtn() {

        self.tableView.tableHeaderView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.list.value?.count() ?? 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sectionHeader.frame = CGRect(x: 0, y: 0, width: tableView.width, height: 40)
        return sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        68
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "YXSearchListCell") as! YXSearchListCell
        
        if let list = viewModel?.list.value, let item = list.item(at: indexPath.row) {
            cell.stockInfoView.nameLabel.attributedText = item.attributedName(with: list.param?.q)
            cell.stockInfoView.symbolLabel.attributedText = item.attributedSymobl(with: list.param?.q)
            cell.stockInfoView.market = item.market
            
            if let image = viewModel?.cellRightNormalImage {
                cell.rightBtn.setImage(UIImage(named:image), for: .normal)
                cell.rightBtn.isHidden = false
            } else {
                cell.rightBtn.isHidden = true
            }
            cell.rightBtnAction = { [weak self](sender) in
                
                if let searchCtrl = self?.next?.next as? YXNewSearchViewController {
                    searchCtrl.searchBar.textField.resignFirstResponder()
                }
                
                self?.viewModel?.cellRightAction(sender: sender, at: indexPath.row)
            }
            
            if let image = viewModel?.cellRightSelectedImage {
                cell.rightBtn.setImage(UIImage(named:image), for: .selected)
            }
            cell.rightBtn.isSelected = YXSecuGroupManager.shareInstance().containsSecu(item)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.viewModel?.cellTapAction(at: indexPath.row)
    }
    
    
    deinit {
        print(">>>>>>> \(NSStringFromClass(YXWarrantsSearchListController.self)) deinit")
    }

}
