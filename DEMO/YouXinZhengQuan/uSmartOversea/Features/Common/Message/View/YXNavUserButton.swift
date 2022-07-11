//
//  YXNavUserButton.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/7/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXNavUserButton: UIButton {

    @objc static let shared = YXNavUserButton(frame: .zero)
    
    typealias ClosureClick = () -> Void
    
    @objc var onClickMessage: ClosureClick?
    
    @objc var icon = UIImageView.init(image: UIImage(named: "user_icon_list"))

    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView?.layer.cornerRadius = 15;
        self.imageView?.clipsToBounds = true
        self.imageView?.contentMode = .center;
        self.setImage(UIImage(named: "nav_user"), for:.normal)
        self.addTarget(self, action: #selector(userButtonAction), for: .touchUpInside)
        self.imageView?.contentMode = .scaleAspectFit
        
        self.imageView?.layer.borderColor = UIColor.qmui_color(withHexString: "#D1D1D1")?.cgColor
        self.imageView?.layer.borderWidth = 1.0
        
        if let imageV = self.imageView {
            addSubview(icon)
            icon.snp.makeConstraints { (make) in
                make.right.bottom.equalTo(imageV)
            }
        }
    }
    
    @objc func refreshUI() {
        
        if let av = YXUserManager.shared().curLoginUser?.avatar {
            self.sd_setImage(with: URL.init(string: av), for: .normal, placeholderImage: UIImage(named: "nav_user"), options: [], completed: nil)
        } else {
            self.setImage(UIImage(named: "nav_user"), for: .normal)
        }
    }
    
    @objc func userButtonAction() {
     
        if let closure = onClickMessage {
            closure()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRect.init(x: 0, y: (self.frame.size.height - 30) * 0.5, width: 30, height: 30)
    }
    
    override func willDealloc() -> Bool {
        return false
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
