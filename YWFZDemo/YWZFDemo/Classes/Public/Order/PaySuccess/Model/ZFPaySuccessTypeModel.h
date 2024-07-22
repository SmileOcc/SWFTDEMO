//
//  ZFPaySuccessTypeModel.h
//  ZZZZZ
//
//  Created by YW on 7/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFPaySuccessType) {
    ZFPaySuccessTypePoint = 0,      // 顶部积分
    ZFPaySuccessTypeDetail,         // 详情
    ZFPaySuccessTypeBanner,         // 多分管
    ZFPaySuccessTypeFivethCouponBanner,   // 五周年优惠券banner
    ZFPaySuccessTypeFivethPointBanner,   // 五周年积分banner
    ZFPaySuccessTypeOrderPartHint,         // 拆单提示
    ZFPaySuccessTypeCODCheckAddress,       // COD地址确认提示
};

@interface ZFPaySuccessTypeModel : NSObject

@property (nonatomic, assign) ZFPaySuccessType   type;
@property (nonatomic, assign) NSInteger          rowCount;
@property (nonatomic, assign) CGFloat            rowHeight;

- (instancetype)initWithPaySuccessModel:(ZFPaySuccessType)type rowCount:(NSInteger)rowCount;

@end
