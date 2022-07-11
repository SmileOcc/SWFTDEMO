//
//  YXUGCRecommandUserCollectionViewCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUGCRecommandUserCollectionViewCell: UICollectionViewCell {
    
    @objc var changeBlock:(() -> Void)?
    
    @objc lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "为你推荐"
        
        return label
    }()
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.layer.cornerRadius = 4
        view.layer.shadowColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 24
        
        return view
    }()
    
    lazy var tableview:UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.backgroundColor = .clear
        table.register(YXUGCRecommandUserTableViewCell.self, forCellReuseIdentifier: "YXUGCRecommandUserTableViewCell")
        
        return table
    }()
    
    lazy var refreshButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle("换一批", for: .normal)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setImage(UIImage(named: "ugc_Refresh_icon"), for: .normal)
        button.spacingBetweenImageAndTitle = 4
    
        button.qmui_tapBlock = { [weak self] (_) in
            guard let `self` = self else { return }
            self.rotationEnded = false
            self.changeBlock?()
            self.buttonRotation()
        }
        
        return button
    }()
    
    @objc var rotationEnded = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(bgView)
        bgView.addSubview(tableview)
        bgView.addSubview(refreshButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.bottom.equalToSuperview()
        }
        tableview.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-66)
            
        }
        
        refreshButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
            
        }
        
    }
    
    var model:YXUGCRecommandUserListModel? {
        didSet {
            self.tableview.reloadData()
        }
    }
  
    
    func buttonRotation() {
        refreshButton.isUserInteractionEnabled = false
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.duration = 0.4
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = 1
        rotationAnimation.delegate = self
        refreshButton.imageView?.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    lazy var isWhiteStyle:Bool = false {
        didSet {
            updateWhiteStyleUI()
        }
    }
    private func updateWhiteStyleUI() {
        titleLabel.textColor = QMUITheme().textColorLevel1()
        bgView.backgroundColor = QMUITheme().foregroundColor()
        bgView.layer.shadowColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05).cgColor
        contentView.backgroundColor = QMUITheme().foregroundColor()
        backgroundColor = QMUITheme().foregroundColor()
    }
    
}

extension YXUGCRecommandUserCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model?.list.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableview.dequeueReusableCell(withIdentifier: "YXUGCRecommandUserTableViewCell", for: indexPath) as! YXUGCRecommandUserTableViewCell
        if let modelData = model {
            let item:YXUGCRecommandUserModel = modelData.list[indexPath.row]
//            cell.model = item
          
        }
        rotationEnded = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if model != nil  {
            return 62
        }
        return CGFloat.leastNormalMagnitude
    }
}

extension YXUGCRecommandUserCollectionViewCell: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if rotationEnded {
            refreshButton.isUserInteractionEnabled = true
        } else {
            buttonRotation()
        }
    }
}
