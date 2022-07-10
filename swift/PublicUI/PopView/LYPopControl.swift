//
//  LYPopControl.swift
//  LYProductModel
//
//  Created by MountainZhu on 2020/11/13.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

class LYPopControl: UIControl {

    init(frame: CGRect, imageName:String, title:String, hiddenLine:Bool) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.init(hex: 0x4C4C4C)
        
        let w = frame.size.width
        let h = frame.size.height
        let imageView_x:CGFloat = 8.0
        let imageView_y:CGFloat = 4.0
        let imageView_h = h - 2*imageView_y
        let imageView_w = imageName == "" ? 0 : imageView_h
        var imageView_rect = CGRect.init()
        imageView_rect.origin.x = imageView_x
        imageView_rect.origin.y = imageView_y
        imageView_rect.size.width = imageView_w
        imageView_rect.size.height = imageView_h
        
        let imageView = UIImageView.init(frame: imageView_rect)
        imageView.image = UIImage.init(named: imageName)
        self.addSubview(imageView)
        
        let label_x = imageView.frame.maxX - (imageName == "" ? 8 : -8)
        let label_y = imageView_y
        let label_h = imageView_h
        let label_w = w-label_x
        var label_rect = CGRect.init()
        label_rect.origin.x = label_x
        label_rect.origin.y = label_y
        label_rect.size.width = label_w
        label_rect.size.height = label_h
        
        let titleLabel = UILabel.init(frame: label_rect)
        titleLabel.text = title
        titleLabel.textColor = UIColor.white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: .scaleW(16))
        self.addSubview(titleLabel)
        
        let line_x = imageView_x
        let line_y = h - 1.0
        let line_w = w - 2*line_x
        let line_h:CGFloat = 1.0
        var line_rect = CGRect.init()
        line_rect.origin.x = line_x
        line_rect.origin.y = line_y
        line_rect.size.width = line_w
        line_rect.size.height = line_h
        let lineLable = UILabel.init(frame: line_rect)
        lineLable.backgroundColor = UIColor.gray
        lineLable.isHidden = hiddenLine
        self.addSubview(lineLable)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
