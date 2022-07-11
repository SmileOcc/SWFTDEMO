//
//  YXCollectViewCell.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

let COLLECT_CELL_IMAGE_VIEW_WIDTH: CGFloat = 124
let COLLECT_CELL_IMAGE_VIEW_HEIGHT: CGFloat = 92

class YXCollectViewCell: QMUITableViewCell {

    var isEditor = false
    var model: CollectionList?
    
    var titleLab: QMUILabel = {
        let lab = QMUILabel()
        lab.font = UIFont.systemFont(ofSize: 16)
        lab.textColor = QMUITheme().textColorLevel1()
        lab.numberOfLines = 3
        return lab
    }()
    
    var sourceLab: QMUILabel = {
        let lab = QMUILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = QMUITheme().textColorLevel2()
        return lab
    }()
    
    var dateLab: QMUILabel = {
        let lab = QMUILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = QMUITheme().textColorLevel2()
        return lab
    }()
    
    var newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var backView: UIView = {
        let backView = UIView()
        backView.backgroundColor = UIColor.clear
        backView.layer.borderColor = QMUITheme().separatorLineColor().cgColor
        backView.layer.borderWidth = 1
        backView.layer.cornerRadius = 4
        return backView
    }()
    
    var selectBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setBackgroundImage(UIImage(named: "settings_nochoose"), for: .normal)
        btn.setBackgroundImage(UIImage(named: "settings_choose"), for: .selected)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialUI() {
        backgroundColor = UIColor.white
        selectionStyle = .none
        
        contentView.addSubview(backView)
        contentView.addSubview(selectBtn)
        backView.addSubview(titleLab)
        backView.addSubview(sourceLab)
        backView.addSubview(dateLab)
        backView.addSubview(newsImageView)
        
        backView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
            make.top.equalTo(self).offset(14)
            make.height.equalTo(120)
        }
        
        selectBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(12)
            make.centerY.equalTo(backView)
            make.width.height.equalTo(16)
        }
        
        sourceLab.snp.makeConstraints { (make) in
            make.left.equalTo(backView).offset(14)
            make.bottom.equalTo(backView).offset(-12)
        }
        
        dateLab.snp.makeConstraints { (make) in
            make.left.equalTo(sourceLab.snp.right).offset(8)
            make.centerY.equalTo(sourceLab)
        }
        
        newsImageView.snp.makeConstraints { (make) in
            make.top.equalTo(backView).offset(14)
            make.right.equalTo(backView).offset(0) // -15
            make.width.equalTo(0) // COLLECT_CELL_IMAGE_VIEW_WIDTH
            make.height.equalTo(COLLECT_CELL_IMAGE_VIEW_HEIGHT)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.left.top.equalTo(backView).offset(14)
            make.right.equalTo(newsImageView.snp.left).offset(-8)
        }
    }
    
    func refreshUI() {
        
        if let model = model {
            titleLab.text = model.title
            if model.source.count > 8 {
                sourceLab.text = String(format: "%@...", model.source.subString(toCharacterIndex: 8))
            }else {
                sourceLab.text = model.source
            }
            dateLab.text = NSDate.dateString(withTimeIntervalSince1970: model.releaseTime)
            
            if !(model.pictureURL?.isEmpty ?? true) {//model.pictureURL?.count ?? 0 > 0
                if let url = URL(string: model.pictureURL?[0] ?? "") {
                    let transformer = SDImageResizingTransformer(size: CGSize(width: COLLECT_CELL_IMAGE_VIEW_WIDTH * UIScreen.main.scale, height: COLLECT_CELL_IMAGE_VIEW_HEIGHT * UIScreen.main.scale), scaleMode: .aspectFill)
                    newsImageView.sd_setImage(with: url, placeholderImage: nil, options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
                }
                newsImageView.snp.updateConstraints { (make) in
                    make.right.equalTo(backView).offset(-15)
                    make.width.equalTo(COLLECT_CELL_IMAGE_VIEW_WIDTH)
                }
            } else {
                newsImageView.snp.updateConstraints { (make) in
                    make.right.equalTo(backView).offset(0)
                    make.width.equalTo(0)
                }
            }
            
            if isEditor {
                backView.snp.updateConstraints { (make) in
                    make.left.equalTo(self).offset(40)
                }
            }else {
                backView.snp.updateConstraints { (make) in
                    make.left.equalTo(self).offset(10)
                }
            }
            selectBtn.isHidden = !isEditor
            
            selectBtn.isSelected = model.isSelected ?? false
            if model.isSelected ?? false {
                backView.layer.borderColor = QMUITheme().themeTextColor().cgColor
            }else {
                backView.layer.borderColor = QMUITheme().separatorLineColor().cgColor
            }
        }
    }
}
