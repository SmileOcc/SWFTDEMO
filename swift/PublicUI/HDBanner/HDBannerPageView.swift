//
//  HDBannerPageView.swift
//  HDPublicUIProject
//
//  Created by 航电 on 2020/8/26.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

class HDBannerPageView: UIView {

    public var allPageCount:NSInteger = 0;
    public var selectPageIndex:NSInteger = 0;
    public var selectView:UIView?
    
    public init(frame: CGRect,pageCount:NSInteger) {
        super.init(frame: frame);
        
        allPageCount = pageCount;
        
        onCreateUIForView();
    }

    required init?(coder: NSCoder) {
        fatalError("HDBannerPageView Load Error !!");
    }
    
    private func onCreateUIForView() {
        
        let itemWidth = self.width / CGFloat(allPageCount);
        for i in 0 ..< allPageCount {
            let circleView = onCreateCircle(frame: CGRect(x: (itemWidth - .scaleW(5.0))/2.0 + itemWidth * CGFloat(i), y: (self.height - .scaleW(5.0))/2.0, width: .scaleW(5.0), height: .scaleW(5.0)),color: .LightGrayTitle()) ;
            self.addSubview(circleView);
        }
        
        selectView = onCreateCircle(frame: CGRect(x: 0, y: (self.height - .scaleW(5.0))/2.0, width: itemWidth, height: .scaleW(5.0)),color: .white) ;
        self.addSubview(selectView!);
    }
    
    private func onCreateCircle(frame:CGRect,color:UIColor) -> UIView {
        let circleView = UIView(frame: frame);
        circleView.backgroundColor = color;
        circleView.layer.cornerRadius = frame.height / 2.0;
        circleView.layer.masksToBounds = true;
        return circleView;
    }
    
    public func onSelectPageFromBanner(selectIndex:NSInteger) {
        if allPageCount > selectIndex {
            selectPageIndex = selectIndex;
            UIView.animate(withDuration: 0.15) {
                self.selectView!.left = self.selectView!.width * CGFloat(selectIndex);
            };
        }
    }
}
