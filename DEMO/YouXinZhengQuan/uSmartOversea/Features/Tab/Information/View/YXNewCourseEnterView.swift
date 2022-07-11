//
//  YXNewCourseEnterView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/7/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit


class YXNewCourseEnterBtn: UIButton {
    
    var model: YXNewCourseEnterModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {

        self.imageView?.layer.cornerRadius = 20
        self.imageView?.clipsToBounds = true
        self.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.titleLabel?.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRect.init(x: (self.mj_w - 40) * 0.5, y: 20, width: 40, height: 40)
        self.titleLabel?.frame = CGRect.init(x: 0, y: (self.imageView?.mj_y ?? 0) + 40 + 5, width: self.mj_w, height: 20)
    }
}

class YXNewCourseEnterView: UIView {

    let stackView = UIStackView.init()
    
    @objc var callBack: ((_ model: YXNewCourseEnterModel?) -> ())?
    
    @objc var list: [YXNewCourseEnterModel]? {
        
        didSet {
            if let list = self.list {
                self.stackView.removeAllSubviews()
                
                for model in list {
                    let btn = YXNewCourseEnterBtn.init()
                    btn.setTitle(model.title.show, for: .normal)
                    btn.sd_setImage(with: URL.init(string: model.icon), for: .normal, completed: nil)
                    self.stackView.addArrangedSubview(btn)
                    btn.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
                    btn.tag = model.tag
                    btn.model = model
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    @objc func click(_ sender: YXNewCourseEnterBtn) {
        self.callBack?(sender.model)
    }
    
}
