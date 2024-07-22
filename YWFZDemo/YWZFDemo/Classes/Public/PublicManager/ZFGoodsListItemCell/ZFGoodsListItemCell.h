//
//  ZFGoodsListItemCell.h
//  ZZZZZ
//
//  Created by YW on 2017/8/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFGoodsModel;

typedef void(^CancleCollectHandler)(ZFGoodsModel *model);

/** 各个列表页显示New, Popular,Hot字段的枚举值 自营销商品：1热卖品 2潜力品3 新品 */
typedef NS_ENUM(NSInteger, ZFMarketingTagType) {
    /** 1热卖品 */
    ZFMarketingTagTypeHot = 1,
    /** 2潜力品 */
    ZFMarketingTagTypePopular,
    /** 3 新品 */
    ZFMarketingTagTypeNew,
};

@interface ZFGoodsListItemCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView          *goodsImageView;
@property (nonatomic, strong) ZFGoodsModel         *goodsModel;
@property (nonatomic, strong) ZFGoodsModel         *selectedGoodsModel;

// V4.4.0 是否是新ab测试界面
//@property (nonatomic, assign) BOOL  isNewABText;

@property (nonatomic, copy) CancleCollectHandler                    cancleCollectHandler;
@property (nonatomic, copy) void(^tapSimilarGoodsHandle)(void);

@property (nonatomic, copy) NSString *af_inner_mediasource;  // AF统计来源
@property (nonatomic, copy) NSString *sort;  // AF 排序

@end
