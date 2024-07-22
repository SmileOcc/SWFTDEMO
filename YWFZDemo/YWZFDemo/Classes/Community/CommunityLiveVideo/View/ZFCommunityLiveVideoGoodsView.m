//
//  ZFCommunityLiveVideoGoodsView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveVideoGoodsView.h"
#import "ZFInitViewProtocol.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFLocalizationString.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "Masonry.h"
#import "UIView+ZFViewCategorySet.h"

#import "ZFCommunityLiveVideoGoodsCCell.h"
#import "ZFCommunityLiveVideoCouponCCell.h"

#import "ZFCommunityLiveVideoGoodsModel.h"
#import "ZFGoodsDetailViewModel.h"

#import "ZFBaseViewController.h"

@interface ZFCommunityLiveVideoGoodsView()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
ZFInitViewProtocol,
CHTCollectionViewDelegateWaterfallLayout
>

@property (nonatomic, strong) UICollectionView                      *collectionView;

@property (nonatomic, strong) ZFCommunityLiveVideoGoodsModel        *liveGoodsViewModel;

@property (nonatomic, copy) NSString                                *cateID;
@property (nonatomic, copy) NSString                                *skus;

@property (nonatomic, assign) BOOL                                  isDraging;
@property (nonatomic, assign) CGFloat                               contentOffsetY;

@end

@implementation ZFCommunityLiveVideoGoodsView

- (instancetype)initWithFrame:(CGRect)frame cateName:(NSString *)cateName cateID:(NSString *)cateID skus:(NSString *)skus{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.cateID = cateID;
        self.skus = skus;
        [self zfInitView];
        [self zfAutoLayoutView];
        
        [self requestLiveGoodsPageData:YES];
    }
    return self;
}

- (void)zfViewWillAppear {
    
}

- (void)zfInitView {
    [self addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)fullScreen:(id)isFull {
    if (![isFull boolValue]) {
        [self scrollCurrentContnetOffSetY];
    }
}

- (void)scrollCurrentContnetOffSetY {
    if (self.contentOffsetY > 0) {
        [self.collectionView setContentOffset:CGPointMake(0, self.contentOffsetY) animated:NO];
    }
}
- (void)requestLiveGoodsPageData:(BOOL)isFirstPage {
    @weakify(self)
    [self.liveGoodsViewModel requestLiveVideoGoodsData:isFirstPage videoCoupon:ZFToString(self.cateID) skus:ZFToString(self.skus) completion:^(NSArray<ZFGoodsModel *> * _Nonnull goodsArray, NSDictionary * _Nonnull pageInfo) {
        @strongify(self)
        
        [self.collectionView reloadData];
        [self.collectionView showRequestTip:pageInfo];
        
        if (self.goodsArrayBlock) {
            self.goodsArrayBlock([self currentGoodsArray]);
        }
        self.contentOffsetY = self.collectionView.contentOffset.y;

    } failure:^(id  _Nonnull obj) {
        
    }];
}

- (NSMutableArray<ZFGoodsModel *> *)currentGoodsArray {
    return self.liveGoodsViewModel.goodsArray;
}

- (void)addCartGoods:(ZFGoodsModel *)goodsModel {
    if (self.cartGoodsBlock) {
        self.cartGoodsBlock(goodsModel);
    }
}

- (void)similarGoods:(ZFGoodsModel *)goodsModel {
    if (self.similarGoodsBlock) {
        self.similarGoodsBlock(goodsModel);
    }
}

- (void)receiveCoupon:(ZFGoodsDetailCouponModel *)couponModel {

    ZFBaseViewController *baseVC = (ZFBaseViewController *)self.viewController;
    baseVC.isStatusBarHidden  = NO;
    
    @weakify(self)
    [self.viewController judgePresentLoginVCCompletion:^{
        @strongify(self)
        baseVC.isStatusBarHidden = YES;

        // 领取优惠券
        ShowLoadingToView(self.viewController.view);
        
        // 1. 调取领劵接口
        @weakify(self)
        [ZFCommunityLiveVideoGoodsModel requestGetGoodsCoupon:couponModel.couponId completion:^(BOOL success, NSInteger couponStatus) {
            @strongify(self)

            // 1:领劵成功;2:领券Coupon不存在;3:已领券;4:没到领取时间;5:已过期;6:coupon已领取完;7:赠送coupon失败
            // 默认提示已领完
            NSString *tiptext = ZFLocalizedString(@"Detail_ReceiveCouponFail", nil);
            
            // 注意界面显示状态 // coupon状态；1:可领取;2:已领取;3:已领取完
            if (success) {
                if (couponStatus == 1) {
                    tiptext = ZFLocalizedString(@"Detail_ReceiveCouponSuccess", nil);
                    self.liveGoodsViewModel.couponModel.couponStats = 2;
                    [self.collectionView reloadData];
                    
                } else if (couponStatus == 6) {
                    tiptext = ZFLocalizedString(@"Detail_ReceiveCouponUsedUp", nil);
                    self.liveGoodsViewModel.couponModel.couponStats = 3;
                    [self.collectionView reloadData];
                }
                
                ShowToastToViewWithText(self.viewController.view, tiptext);
            } else {
                ShowToastToViewWithText(self.viewController.view, tiptext);
            }
        }];
    } cancelCompetion:^{
        baseVC.isStatusBarHidden = YES;
    }];
}
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    //没商品时，隐藏优惠券领取
    if (self.liveGoodsViewModel.goodsArray.count > 0 && !ZFIsEmptyString(self.liveGoodsViewModel.couponModel.couponId)) {
         return self.liveGoodsViewModel.goodsArray.count + 1;
     }
    return self.liveGoodsViewModel.goodsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    @weakify(self)
    if (self.liveGoodsViewModel.goodsArray.count > 0 && !ZFIsEmptyString(self.liveGoodsViewModel.couponModel.couponId) && indexPath.row == 0) {
        
        ZFCommunityLiveVideoCouponCCell *couponCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveVideoCouponCCell class]) forIndexPath:indexPath];
        couponCell.receiveCouponBlock = ^(ZFGoodsDetailCouponModel * _Nonnull couponModel) {
            @strongify(self)
            [self receiveCoupon:couponModel];
        };
        couponCell.couponModel = self.liveGoodsViewModel.couponModel;
        return couponCell;
        
    }
    
    ZFCommunityLiveVideoGoodsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveVideoGoodsCCell class]) forIndexPath:indexPath];
    
    NSInteger tempRow = !ZFIsEmptyString(self.liveGoodsViewModel.couponModel.couponId) ? 1 : 0;
    if (self.liveGoodsViewModel.goodsArray.count > indexPath.row - tempRow) {
        
        ZFGoodsModel *goodsModel = self.liveGoodsViewModel.goodsArray[indexPath.row - tempRow];
        cell.goodsModel = goodsModel;
    }
    
    
    cell.cartBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
        @strongify(self)
        [self addCartGoods:goodsModel];
    };
    
    cell.findSimilarBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
        @strongify(self)
        [self similarGoods:goodsModel];
    };
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.liveGoodsViewModel.goodsArray.count > 0
        && !ZFIsEmptyString(self.liveGoodsViewModel.couponModel.couponId)
        && indexPath.row == 0) {

    } else {
        
        NSInteger tempRow = !ZFIsEmptyString(self.liveGoodsViewModel.couponModel.couponId) ? 1 : 0;
        if (self.liveGoodsViewModel.goodsArray.count > indexPath.row - tempRow) {
            ZFGoodsModel *goodsModel = self.liveGoodsViewModel.goodsArray[indexPath.row - tempRow];
            if (self.selectBlock) {
                self.selectBlock(goodsModel);
            }
        }
    }
}


#pragma mark -===CHTCollectionViewDelegateWaterfallLayout===


/**
 * 每个Item的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.liveGoodsViewModel.goodsArray.count > 0 && !ZFIsEmptyString(self.liveGoodsViewModel.couponModel.couponId) && indexPath.row == 0) {
        return CGSizeMake(KScreenWidth, 96);
    }
    return CGSizeMake(KScreenWidth, 144);
}

/**
 * 每个section之间的缩进间距
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(12, 12, 12, 12);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section {
    return  0;
}

#pragma mark - UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetY = scrollView.contentOffset.y;
    YWLog(@"------- %f",offsetY);
    
    if (self.isDraging) {// 这个只处理拖拽
        self.contentOffsetY = offsetY;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    YWLog(@"-----scrollViewDidEndDecelerating：%f",scrollView.contentOffset.y);
    self.contentOffsetY = scrollView.contentOffset.y;
    
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    self.isDraging = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDraging = YES;
}
#pragma mark - Property Method

- (ZFCommunityLiveVideoGoodsModel *)liveGoodsViewModel {
    if (!_liveGoodsViewModel) {
        _liveGoodsViewModel = [[ZFCommunityLiveVideoGoodsModel alloc] init];
    }
    return _liveGoodsViewModel;
}


- (UICollectionView *)collectionView {
    if(!_collectionView){
        
        CHTCollectionViewWaterfallLayout *waterfallLayout = [[CHTCollectionViewWaterfallLayout alloc] init]; //创建布局
        waterfallLayout.minimumColumnSpacing = 13;
        waterfallLayout.minimumInteritemSpacing = 0;
        waterfallLayout.headerHeight = 0;
        waterfallLayout.columnCount = 1;
        
        CGRect frameRect = self.bounds;
        if (CGSizeEqualToSize(frameRect.size, CGSizeZero)) {
            frameRect = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 150);
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:frameRect collectionViewLayout:waterfallLayout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = YES;
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_collectionView registerClass:[ZFCommunityLiveVideoGoodsCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveVideoGoodsCCell class])];
        [_collectionView registerClass:[ZFCommunityLiveVideoCouponCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveVideoCouponCCell class])];

        _collectionView.emptyDataTitle = ZFLocalizedString(@"Community_LivesVideo_Goods_Sold_Out_msg", nil);
        @weakify(self);
        [self.collectionView addCommunityHeaderRefreshBlock:^{
            @strongify(self);
            [self requestLiveGoodsPageData:YES];
            
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self requestLiveGoodsPageData:NO];
            
        } startRefreshing:NO];
    }
    return _collectionView;
}

@end
