//
//  SizeCodeCell.swift
//  Adorawe
//
//  Created by fan wang on 2021/10/29.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import YYImage

class SizeCodeCell: UICollectionViewCell {
    private weak var codeLbl:UILabel!
    private weak var underLine:UIView!
    
    var data:SizeMappingItem?{
        didSet{
            if let code = data?.code {
                let attrString = NSMutableAttributedString(string: code)
                var font = UIFont.systemFont(ofSize: 14)
                var fontColor = OSSVThemesColors.col_000000(0.5)
                
                var needUnderLine = true
                if let savedCode = STLPreference.object(forKey: STLPreference.keySelectedSizeCode) as? String{
                    if savedCode == code{
                        font = UIFont.boldSystemFont(ofSize: 14)
                        fontColor = OSSVThemesColors.col_000000(1.0)
                        needUnderLine = false
                    }
                }else {
                    if(data?.is_default == true){
                        font = UIFont.boldSystemFont(ofSize: 14)
                        fontColor = OSSVThemesColors.col_000000(1.0)
                        needUnderLine = false
                    }
                }
                
                attrString.yy_font = font
                attrString.yy_color = fontColor
                
//                if needUnderLine{
//                    attrString.yy_underlineStyle = NSUnderlineStyle(rawValue: (0x01 | 0x0100))
//                    attrString.yy_underlineColor = OSSVThemesColors.col_000000(0.5)
//                }
                underLine.isHidden = !needUnderLine
                
                codeLbl.attributedText = attrString
            }
            
            
        }
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
       
        let lbl = UILabel()
        contentView.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        self.codeLbl = lbl
        
        let underLine = UIView()
        underLine.backgroundColor = UIColor(patternImage: UIImage(named: "spic_dash_line_black")!)
        contentView.addSubview(underLine)
        underLine.snp.makeConstraints { make in
            make.leading.equalTo(lbl.snp.leading)
            make.trailing.equalTo(lbl.snp.trailing)
            make.height.equalTo(1)
            make.top.equalTo(lbl.snp.bottom).offset(-7)
        }
        self.underLine = underLine
    }
    
    
}
