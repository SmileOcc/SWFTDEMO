//
//  YXFoldLabel.swift
//  uSmartEducation
//
//  Created by usmart on 2022/2/22.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import UIKit

class YXFoldLabel: UIView {
    
    var fold: Bool = false {
        didSet {
            configScrollView()
        }
    }
    
    @objc dynamic var canFold: Bool = false
    
    var text: String? {
        didSet {
            self.label.text = text
            configScrollView()
        }
    }
    
    lazy private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.contentSize = CGSize.zero
        return scrollView
    }()
    
    lazy var label: QMUILabel = {
        let label = QMUILabel()
        label.numberOfLines = 2
        label.font = .normalFont14()
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupUI() {
        
        addSubview(scrollView)
        scrollView.addSubview(label)
        
        backgroundColor = .clear
        
        snp.makeConstraints { make in
            make.height.equalTo(0)
        }
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
                
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    private func configScrollView() {
        var size = CGSize.zero
        self.label.numberOfLines = 0
        size = self.label.systemLayoutSizeFitting(CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        canFold = size.height > 40
        if fold {
            self.label.numberOfLines = 0
            size = self.label.systemLayoutSizeFitting(CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        } else {
            self.label.numberOfLines = 2
            size = self.label.systemLayoutSizeFitting(CGSize(width: self.frame.size.width, height: 42))
        }
        self.snp.updateConstraints { make in
            make.height.equalTo(size.height > 200 ? 200 : size.height)
        }
        self.scrollView.contentSize = size

    }
    
    override func layoutSubviews() {
        configScrollView()
    }
    
}
