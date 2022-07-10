//
//  HDAddPictureView.swift
//  HDPublicUIProject
//
//  Created by 航电 on 2020/8/31.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

public protocol HDAddPictureViewDelegate: NSObjectProtocol {
    func onAddPictureFromHDAddPictureView(_ view:HDAddPictureView);
    func onDeltePictureFromHDAddPictureView(_ view:HDAddPictureView);
}

public class HDAddPictureView: UIView {

    public var selectImgView:UIImageView?
    public weak var cellDelegate:HDAddPictureViewDelegate?
    private var tipImgView: UIImageView?
    private var selectImgBt:UIButton?
    
    public override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.onCreateUIForView();
    }
    
    required init?(coder: NSCoder) {
        fatalError("HDAddPictureView Load Error!")
    }
    
    //MARK: ***** UI ******
    private func onCreateUIForView() {
        self.isUserInteractionEnabled = true;
       
//        self.layer.cornerRadius = 5.0;
//        self.layer.borderWidth = 1.0;
//        self.layer.borderColor = UIColor.lineColor().cgColor;
//        self.layer.masksToBounds = true;
        
        let tipImg = UIImage(named: "WO_Order_Add_Pictiure");
        self.tipImgView = UIImageView(frame: CGRect(x: 0, y: .scaleW(9), width: self.width - .scaleW(10), height: self.height - .scaleW(9)));
        self.tipImgView?.backgroundColor = .clear;
        self.tipImgView?.image = tipImg;
        self.tipImgView?.contentMode = .scaleAspectFit;
        self.tipImgView?.isUserInteractionEnabled = true;
        self.addSubview(self.tipImgView!);
        self.tipImgView?.layer.cornerRadius = 5.0;
        self.tipImgView?.layer.borderWidth = 1.0;
        self.tipImgView?.layer.borderColor = UIColor.lineColor().cgColor;
        self.tipImgView?.layer.masksToBounds = true;
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(onTapGestureForImgView))
        self.tipImgView?.addGestureRecognizer(tapGest);
        
        //******************
        self.selectImgView = UIImageView(frame: self.tipImgView!.frame);
        self.selectImgView?.backgroundColor = .clear;
        self.selectImgView?.contentMode = .scaleAspectFill;
        self.selectImgView?.isHidden = true;
        self.selectImgView?.isUserInteractionEnabled = true;
        self.addSubview(self.selectImgView!);
        self.selectImgView?.layer.cornerRadius = 5.0;
        self.selectImgView?.layer.borderWidth = 1.0;
        self.selectImgView?.layer.borderColor = UIColor.lineColor().cgColor;
        self.selectImgView?.layer.masksToBounds = true;
        
        let deleteImg = UIImage(named: "取消");
        let bt = UIButton(frame: CGRect(x: self.selectImgView!.right - deleteImg!.size.width / 2.0, y: self.selectImgView!.top - deleteImg!.size.height / 2.0, width: deleteImg!.size.width, height: deleteImg!.size.height));
        bt.backgroundColor = .clear;
        bt.isHidden = true;
        bt.setImage(deleteImg, for: .normal);
        bt.addTarget(self, action: #selector(onDeleteForImgView), for: .touchUpInside);
        self.addSubview(bt);
        selectImgBt = bt;
        
//        let deleteGest = UILongPressGestureRecognizer(target: self, action: #selector(onLongGestureForImgView(_:)))
//        deleteGest.minimumPressDuration = 2.5;
//        self.selectImgView?.addGestureRecognizer(deleteGest);
    }
    
    override public func layoutSubviews() {
//        self.tipImgView?.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
//        self.selectImgView?.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
    }
    //MARK: ***** Actions *****
    //添加图片
    @objc private func onTapGestureForImgView() {
        if (self.cellDelegate != nil) {
            self.cellDelegate?.onAddPictureFromHDAddPictureView(self);
        }
    }
    
    //删除图片
    @objc private func onDeleteForImgView() {
        if (self.cellDelegate != nil) {
            self.cellDelegate?.onDeltePictureFromHDAddPictureView(self);
        }
    }
    
    @objc private func onLongGestureForImgView(_ gest:UILongPressGestureRecognizer) {
        if gest.view != nil && gest.state == .began {
            if (self.cellDelegate != nil) {
                self.cellDelegate?.onDeltePictureFromHDAddPictureView(self);
            }
        }
    }
    
    //MARK: 传值
    public func onShowImage(_ img: UIImage,_ isShow: Bool) {
        self.selectImgView?.isHidden = !isShow;
        self.selectImgView?.image = img;
        self.selectImgBt?.isHidden = self.selectImgView!.isHidden;
    }
}
