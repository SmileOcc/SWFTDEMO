//
//  ZFGeshopNavtiveAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/10/15.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopNavtiveAOP.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFGoodsModel.h"
#import "ZFGeshopSectionModel.h"
#import "ZFGeshopGridGoodsCell.h"
#import "ZFGeshopTextImageCell.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "AccountManager.h"
#import "ZFAnalyticsExposureSet.h"
#import "ZFGeshopSecKilGoodsCell.h"

@interface ZFGeshopNavtiveAOP ()
@property (nonatomic, strong) NSMutableArray *themeAnalyticsList;
@end

@implementation ZFGeshopNavtiveAOP

- (void)after_collectionView:(UICollectionView *)collection willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isGoodsCell = [cell isKindOfClass:[ZFGeshopGridGoodsCell class]];
    BOOL isSecKilCell = [cell isKindOfClass:[ZFGeshopSecKilGoodsCell class]];
    if (isGoodsCell || isSecKilCell) { ///商品组件, 秒杀组件
        
        ZFGeshopSectionListModel *listModel = nil;
        if (isGoodsCell) { ///商品组件
            ZFGeshopGridGoodsCell *tcell = (ZFGeshopGridGoodsCell *)cell;
            listModel = tcell.sectionModel.component_data.list[tcell.indexPath.item];
            
        } else { ///秒杀组件
            ZFGeshopSecKilGoodsCell *tcell = (ZFGeshopSecKilGoodsCell *)cell;
            listModel = tcell.sectionModel.component_data.list[tcell.indexPath.item];
        }
        
        if ([self.themeAnalyticsList containsObject:ZFToString(listModel.goods_sn)]) return;
        [self.themeAnalyticsList addObject:ZFToString(listModel.goods_sn)];
        
        ZFGoodsModel *model = [[ZFGoodsModel alloc] init];
        model.af_rank = indexPath.item + 1;
        model.goods_sn = listModel.goods_sn;
        model.goods_id = listModel.goods_id;
        model.goods_title = listModel.goods_title;
        model.cat_name = listModel.category;
        
        if (ZFIsEmptyString(self.selectedSort)) {
            self.selectedSort = @"recommend";
        }
        [ZFAppsflyerAnalytics trackGoodsList:@[model]
                                inSourceType:ZFAppsflyerInSourceTypeNativeTopic
                                    sourceID:self.nativeThemeId
                                        sort:ZFToString(self.selectedSort)
                                    aFparams:nil];
        
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:model page:GIOGoodsTypeNative];
        
    } else if ([cell isKindOfClass:[ZFGeshopTextImageCell class]]) { ///文本组件
        ZFGeshopTextImageCell *tcell = (ZFGeshopTextImageCell *)cell;
        ZFGeshopSectionModel *sectionModel = tcell.sectionModel;
        
        NSString *key = [ZFToString(sectionModel.component_id) stringByAppendingString:ZFToString(sectionModel.component_data.floor_id)];
        
        if (![[ZFAnalyticsExposureSet sharedInstance].nativeThemeAnalyticsArray containsObject:ZFToString(key)]) {
            [[ZFAnalyticsExposureSet sharedInstance].nativeThemeAnalyticsArray addObject:ZFToString(key)];
            [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithnativeThemeSectionModel:sectionModel pageName:self.nativeThemeName nativeThemeId:self.nativeThemeId];
        }
    }
}

- (void)after_collectionView:(UICollectionView *)collection didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collection cellForItemAtIndexPath:indexPath];
    
    BOOL isGoodsCell = [cell isKindOfClass:[ZFGeshopGridGoodsCell class]];
    BOOL isSecKilCell = [cell isKindOfClass:[ZFGeshopSecKilGoodsCell class]];
    if (isGoodsCell || isSecKilCell) { ///商品组件, 秒杀组件
        
        ZFGeshopSectionListModel *listModel = nil;
        if (isGoodsCell) { ///商品组件
            ZFGeshopGridGoodsCell *tcell = (ZFGeshopGridGoodsCell *)cell;
            listModel = tcell.sectionModel.component_data.list[tcell.indexPath.item];
            
        } else { ///秒杀组件
            ZFGeshopSecKilGoodsCell *tcell = (ZFGeshopSecKilGoodsCell *)cell;
            listModel = tcell.sectionModel.component_data.list[tcell.indexPath.item];
        }
        
        ZFGoodsModel *model = [[ZFGoodsModel alloc] init];
        model.af_rank = indexPath.item + 1;
        model.goods_sn = listModel.goods_sn;
        model.goods_id = listModel.goods_id;
        model.goods_title = listModel.goods_title;
        model.cat_name = listModel.category;
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                          @"af_spu_id" : ZFToString(model.goods_spu),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type),
                                          @"af_page_name" : @"native_topic",
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
        [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:GIOGoodsTypeNative sourceParams:@{
            GIOGoodsTypeEvar : GIOGoodsTypeNative,
            GIOGoodsNameEvar : [NSString stringWithFormat:@"native_topic_%@", self.nativeThemeId]
        }];
    } else if ([cell isKindOfClass:[ZFGeshopTextImageCell class]]) {
        ZFGeshopTextImageCell *tcell = (ZFGeshopTextImageCell *)cell;
        ZFGeshopSectionModel *sectionModel = tcell.sectionModel;
        [ZFGrowingIOAnalytics ZFGrowingIOBannerClickWithnativeThemeSectionModel:sectionModel pageName:self.nativeThemeName nativeThemeId:self.nativeThemeId];
    }
}

-(NSDictionary *)injectMenthodParams
{
    NSDictionary *params = @{
        NSStringFromSelector(@selector(collectionView:willDisplayCell:forItemAtIndexPath:)) : NSStringFromSelector(@selector(after_collectionView:willDisplayCell:forItemAtIndexPath:)),
        NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
            NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
    };
    return params;
}

- (NSMutableArray *)themeAnalyticsList {
    if (!_themeAnalyticsList) {
        _themeAnalyticsList = [NSMutableArray array];
    }
    return _themeAnalyticsList;
}

@end
