//
//  IndexTabHeaderView.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/13.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift

class OSSVIndexTabHeaderView: UICollectionReusableView {
    
    weak var menuView:WMMenuView?
    
    let indexChangedPub = PublishSubject<Int>()
    
    var currentIndex:Int?{
        didSet{
            if let current = currentIndex{
                menuView?.justSelect(current)
            }
        }
    }
    
    
    var titleArrs:[String]?{
        didSet{
            menuView?.reload()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupSubViews() {
        let menuView = WMMenuView(frame: CGRect(x: 0, y: 0, width: CGFloat.screenWidth, height: 44))
        addSubview(menuView)
        menuView.dataSource = self
        menuView.delegate = self
        self.menuView = menuView
        menuView.style = .line
        menuView.speedFactor = 10
        menuView.progressViewCornerRadius = 10
        menuView.contentMargin = 0
        menuView.fontName = "Almarai-ExtraBold";
        menuView.lineColor = OSSVThemesColors.col_0D0D0D()
        menuView.progressHeight = 2
        menuView.progressViewBottomSpace = 10
        
       
    }
}

extension OSSVIndexTabHeaderView:WMMenuViewDelegate,WMMenuViewDataSource{
    func numbersOfTitles(in menu: WMMenuView!) -> Int {
        titleArrs?.count ?? 0
    }
    
    func menuView(_ menu: WMMenuView!, titleAt index: Int) -> String! {
        titleArrs?[index] ?? ""
    }
    
    func menuView(_ menu: WMMenuView!, titleColorFor state: WMMenuItemState, at index: Int) -> UIColor! {
        if state == .selected{
            return OSSVThemesColors.col_0D0D0D()
        }
        return OSSVThemesColors.col_999999()
    }
    
    func menuView(_ menu: WMMenuView!, titleSizeFor state: WMMenuItemState, at index: Int) -> CGFloat {
        13
    }
    
    func menuView(_ menu: WMMenuView!, widthForItemAt index: Int) -> CGFloat {
        let tempLbl = UILabel()
        tempLbl.text = titleArrs?[index]
        tempLbl.font = UIFont(name: menu.fontName, size: 13)
        let size = tempLbl.sizeThatFits(CGSize(width: CGFloat.infinity, height: 20))
        return size.width
    }
    
    func menuView(_ menu: WMMenuView!, didSelectedIndex index: Int, currentIndex: Int) {
        indexChangedPub.onNext(index)
        print(index)
    }
    
}




extension String{
    static let indexHeaderReuseId = "IndexTabHeaderView"
}



