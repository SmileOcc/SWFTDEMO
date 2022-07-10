//
//  HDTaskLoadTipView.swift
//  HDPublicUIProject
//
//  Created by 航电 on 2020/9/22.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

public class HDTaskLoadTipView: UIView {

    private var selectWindow:UIWindow?
    private var bgView:UIView?
    private var titleLb:UILabel?
    private var contentLb:UILabel?
    private var contentView:UIView?
    
    private var contentShapeLayer:CAShapeLayer?
    private var contentBeizerPath:UIBezierPath?
    
    private var currentDownIndex:Int = 0;
    private var allDownIndex:Int = 0;
    
    public override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.onCreateUIForView();
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func onCreateUIForView() {
        let screenSize = UIScreen.main.bounds.size;
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height);
        self.backgroundColor = .clear;
        
        if self.bgView == nil {
            
            self.bgView = UIView(frame: CGRect(x: (screenSize.width - 120)/2.0, y: (screenSize.height - 120)/2.0, width: 120, height: 120))
            self.bgView?.backgroundColor = .BlackTitle();
            self.addSubview(self.bgView!);
            self.bgView?.layer.cornerRadius = 5.0;
            self.bgView?.layer.masksToBounds = true;
            
            self.titleLb = UILabel(frame: CGRect(x: 0, y: 5, width: self.bgView!.width, height: 20));
            self.titleLb?.backgroundColor = .clear;
            self.titleLb?.textColor = .WhiteToBlack();
            self.titleLb?.text = "领取"
            self.titleLb?.textAlignment = .center;
            self.titleLb?.font = UIFont.systemFont(ofSize: 16, weight: .regular);
            self.titleLb?.isHidden = true;
            self.bgView?.addSubview(self.titleLb!);
            
            self.contentLb = UILabel(frame: CGRect(x: 0, y: self.bgView!.height - 20 - 5, width: self.bgView!.width, height: 20));
            self.contentLb?.backgroundColor = .clear;
            self.contentLb?.textColor = .WhiteToBlack();
            self.contentLb?.textAlignment = .center;
            self.contentLb?.font = UIFont.systemFont(ofSize: 16, weight: .regular);
            self.contentLb?.text = "进度 1/20"
            self.bgView?.addSubview(self.contentLb!);
            
            let contentHeight = self.contentLb!.top - 30;
            self.contentView = UIView(frame: CGRect(x: (self.bgView!.width - contentHeight)/2.0, y: 20, width: contentHeight, height: contentHeight))
            self.contentView?.backgroundColor = .BlackTitle();
            self.bgView?.addSubview(self.contentView!);
            
            //
            let bgShapeLayer = CAShapeLayer();
            bgShapeLayer.frame = self.contentView!.bounds;
            self.contentView?.layer.addSublayer(bgShapeLayer);
            
            let bgBeizerPath = UIBezierPath(arcCenter: CGPoint(x: contentHeight/2.0, y: contentHeight/2.0), radius: contentHeight/2.0, startAngle: 0, endAngle: .pi * 2.0, clockwise: true);
            bgShapeLayer.path = bgBeizerPath.cgPath;
            bgShapeLayer.fillColor = UIColor.BlackTitle().cgColor;
            bgShapeLayer.strokeColor = UIColor.LightGrayTitle().cgColor;
            bgShapeLayer.lineWidth = 3;
            
            //
            contentShapeLayer = CAShapeLayer();
            contentShapeLayer?.frame = self.contentView!.bounds;
            self.contentView?.layer.addSublayer(contentShapeLayer!);
            
            contentBeizerPath = UIBezierPath(arcCenter: CGPoint(x: contentHeight/2.0, y: contentHeight/2.0), radius: contentHeight/2.0, startAngle: -.pi * 0.5, endAngle: -.pi * 0.5, clockwise: true);
            contentShapeLayer?.path = contentBeizerPath!.cgPath;
            contentShapeLayer?.fillColor = UIColor.BlackTitle().cgColor;
            contentShapeLayer?.strokeColor = UIColor.TabbarTitleSelect().cgColor;
            contentShapeLayer?.lineWidth = 3;
        }
    }
    
    public func onChangeUIForData(_ currentIndex: Int,_ allCount: Int) {
        
        if self.currentDownIndex > currentIndex {
            return;
        }
        
        self.currentDownIndex = currentIndex;
        self.allDownIndex = allCount;
        
        self.contentLb?.text = "进度 "+"\(currentIndex)"+"/"+"\(allCount)"
        
        let endAngle = CGFloat(currentIndex) * .pi * 2.0 / CGFloat(allCount) - .pi * 0.5;
        
        UIView.animate(withDuration: 0.35) {
            self.contentBeizerPath = UIBezierPath(arcCenter: CGPoint(x: self.contentView!.width/2.0, y: self.contentView!.width/2.0), radius: self.contentView!.width/2.0, startAngle: -.pi * 0.5, endAngle: endAngle, clockwise: true);
            self.contentShapeLayer?.path = self.contentBeizerPath!.cgPath;
        };
    }
    
    //MARK: >>>>> 声明公共方法
    //TODO: 显示窗口
    public func onShowInWindow() {
        if self.selectWindow == nil {
            let frame = UIApplication.shared.keyWindow?.frame;
            self.selectWindow = UIWindow(frame: frame!);
            self.selectWindow?.backgroundColor = UIColor.black.withAlphaComponent(0.55);
            self.selectWindow?.windowLevel = .alert;
            self.selectWindow?.becomeKey();
        }
        self.selectWindow?.makeKeyAndVisible();
        self.selectWindow?.isHidden = false;
        
        self.frame = self.selectWindow!.bounds;
        self.selectWindow?.addSubview(self);
    }
    
    //TODO: 隐藏窗口
    public func onHideInWindow() {
        if self.selectWindow != nil {
            self.selectWindow?.resignKey();
            self.selectWindow?.isHidden = true;
        }
    }

}
