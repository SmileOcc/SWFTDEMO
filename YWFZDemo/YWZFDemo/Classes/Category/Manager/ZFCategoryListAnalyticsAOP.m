//
//  ZFCategoryListAnalyticsManager.m
//  ZZZZZ
//
//  Created by YW on 2018/10/24.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCategoryListAnalyticsAOP.h"
#import "ZFGoodsListItemCell.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "CategoryListPageModel.h"

@interface ZFCategoryListAnalyticsAOP ()

@property (nonatomic, strong) NSMutableArray *goodsAnalyticsSet;
@property (nonatomic, assign) ZFAppsflyerInSourceType   type;

@end

@implementation ZFCategoryListAnalyticsAOP

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIViewController *currentViewController = [UIViewController currentTopViewController];
        if ([NSStringFromClass(currentViewController.class) isEqualToString:@"CategoryVirtualViewController"]) {
            self.type = ZFAppsflyerInSourceTypeVirtualCategoryList;
        }else if([NSStringFromClass(currentViewController.class) isEqualToString:@"CategoryListPageViewController"]){
            self.type = ZFAppsflyerInSourceTypeCategoryList;
        }
    }
    return self;
}

//-(void)after_collectionView:(UICollectionView *)collectionView
//     cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self.dataList count] <= indexPath.row) {
//        return;
//    }
//    id model = self.dataList[indexPath.row];
//    if ([model isKindOfClass:[ZFGoodsModel class]]) {
//        ZFGoodsModel *goodsModel = (ZFGoodsModel *)model;
//        if ([self.goodsAnalyticsSet containsObject:ZFToString(goodsModel.goods_id)]) {
//            return;
//        }
//        [self.goodsAnalyticsSet addObject:ZFToString(goodsModel.goods_id)];
//        //Appsflyer 统计
//        [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel] inSourceType:ZFAppsflyerInSourceTypeCategoryList sourceID:self.cateName];
//        
//        //GA 统计
//        NSString *impressionName = [NSString stringWithFormat:@"%@_%@", ZFGACategoryList, ZFToString(self.cateName)];
//        
//        [ZFAnalytics showProductsWithProducts:@[goodsModel]
//                                     position:(int)indexPath.row
//                               impressionList:impressionName
//                                   screenName:@"分类列表"
//                                        event:@"load"];
//    }
//}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFGoodsListItemCell class]]) {
        ZFGoodsListItemCell *goodsCell = (ZFGoodsListItemCell *)cell;
        ZFGoodsModel *goodsModel = goodsCell.goodsModel;
        if ([self.goodsAnalyticsSet containsObject:ZFToString(goodsModel.goods_id)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:ZFToString(goodsModel.goods_id)];
 
        //Appsflyer 统计
        goodsModel.af_rank = indexPath.row + 1;
        [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel] inSourceType:self.type sourceID:self.cateName sort:self.sort aFparams:self.afParams];
        
        //GA 统计
        NSString *impressionName = [NSString stringWithFormat:@"%@_%@", ZFGACategoryList, ZFToString(self.cateName)];
        
        [ZFAnalytics showProductsWithProducts:@[goodsModel]
                                     position:(int)indexPath.row
                               impressionList:impressionName
                                   screenName:@"分类列表"
                                        event:@"load"];
        
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:goodsModel page:@"分类列表"];
    }
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZFGoodsListItemCell class]]) {
        ZFGoodsListItemCell *goodsCell = (ZFGoodsListItemCell *)cell;
        ZFGoodsModel *goodsModel = goodsCell.selectedGoodsModel;
        if (!goodsModel) {
            goodsModel = goodsCell.goodsModel;
        } else {
            goodsModel.cat_name = goodsCell.goodsModel.cat_name;
            goodsModel.cat_level_column = goodsCell.goodsModel.cat_level_column;
            goodsModel.channel_type = goodsCell.goodsModel.channel_type;
            goodsModel.goods_number = goodsCell.goodsModel.goods_number;
            goodsModel.recommentType = goodsCell.goodsModel.recommentType;
            goodsModel.postType = goodsCell.goodsModel.postType;
        }
        //GA 统计
        NSString *impressionName = [NSString stringWithFormat:@"%@_%@", ZFGACategoryList, ZFToString(self.cateName)];
        
        [ZFAnalytics clickProductWithProduct:goodsModel
                                    position:(int)indexPath.row
                                  actionList:impressionName];
    }
}

- (void)refreshDataSource
{
    if ([self.goodsAnalyticsSet count]) {
        [self.goodsAnalyticsSet removeAllObjects];
    }
}


- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                             NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                             @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             };
    return params;
}

- (NSMutableArray *)goodsAnalyticsSet
{
    if (!_goodsAnalyticsSet) {
        _goodsAnalyticsSet = [[NSMutableArray alloc] init];
    }
    return _goodsAnalyticsSet;
}

@end
