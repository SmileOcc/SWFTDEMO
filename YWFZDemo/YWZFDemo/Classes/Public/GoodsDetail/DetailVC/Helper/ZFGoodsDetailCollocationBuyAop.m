//
//  ZFGoodsDetailCollocationBuyAop.m
//  ZZZZZ
//
//  Created by YW on 2019/12/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailCollocationBuyAop.h"
#import "ZFCollocationBuyModel.h"
#import "ZFGoodsDetailCollocationBuyItemCell.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@interface ZFGoodsDetailCollocationBuyAop ()
@property (nonatomic, strong) NSMutableArray *analyticsSet;
@property (nonatomic, weak) UIViewController *currentController;
@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;
@property (nonatomic, copy) NSString *af_first_entrance;
@end

@implementation ZFGoodsDetailCollocationBuyAop

- (instancetype)initAopWithSourceType:(ZFAppsflyerInSourceType)sourceType
{
    self = [super init];
    if (self) {
        self.sourceType = sourceType;
        self.analyticsSet = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)gainCurrentAopClass:(id)currentAopClass {
    self.currentController = currentAopClass;
    
    if ([NSStringFromClass(self.currentController.class) isEqualToString:@"ZFGoodsDetailCollocationBuyCell"]) {
    }
}

- (void)after_resetCollocationBuyList {
    [self.analyticsSet removeAllObjects];
}

///// 不能使用此方法, 因为会提前曝光搭配购, 因此在页面上做曝光操作
//- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell isKindOfClass:[ZFGoodsDetailCollocationBuyItemCell class]]) {
//
//        ZFGoodsDetailCollocationBuyItemCell *productCell = (ZFGoodsDetailCollocationBuyItemCell *)cell;
//        if ([productCell.model isKindOfClass:[ZFCollocationGoodsModel class]]) {
//            ZFCollocationGoodsModel *goodsModel = (ZFCollocationGoodsModel *)productCell.model;
//            if ([self.analyticsSet containsObject:ZFToString(goodsModel.goods_id)]) {
//                return;
//            }
//            YWLog(@"======是否提前曝光: 搭配购区域商品======");
//            [ZFAppsflyerAnalytics zfTrackEvent:@"af_recommend_collocation_impression" withValues:@{}];
//        }
//    }
//}

// appflyer统计
-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    if ([cell isKindOfClass:[ZFGoodsDetailCollocationBuyItemCell class]]) {
        ZFGoodsDetailCollocationBuyItemCell *productCell = (ZFGoodsDetailCollocationBuyItemCell *)cell;
        if (![productCell.model isKindOfClass:[ZFCollocationGoodsModel class]])return;
        //ZFCollocationGoodsModel *goodsModel = productCell.model;
        
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_recommend_collocation_click" withValues:@{}];
    }
}

-(NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
//        NSStringFromSelector(@selector(collectionView:willDisplayCell:forItemAtIndexPath:)) : NSStringFromSelector(@selector(after_collectionView:willDisplayCell:forItemAtIndexPath:)),
        
        NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
            NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
        
        @"resetCollocationBuyList" : @"after_resetCollocationBuyList",
    };
    return params;
}

@end
