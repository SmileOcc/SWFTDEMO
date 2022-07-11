//
//  YXRecommendChatCell.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/30.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class YXRecommendChatCell: UITableViewCell {
    
    var dataSource: [YXRecommendChatResModel]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 104, height: 115)
        
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.contentInset = UIEdgeInsets(top: 10, left: 16, bottom: 15, right: 16)
        collection.register(YXRecommendChatKOLCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXRecommendChatKOLCell.self))
        return collection
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(collectionView)
        
        backgroundColor = .clear
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
}

extension YXRecommendChatCell: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXRecommendChatKOLCell.self), for: indexPath) as! YXRecommendChatKOLCell
        if let model = dataSource?[indexPath.row] {
            cell.kolNameLabel.text = model.chatGroupName
            if let url = URL(string: model.chatGroupUrl ?? "") {
                cell.kolImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "user_default_photo"))
            } else {
                cell.kolImageView.image = UIImage(named: "user_default_photo")
            }
            
            cell.tipsLable.isHidden = !(model.userStatus == 0 || model.userStatus == 4)
            cell.badgeView.isHidden = !model.isSpot
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        YXToolUtility.handleBusinessWithLogin {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.chatRoom(chatRoomId: self.dataSource?[indexPath.row].chatGroupId ?? "")]
            NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
    }
}
