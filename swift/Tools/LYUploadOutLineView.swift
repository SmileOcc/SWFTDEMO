//
//  LYUploadOutLineView.swift
//  LYProductModel
//
//  Created by 航电 on 2020/12/1.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

class LYUploadOutLineView: UIView {

    public var selectBlock:(() -> Void)?
    
    private var titleName: NSString?
    
    private var bgView:UIView?
    private var selectWindow:UIWindow?
    
    //MARK: *** START *****
    public init(frame: CGRect,title:NSString) {
        super.init(frame: frame);
        
        self.titleName = title;
        
        self.onCreaeUIForContent();
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: ***** UI ******
    private func onCreaeUIForContent() {
        
        self.bgView = self.onCreateUIForView(frame: CGRect(x: .scaleW(37.5), y: (HDConst.SCREENH - .scaleW(170)) / 2.0, width: HDConst.SCREENW - .scaleW(37.5) * 2, height: .scaleW(170)), bgColor: .WhiteToBlack());
        self.addSubview(self.bgView!);
        self.bgView?.layer.cornerRadius = 10
        self.bgView?.layer.masksToBounds = true
        
        //头部
        let titleLb = self.onCreateUIForLabel(frame: CGRect(x: .scaleW(30.0), y: .scaleW(50), width: self.bgView!.width - .scaleW(30.0) * 2.0, height: .scaleW(45)), title: self.titleName! as String, font: UIFont.systemFont(ofSize: .scaleW(17.0), weight: .medium), align: .left, textColor: .DarkGrayTitle());
        titleLb.backgroundColor = .clear;
        titleLb.numberOfLines = 0;
        self.bgView?.addSubview(titleLb);
        titleLb.height = self.onGetTitleHeight(titleLb.text!);
        
        var allHeight:CGFloat = titleLb.bottom;
        let titleArray = ["暂不上传","立即上传"];
        let itemMarg:CGFloat = .scaleW(10) * CGFloat((titleArray.count - 1));
        let itemWidth:CGFloat = (self.bgView!.width - .scaleW(15) * 2.0 - itemMarg) / CGFloat(titleArray.count);
        for i in 0 ..< titleArray.count {
            let bt = UIButton(type: .custom);
            bt.frame = CGRect(x: .scaleW(15) + (itemWidth + .scaleW(10)) * CGFloat(i), y: titleLb.bottom + .scaleW(25), width: itemWidth, height: .scaleW(45));
            bt.backgroundColor = .clear;
            bt.setTitle(titleArray[i], for: .normal);
            bt.setTitleColor(.DarkGrayTitle(), for: .normal);
            bt.titleLabel?.font = UIFont.systemFont(ofSize: .scaleW(16.0), weight: .regular);
            bt.tag = 4100 + i;
            bt.addTarget(self, action: #selector(onCancelOrSureAction(_:)), for: .touchUpInside);
            self.bgView?.addSubview(bt);
            bt.layer.cornerRadius = 5.0;
            bt.layer.borderColor = UIColor.BlueTextColor().cgColor;
            bt.layer.borderWidth = 1.0;
            bt.layer.masksToBounds = true;
            
            if i == 0 {
                bt.backgroundColor = .WhiteToBlack();
                bt.setTitleColor(.BlueTextColor(), for: .normal);
            }
            else if i == 1 {
                bt.backgroundColor = .BlueTextColor();
                bt.setTitleColor(.WhiteToBlack(), for: .normal);
            }
            
            allHeight = bt.bottom + .scaleW(15);
        }
        
        self.bgView?.height = allHeight;
        self.bgView?.top = (HDConst.SCREENH - allHeight) / 2.0;
    }

    //MARK: ***** Actions *****
    //TODO: 自动生成label
    private func onCreateUIForLabel(frame:CGRect,title:String,font:UIFont,align:NSTextAlignment,textColor:UIColor) -> UILabel {
        let lb = UILabel(frame: frame);
        lb.text = title;
        lb.font = font;
        lb.textAlignment = align;
        lb.textColor = textColor;
        lb.backgroundColor = .clear
        return lb;
    }
    
    //TODO: 自动生成view
    private func onCreateUIForView(frame:CGRect,bgColor:UIColor) -> UIView {
        let view = UIView(frame: frame);
        view.backgroundColor = bgColor;
        return view;
    }
    
    //TODO: 根据内容获取高度
    private func onGetTitleHeight(_ title:String) -> CGFloat {
    
        let itemWidth = HDConst.SCREENW - .scaleW(37.5) * 2 - .scaleW(30) * 2;
        var checkHeight = title.boundingRect(with: CGSize(width: itemWidth, height: 1000), options: .usesLineFragmentOrigin, attributes: [.font : UIFont.systemFont(ofSize: .scaleW(17.0), weight: .medium)], context: nil).size.height;
        if checkHeight < .scaleW(20) {
            checkHeight = .scaleW(20.0);
        }
        return checkHeight;
    }
    
    //TODO: 取消或确定
    @objc private func onCancelOrSureAction(_ bt: UIButton) {
        let tagIndex = bt.tag - 4100;
        if tagIndex == 0 {
            //暂不上传
            self.onHideInWindow();
        } else {
            if self.selectBlock != nil {
                self.selectBlock!();
                
                self.onHideInWindow();
            }
        }
    }
    
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
        
        let allHeight:CGFloat = (HDConst.SCREENH - self.bgView!.height) / 2.0;
 
        self.bgView?.top = HDConst.SCREENH;
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: { [unowned self] in
            self.bgView?.top = allHeight;
        }, completion: { _ in
            
        })
    }
    
    //TODO: 选中确定回调
    public func onSelectBack(block:@escaping () -> Void) {
        self.selectBlock = block;
    }
    
    //TODO: 隐藏窗口
    public func onHideInWindow() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView?.top = HDConst.SCREENH;
        }, completion: {[unowned self] (finished:Bool)in
            self.removeFromSuperview()
            
            if self.selectWindow != nil {
                self.selectWindow?.resignKey();
                self.selectWindow?.isHidden = true;
            }
        })
    }
}
