//
//  TabView.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/14.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TabView: UIView {
    
    let disposeBag = DisposeBag()
    
    lazy var indexPub:PublishSubject<Int> = {
        let pub = PublishSubject<Int>()
        return pub
    }()
    
    var defaultIndex = 0
    
    
    var titles:[String]?{
        didSet{
            if let titles = titles {
                stackView.arrangedSubviews.forEach { view in
                    view.removeFromSuperview()
                }
                for (index,title) in titles.enumerated() {
                    let item = TabItem(frame: .zero)
                    item.isSelected = index == defaultIndex
                    item.index = index
                    item.titleLbl.text = title
                    stackView.addArrangedSubview(item)
                    item.addTarget(self, action: #selector(didSelectItem(_:)), for: .touchUpInside)
                }
            }
        }
    }
    
    weak var stackView:UIStackView!

    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        addSubview(stackView)
        self.stackView = stackView
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        }
    }
    
    @objc func didSelectItem(_ item:TabItem){
        for view in stackView.arrangedSubviews {
            if let otherTab = view as? TabItem {
                otherTab.isSelected = false
            }
        }
        item.isSelected = true
        indexPub.onNext(item.index)
    }

}

class TabItem : UIControl{

    override var isSelected: Bool{
        didSet{
            self.titleLbl.textColor = isSelected ? OSSVThemesColors.col_000000(1) : OSSVThemesColors.col_000000(0.7)
            self.underLine.isHidden = !isSelected
        }
    }
    
    weak var titleLbl:UILabel!
    weak var underLine:UIView!
    
    var index = -1
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        let titleLbl = UILabel()
        titleLbl.font = UIFont.boldSystemFont(ofSize: 14)
        self.titleLbl = titleLbl
        addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(17)
        }
        
        let underLineView = UIView()
        addSubview(underLineView)
        self.underLine = underLineView
        underLineView.backgroundColor = OSSVThemesColors.col_000000(1)
        underLineView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLbl)
            make.top.equalTo(titleLbl.snp.bottom)
            make.height.equalTo(2)
            make.bottom.equalTo(-5)
        }
    }

}
