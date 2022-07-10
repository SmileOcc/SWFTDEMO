//
//  HDBannerView.swift
//  HDPublicUIProject
//
//  Created by 航电 on 2020/8/25.
//  Copyright © 2020 航电. All rights reserved.
//  轮播图

import UIKit

typealias BannerClickBlock = (NSDictionary) -> Void;

public class HDBannerView: UIView {

    //图片数据源
    public var imageDatas:NSArray = NSArray();
    //是否支持自动滑动
    public var autoScroll:Bool = true;
    //自动滑动间隔时间
    public var autoScrollTimeInterval:CGFloat = 4.0;
    //是否支持缩放
    public var isZoom:Bool = false;
    //左右宽度
    public var itemWidth:CGFloat?
    //上下间距
    public var itemTopSpace:CGFloat = 0.0;
    public var placeholderImage:UIImage = UIImage(named: "icon-kongKongpic") ?? UIImage();
    var bannerBlock:BannerClickBlock?;
    
    private var moreImgArr:NSMutableArray = NSMutableArray();
    private var collectionV:UICollectionView?;
    private lazy var flowLayout:HDBannerFlowLayout = {
        let flowLy = HDBannerFlowLayout();
        flowLy.isZoom = self.isZoom;
        flowLy.scrollDirection = .horizontal;
        flowLy.minimumLineSpacing = 0;
        return flowLy;
    }();
    private var pageView:HDBannerPageView?;
    private var timer:Timer?;
    private var lastPoint:CGFloat = 0.0;
    private var dragDirection:Int = 0;
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configData();
        
        onCreateUIForView();
    }

    required init?(coder: NSCoder) {
        fatalError("HDBannerView Load Error");
    }
    
    //MARK: ***** UI *****
    private func onCreateUIForView() {
        
        collectionV = UICollectionView(frame: self.bounds, collectionViewLayout: self.flowLayout);
        collectionV?.delegate = self;
        collectionV?.dataSource = self;
        collectionV?.showsVerticalScrollIndicator = false;
        collectionV?.showsHorizontalScrollIndicator = false;
        collectionV?.backgroundColor = self.backgroundColor;
        collectionV?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "HDBannaer_Collection_Cell");
        self.addSubview(collectionV!);
        
    }
    
    //MARK: ***** Actions *****
    //TODO: ↓ Private Actions ↓
    //TODO: 初始化数据
    private func configData() {
        
    }
    
    //TODO: 默认滚动到第一个cell
    private func onScrollToFirstItem() {
        collectionV?.frame = self.bounds;
        self.flowLayout.itemSize = CGSize(width: itemWidth ?? self.width, height: self.height);
        self.flowLayout.minimumLineSpacing = itemTopSpace;
        
        if /*collectionV?.contentOffset.x == 0 &&*/ moreImgArr.count > 0 {
            
            collectionV?.scrollToItem(at: NSIndexPath(row: 1, section: 0) as IndexPath, at: .centeredHorizontally, animated: false);
            lastPoint = (collectionV?.contentOffset.x)!;
            collectionV?.isUserInteractionEnabled = true;
        }
    }
    
    @objc func onAutomaticScroll() {
        if moreImgArr.count == 0 {
            return;
        }
        
        let currentIndex = currentPage();
        let targetIndex = currentIndex + 1;
        collectionV?.scrollToItem(at: NSIndexPath(row: targetIndex, section: 0) as IndexPath, at: .centeredHorizontally, animated: true);
    }
    
    //TODO: ↓ Public Actions ↓
    public func onLoad() {
        //参数配置
        self.flowLayout.itemSize = CGSize(width: itemWidth ?? self.width, height: self.height);
        self.flowLayout.minimumLineSpacing = itemTopSpace;
        self.flowLayout.isZoom = isZoom;
        
        //计时器
        if autoScroll == true {
            onSetUpTimer(isSetUp: true);
        }
        
        //数据源
        moreImgArr.removeAllObjects();
        if imageDatas.count > 1 {
            moreImgArr.add(imageDatas.lastObject as! String);
            moreImgArr.addObjects(from: imageDatas as! [String]);
            moreImgArr.add(imageDatas.firstObject as! String);
            
            collectionV?.isScrollEnabled = true;
        } else {
            moreImgArr.add("");
            moreImgArr.addObjects(from: imageDatas as! [String]);
            moreImgArr.add("");
            
            collectionV?.isScrollEnabled = false;
            
            onSetUpTimer(isSetUp: false);
        }
        
        pageView?.removeFromSuperview();
        pageView = nil;
        
        if pageView == nil {
            let allPageWidth = .scaleW(11.0) * CGFloat(imageDatas.count <= 1 ? 1 : imageDatas.count);
            pageView = HDBannerPageView(frame: CGRect(x: (collectionV!.width - allPageWidth)/2.0, y: collectionV!.height - .scaleH(5.0) - .scaleH(20.0), width: allPageWidth, height: .scaleH(5.0)), pageCount: (imageDatas.count <= 1 ? 1 : imageDatas.count));
            self.insertSubview(pageView!, aboveSubview: collectionV!);
        }
        pageView?.onSelectPageFromBanner(selectIndex: 0);
        
        collectionV?.reloadData();
        
        onScrollToFirstItem();
    }
    
    public func currentPage() -> Int {
        if collectionV?.width == 0 || collectionV?.height == 0 {
            return 0;
        }
        
        let itemValue = itemWidth ?? self.width + itemTopSpace;
        var currentIndex = ((collectionV?.contentOffset.x)! + itemValue * 0.5) / itemValue;
        if currentIndex < 1 {
            currentIndex = 0.0;
        }
        return Int(max(0, roundf(Float(currentIndex))));
    }
    
    public func onSetUpTimer(isSetUp:Bool) {
        if isSetUp == true {
            onSetUpTimer(isSetUp: false);
            
            if timer == nil {
                timer = Timer(timeInterval: TimeInterval(autoScrollTimeInterval), target: self, selector: #selector(onAutomaticScroll), userInfo: nil, repeats: true);
                RunLoop.main.add(timer!, forMode: .common);
                
                timer?.fire();
            } else {
                timer?.fireDate = Date(timeIntervalSinceNow: TimeInterval(autoScrollTimeInterval));
            }
        } else {
//            timer?.invalidate();
            timer?.fireDate = Date.distantFuture;
        }
    }
    
    public func onBannerBlock(block:@escaping(NSDictionary) -> Void) {
        self.bannerBlock = block;
    }
}

extension HDBannerView:UICollectionViewDelegate,UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moreImgArr.count;
    }

  
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HDBannaer_Collection_Cell", for: indexPath) as UICollectionViewCell;
        
        let cellContentViews = cell.contentView.subviews;
        if cellContentViews.count == 0 {
            let imgV = UIImageView(frame: cell.bounds);
            imgV.backgroundColor = .clear;
//            imgV.contentMode = .scaleAspectFit;
            cell.contentView.addSubview(imgV);
        }
        
        if moreImgArr.count > indexPath.row {
            if cell.contentView.subviews.count > 0 {
                let firstView = cell.contentView.subviews[0];
                if firstView.isKind(of: UIImageView.self) {
                    let imgView = firstView as! UIImageView;
                    let imageName = moreImgArr[indexPath.row] as! String
                    imgView.sd_setImage(with: URL(string: imageName), placeholderImage: UIImage(named: "placeholderImg"))
                }                
            }
        }
        
        return cell;
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let nextIndex = currentPage();
        if indexPath.row == nextIndex {
            
            if self.bannerBlock != nil {
                self.bannerBlock!(["title":"听听"]);
            }
        }
    }
}

extension HDBannerView:UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //滑动关闭交互
        collectionV?.isUserInteractionEnabled = false;
        
        if moreImgArr.count == 0 {
            return;
        }
        
        let nextIndex = currentPage();
        
        if nextIndex == moreImgArr.count-1 {
            pageView?.onSelectPageFromBanner(selectIndex: 0);
        }
        else if nextIndex == 0 {
            pageView?.onSelectPageFromBanner(selectIndex: pageView!.allPageCount-1);
        }
        else {
            pageView?.onSelectPageFromBanner(selectIndex: nextIndex-1);
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastPoint = scrollView.contentOffset.x;
        
        if autoScroll {
            onSetUpTimer(isSetUp: false);
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
      if autoScroll {
          onSetUpTimer(isSetUp: true);
      }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let itemValue = itemWidth ?? self.width + itemTopSpace;
        let currentIndex = (lastPoint + itemValue * 0.5) / itemValue;
        collectionV?.scrollToItem(at: NSIndexPath(row: (Int(currentIndex) + dragDirection), section: 0) as IndexPath, at: .centeredHorizontally, animated: true);
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(collectionV!);
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        let currentPage = self.currentPage();
        if moreImgArr.count > currentPage {
            if currentPage == 0 {
                collectionV?.scrollToItem(at: NSIndexPath(row: moreImgArr.count-2, section: 0) as IndexPath, at: .centeredHorizontally, animated: false);

            }
            else if currentPage == moreImgArr.count-1 {
                collectionV?.scrollToItem(at: NSIndexPath(row: 1, section: 0) as IndexPath, at: .centeredHorizontally, animated: false);
            }
            
        }
        collectionV?.isUserInteractionEnabled = true;
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
       
        let contentOffSetX = scrollView.contentOffset.x;
        let moveWidth = contentOffSetX - lastPoint;
        let movePage = moveWidth / ((itemWidth ?? self.width) / 2.0);
        if velocity.x > 0 || movePage > 0 {
            dragDirection = 1;
        }
        else if velocity.x < 0 || movePage < 0 {
            dragDirection = -1;
        }
        else {
            dragDirection = 0;
        }
        collectionV?.isUserInteractionEnabled = false;
        
        let itemValue = itemWidth ?? self.width + itemTopSpace;
        let currentIndex = (lastPoint + itemValue * 0.5) / itemValue;
        let nextIndex = Int(currentIndex) + dragDirection
        collectionV?.scrollToItem(at: NSIndexPath(row: nextIndex, section: 0) as IndexPath, at: .centeredHorizontally, animated: true);
        
        if nextIndex == moreImgArr.count-1 {
            pageView?.onSelectPageFromBanner(selectIndex: 0);
        }
        else if nextIndex == 0 {
            pageView?.onSelectPageFromBanner(selectIndex: pageView!.allPageCount-1);
        }
        else {
            pageView?.onSelectPageFromBanner(selectIndex: nextIndex-1);
        }
    }
    
    
}
