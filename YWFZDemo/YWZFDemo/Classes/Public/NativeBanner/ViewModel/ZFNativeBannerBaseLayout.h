//
//  ZFNativeBannerBaseLayout.h
//  ZZZZZ
//
//  Created by YW on 31/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 原生专题类型 */
typedef NS_ENUM(NSInteger, ZFNativeBannerType) {
    ZFNativeBannerTypeOne    = 1,   // 1分馆
    ZFNativeBannerTypeBranch = 2,   // 多分馆
    ZFNativeBannerTypeSlide,        // 滑动Banner
    ZFNativeBannerTypeSKUBanner,    // skuBanner
    ZFNativeBannerTypeGoodsList,    // 商品列表(实际不需要用到)
    ZFNativeBannerTypeVideo         // 视频
};

@interface ZFNativeBannerBaseLayout : NSObject

@property (nonatomic, assign) ZFNativeBannerType            type;
@property (nonatomic, assign) CGSize                        headerSize;
@property (nonatomic, assign) CGSize                        footerSize;
@property (nonatomic, assign) UIEdgeInsets                  edgeInsets;
@property (nonatomic, assign) CGFloat                       minimumLineSpacing;
@property (nonatomic, assign) CGFloat                       minimumInteritemSpacing;
@property (nonatomic, assign, readonly) NSInteger           rowCount;
@property (nonatomic, assign) CGSize                        itemSize;

- (void)setRowCount:(NSInteger)rowCount;

@end
