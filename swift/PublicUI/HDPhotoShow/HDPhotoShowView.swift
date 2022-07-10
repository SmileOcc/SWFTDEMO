//
//  HDPhotoShowView.swift
//  HDPublicUIProject
//
//  Created by 航电 on 2020/9/21.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

public class HDPhotoShowView: UIView {

    public var imageData:NSArray {
        set {
            if imgArray != newValue {
                imgArray = newValue;
                
                if imgArray.count > imgSelectIndex {
                    self.mainCollectionView?.scrollToItem(at: NSIndexPath(item: imgSelectIndex, section: 0) as IndexPath, at: .centeredHorizontally, animated: false);
                }
                
                self.mainCollectionView?.reloadData();
                self.titleLb?.text = "\(imgSelectIndex+1)"+"/"+"\(imgArray.count)"
            }
        }
        get {
            return imgArray;
        }
    }
    
    public var imageIndex:NSInteger {
        set {
            if imgSelectIndex != newValue {
                imgSelectIndex = newValue;
                
                if imgArray.count > 0 {
                    if imgArray.count > imgSelectIndex {
                        self.mainCollectionView?.scrollToItem(at: NSIndexPath(item: imgSelectIndex, section: 0) as IndexPath, at: .centeredHorizontally, animated: false);
                    }
                    
                    self.mainCollectionView?.reloadData();
                    self.titleLb?.text = "\(imgSelectIndex+1)"+"/"+"\(imgArray.count)"
                }
            }
        }
        get {
            return imgSelectIndex;
        }
    }
    
    private var mainCollectionView:UICollectionView?
    private var titleLb:UILabel?
    private var selectWindow:UIWindow?
    private var imgArray:NSArray = NSArray();
    private var imgSelectIndex:NSInteger = 0;
    
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
        self.backgroundColor = .BlackTitle();
        
        let flowLayout = UICollectionViewFlowLayout();
        flowLayout.itemSize = screenSize;
        flowLayout.scrollDirection = .horizontal;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        if self.mainCollectionView == nil {
            self.mainCollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout);
            self.mainCollectionView?.delegate = self;
            self.mainCollectionView?.dataSource = self;
            self.mainCollectionView?.showsVerticalScrollIndicator = false;
            self.mainCollectionView?.showsHorizontalScrollIndicator = false;
            self.mainCollectionView?.backgroundColor = self.backgroundColor;
            self.mainCollectionView?.isPagingEnabled = true;
            self.mainCollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "HDPhotoShow_Collection_Cell");
            self.addSubview(self.mainCollectionView!);            
        }
        
        if self.titleLb == nil {
            self.titleLb = UILabel(frame: CGRect(x: 0, y: screenSize.height - 20 - 20, width: screenSize.width, height: 20));
            self.titleLb?.backgroundColor = .clear;
            self.titleLb?.textColor = .WhiteToBlack();
            self.titleLb?.textAlignment = .center;
            self.titleLb?.font = UIFont.systemFont(ofSize: 16, weight: .regular);
            self.addSubview(self.titleLb!);
        }
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
//            self.selectWindow = nil
        }
    }
}

extension HDPhotoShowView: UICollectionViewDelegate,UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          return imgArray.count;
      }

    
      public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HDPhotoShow_Collection_Cell", for: indexPath) as UICollectionViewCell;
        
          let cellContentViews = cell.contentView.subviews;
          if cellContentViews.count == 0 {
              let imgV = UIImageView(frame: cell.bounds);
              imgV.backgroundColor = .clear;
              imgV.contentMode = .scaleAspectFit;
              cell.contentView.addSubview(imgV);
          }
          
          if imgArray.count > indexPath.row {
            let dataimgView = imgArray[indexPath.row] as! UIImageView;
            
              if cell.contentView.subviews.count > 0 {
                  let firstView = cell.contentView.subviews[0];
                  if firstView.isKind(of: UIImageView.self) {
                      let imgView = firstView as! UIImageView;
                    imgView.image = dataimgView.image;
                  }
              }
          }
          
          return cell;
      }
      
      public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          
        self.onHideInWindow()
      }
}

extension HDPhotoShowView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width);
        
        if imgArray.count > pageIndex {
            self.titleLb?.text = "\(pageIndex+1)"+"/"+"\(imgArray.count)"
        }
    }
}
