//
//  BreadCells.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

///mianbaoxie间隔cell
class BreadIntevalCell:UICollectionViewCell{
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        let imgView = UIImageView()
        imgView.convertUIWithARLanguage()
        imgView.image = UIImage(named: "bread_interval")
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.center.equalTo(contentView.snp.center)
        }
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class BreadItemCell:UICollectionViewCell{
    
    weak var contentLbl:UILabel?
    weak var bottomLine:UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        let contentLbl = UILabel()
        contentLbl.font = UIFont.boldSystemFont(ofSize: 14)
        contentLbl.textAlignment = .center
        contentView.addSubview(contentLbl)
        contentLbl.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        self.contentLbl = contentLbl
        
        let line = UIView()
        contentView.addSubview(line)
        bottomLine = line
        line.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(5)
            make.trailing.equalTo(contentView).offset(-5)
            make.height.equalTo(1)
            make.bottom.equalTo(contentView).offset(-10)
        }
        line.backgroundColor = OSSVThemesColors.col_0D0D0D()
        line.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var isSelected: Bool{
        didSet{
            bottomLine?.isHidden = !isSelected
            contentLbl?.textColor = isSelected ? OSSVThemesColors.col_0D0D0D() : OSSVThemesColors.col_B2B2B2()
        }
    }
    
    override func prepareForReuse() {
        bottomLine?.isHidden = true
        contentLbl?.textColor = OSSVThemesColors.col_B2B2B2()
        isSelected = false
    }
}
