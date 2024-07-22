//
//  UICollectionView+TouchPreviewing.m
//  ZZZZZ
//
//  Created by YW on 2018/4/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "UICollectionView+TouchPreviewing.h"
#import "ZFPreviewingViewController.h"
#import "ZFGoodsDetailViewModel.h"
#import "ZFCollectionViewModel.h"
#import "CommendModel.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "NSObject+Swizzling.h"
#import "ZFAnalytics.h"
#import "CartOperationManager.h"
#import "ZF3DTouchHeader.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"

#pragma mark -===========扩展3DTouch事件===========
@implementation UICollectionView (TouchPreviewing)

#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    YWLog(@"---按压屏幕触发3DTouch事件---");
    
    // 用于显示预览的vc
    UICollectionViewCell *touchCell = (UICollectionViewCell *)[previewingContext sourceView];
    if (!touchCell || ![touchCell isKindOfClass:[UICollectionViewCell class]]) return nil;
    
    NSIndexPath *indexPath = [self indexPathForCell:touchCell];
    if(!indexPath) return nil;
    
    NSDictionary *cellDataDic = objc_getAssociatedObject(touchCell, k3DTouchPreviewingModelKey);
    if (!cellDataDic || ![cellDataDic isKindOfClass:[NSDictionary class]]) return nil;
    NSMutableDictionary *likeRefreshDict = [NSMutableDictionary dictionaryWithDictionary:cellDataDic];
    
    //添加到购物车
    NSString *bagTitle = ZFLocalizedString(@"3DTouch_Pop_Add_To_Bag", nil);
    UIPreviewAction *addCarAction = [UIPreviewAction actionWithTitle:bagTitle style:UIPreviewActionStyleDefault handler:^(UIPreviewAction *action, UIViewController *previewViewController) {
        
        //请求添加到购物车
        NSString *goods_id = ZFToString(likeRefreshDict[@"goods_id"]);
        NSString *comeFromType = ZFToString(likeRefreshDict[k3DTouchComeFromTypeKey]);
        [self requestAddToShoppingCar:goods_id comeFromType:comeFromType];
    }];
    
    NSString *tipString = ZFLocalizedString(@"3DTouch_Pop_Add_To_Favorites", nil);
    NSString *is_collect = likeRefreshDict[@"is_collect"];
    if ([is_collect isEqualToString:@"1"]) { //已收藏
        tipString = ZFLocalizedString(@"3DTouch_Pop_Remove_Favorites", nil);
    }
    
    //添加到收藏夹
    UIPreviewAction *wishlistAction = [UIPreviewAction actionWithTitle:tipString style:UIPreviewActionStyleDefault handler:^(UIPreviewAction *action, UIViewController *previewViewController) {
        
        BOOL addCollect = YES;
        if ([is_collect isEqualToString:@"1"]) { //已收藏
            likeRefreshDict[@"is_collect"] = @"0";
            addCollect = NO;
        } else {
            likeRefreshDict[@"is_collect"] = @"1";
            addCollect = YES;
        }
        likeRefreshDict[@"NeedRefreshFrom3DTouch"] = @"YES";
        
        //请求添加收藏
        NSString *comeFromType = ZFToString(likeRefreshDict[k3DTouchComeFromTypeKey]);
        [self requestAddCollected:likeRefreshDict
                       addCollect:addCollect
                     comeFromType:comeFromType
                        touchCell:touchCell
                   touchIndexPath:indexPath];
    }];
    
    //取消
    NSString *cancelTitle = ZFLocalizedString(@"3DTouch_Pop_Cancel", nil);
    UIPreviewAction *cancelAction = [UIPreviewAction actionWithTitle:cancelTitle style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction *action, UIViewController *previewViewController) {
        YWLog(@"Cancel 3DTouch");
    }];
    
    //商品上架状态{1：上架，0：下架},
    NSString *is_on_sale = ZFToString(likeRefreshDict[@"is_on_sale"]);
    NSString *goods_number = ZFToString(likeRefreshDict[@"goods_number"]);
    
    //预览控制器
    ZFPreviewingViewController *previewingVC = [[ZFPreviewingViewController alloc] init];
    previewingVC.view.backgroundColor = [UIColor whiteColor];
    
    NSString *smallPicUrl = likeRefreshDict[@"smallPicUrl"];
    NSURL *url = [NSURL URLWithString:smallPicUrl];
    NSString *cacheKey = [[YYWebImageManager sharedManager] cacheKeyForURL:url];
    
    //这里为什么要这样奇葩的拼接,是因为YYimage库底层是这样存的
    UIImage *placeholderImg = [[YYImageCache sharedCache] getImageForKey:cacheKey];
    
    CGSize showSize = CGSizeMake(KScreenWidth*0.96, KScreenHeight*0.73);
    if ([placeholderImg isKindOfClass:[UIImage class]]) {
        CGFloat showImageHeight = (placeholderImg.size.height * KScreenWidth*0.96) / placeholderImg.size.width;
        showSize = CGSizeMake(KScreenWidth*0.96, showImageHeight);
    } else {
        if (KScreenHeight >= 736.0f) {
            showSize = CGSizeMake(KScreenWidth*0.96, KScreenHeight*0.6);
        }
    }
    previewingVC.preferredContentSize = showSize;
    previewingVC.placeholderImg = placeholderImg;
    previewingVC.previewingImageOrUrl = ZFToString(likeRefreshDict[@"goods_thumb"]);

    /**
     * 传递上拉菜单项给actions
     * 下架，没有货,不显示添加到购物车按钮
     */
    if ([goods_number integerValue] == 0 || [is_on_sale integerValue] == 0) {
        previewingVC.actions = @[wishlistAction, cancelAction];
    } else {
        previewingVC.actions = @[addCarAction, wishlistAction, cancelAction];
    }
    return previewingVC;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    YWLog(@"----用力按钮屏幕进入控制器----");
    UICollectionViewCell *touchCell = (UICollectionViewCell *)[previewingContext sourceView];
    if (!touchCell || ![touchCell isKindOfClass:[UICollectionViewCell class]]) return ;
    
    NSIndexPath *indexPath = [self indexPathForCell:touchCell];
    if (indexPath && self.delegate && [self.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [self relationCellBy3DTouch:YES indexPath:indexPath];
        [self.delegate collectionView:self didSelectItemAtIndexPath:indexPath];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self relationCellBy3DTouch:NO indexPath:indexPath];
        });
    }
}

/**
 * 给cell关联一个值,页面上调用didSelectItemAtIndexPath方法时标识是从3DTouch进来
 */
- (void)relationCellBy3DTouch:(BOOL)mark indexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return;
    objc_setAssociatedObject(indexPath, k3DTouchRelationCellComeFrom, @(mark), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark -===========请求操作===========

/**
 * 请求添加到购物车
 */
- (void)requestAddToShoppingCar:(NSString *)goodsId comeFromType:(NSString *)fromType
{
    [[ZFGoodsDetailViewModel new] requestAddToCart:ZFToString(goodsId) loadingView:self.superview goodsNum:1 completion:nil];
    
    //appsFlyer统计
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentType] = ZFToString(fromType);
    [ZFAnalytics appsFlyerTrackEvent:@"af_3DTouch_add_to_bag" withValues:valuesDic];
}

/**
 * 请求添加收藏
 */
- (void)requestAddCollected:(NSDictionary *)likeRefreshInfo
                 addCollect:(BOOL)addCollect
               comeFromType:(NSString *)fromType
                  touchCell:(UICollectionViewCell *)touchCell
             touchIndexPath:(NSIndexPath *)touchIndexPath
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = addCollect ? @"0" : @"1";
    dict[@"goods_id"] = ZFToString(likeRefreshInfo[@"goods_id"]);
    dict[kLoadingView] = self.superview;
    
    ShowLoadingToView(self.superview);
    @weakify(self);
    [ZFCollectionViewModel requestCollectionGoodsNetwork:dict completion:^(BOOL isOK) {
        @strongify(self);
        if (isOK) {
            HideLoadingFromView(self.superview);
            [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionGoodsNotification object:nil userInfo:likeRefreshInfo];
            
            //appsFlyer统计
            NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
            valuesDic[AFEventParamContentType] = ZFToString(fromType);
            if (addCollect) {
                ShowToastToViewWithText(self.superview, ZFLocalizedString(@"Product_Collection_success", nil));
                [ZFAnalytics appsFlyerTrackEvent:@"af_3DTouch_add_to_Collection" withValues:valuesDic];
            } else {
                ShowToastToViewWithText(self.superview, ZFLocalizedString(@"Product_remover_Collection_success", nil));
                [ZFAnalytics appsFlyerTrackEvent:@"af_3DTouch_remover_Collection" withValues:valuesDic];
            }
            
            //采用kvo改变model的收藏状态刷新Cell
            [self refreshModelAndCell:touchCell touchIndexPath:touchIndexPath addCollect:addCollect];
            
        } else {
            ShowToastToViewWithText(self.superview, ZFLocalizedString(@"Failed", nil));
        }
    } target:self];
}

/**
 * 这里采用kvo改变model的收藏状态,刷新Cell,不用发通知去页面更改,因为页面太多
 */
- (void)refreshModelAndCell:(UICollectionViewCell *)touchCell
             touchIndexPath:(NSIndexPath *)touchIndexPath
                 addCollect:(BOOL)addCollect
{
    //判断是否有goodsModel属性
    if (![[touchCell class] zf_hasVarName:@"goodsModel"]) return;
    
    id goodsModel = [touchCell valueForKey:@"goodsModel"];
    if (goodsModel) {
        NSString *collectStatus = addCollect ? @"1" : @"0";
        [goodsModel setValue:collectStatus forKey:@"is_collect"];
        
        NSNumber *dataCountNum = nil;
        if (touchIndexPath && self.dataSource && [self.dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            NSInteger dataCount = [self.dataSource collectionView:self numberOfItemsInSection:touchIndexPath.section];
            dataCountNum = [NSNumber numberWithInteger:dataCount];
        }
        
        if (dataCountNum && [dataCountNum integerValue] > touchIndexPath.item) {
            //如果是浏览历史, 则需要更新数据库
            if ([goodsModel isKindOfClass:[CommendModel class]]) {
                [[CartOperationManager sharedManager] updateCommend:goodsModel];
            }
            
            NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForItem:touchIndexPath.item inSection:touchIndexPath.section];
            [UIView performWithoutAnimation:^{
                [self reloadItemsAtIndexPaths:@[reloadIndexPath]];
            }];
        }
    }
}

@end

