//
//  YXStockFilterSelectedConditionView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/7.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockFilterSelectedConditionView: UIView {
    
    var didDeleteConditionAction: ((_ actionType: YXStockFilterActionType) -> Void)?
    var didClickItemAction: ((_ item: YXStockFilterItem) -> Void)?
    var hideAction: (() -> Void)?
    
    var dataSources: [YXStockFilterItem] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    lazy var contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    lazy var tableView: YXTableView = {
        let tableView = YXTableView.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = QMUITheme().foregroundColor()
        
        return tableView
    }()
    
    lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "clear_conditions"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.didDeleteConditionAction?(.unSelectedAll)
        })
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ad_close"), for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            self?.hideAction?()
        })
        return button
    }()
    
    func reload(withDatas datas: [YXStockFilterItem]) {
        dataSources = datas
        tableView.reloadData()
    }
    
    func show(withDatas datas: [YXStockFilterItem], inView view: UIView) {
        
        dataSources = datas
        tableView.reloadData()
        
        view.addSubview(self)
        
        self.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
            } else {
                make.bottom.equalToSuperview().offset(-50)
            }
        }
        
        self.layoutIfNeeded()
        
        contentContainerView.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    override func hide() {
        contentContainerView.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }) { (isFinish) in
            self.removeFromSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        let button = UIButton()
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](e) in
            self?.hideAction?()
        })
        addSubview(button)
        button.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        tableView.register(YXStockFilterSelectedConditionCell.self, forCellReuseIdentifier: NSStringFromClass(YXStockFilterSelectedConditionCell.self))
        
        let grayView = UIView()
        grayView.backgroundColor = QMUITheme().backgroundColor()
        
        grayView.addSubview(cancelButton)
        grayView.addSubview(clearButton)
        
        cancelButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        
        clearButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
        
        contentContainerView.addSubview(grayView)
        contentContainerView.addSubview(tableView)
        
        grayView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(grayView.snp.bottom)
            make.height.equalTo(160)
        }
        
        self.addSubview(contentContainerView)
        
        contentContainerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YXStockFilterSelectedConditionView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXStockFilterSelectedConditionCell.self), for: indexPath) as! YXStockFilterSelectedConditionCell
        let model = dataSources[indexPath.row]
        cell.model = model
        cell.deleteAction = { [weak self] in
            self?.didDeleteConditionAction?(.unSelectedItem(item: model))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSources[indexPath.row]
        self.hideAction?()
        self.didClickItemAction?(model)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0
    }
}
