//
//  ZFGoodsDetailTypeModel.h
//  ZZZZZ
//
//  Created by YW on 2017/11/26.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZFGoodsDetailType) {
    ZFGoodsDetailTypeActivity = 0,
    ZFGoodsDetailTypeCoupon,
    ZFGoodsDetailTypeSelectStandard, //V4.5.3 内嵌选择尺码规格
    ZFGoodsDetailTypeGoodsInfo,
    ZFGoodsDetailTypeQualified,
    ZFGoodsDetailTypePatchUpTips,   // //V4.6.0 商详为C版本时,需要凑单提示
    ZFGoodsDetailTypeSizeInfo,      // V4.5.3 ABTest增加内嵌选择尺码规格后不再单独显示SizeInfo一栏
    ZFGoodsDetailTypeShippingTips,
    ZFGoodsDetailTypeDescription,
    ZFGoodsDetailTypeSizeGuide,     // V4.5.3 ABTest增加内嵌选择尺码规格后不再单独显示SizeGuide一栏
    ZFGoodsDetailTypeModelStats,
    ZFGoodsDetailTypeShow,
    ZFGoodsDetailTypeReview,
    ZFGoodsDetailTypeRecommend,
};

@interface ZFGoodsDetailTypeModel : NSObject

@property (nonatomic, assign) ZFGoodsDetailType type;

+ (instancetype)createWithTpye:(ZFGoodsDetailType)type;

@end
