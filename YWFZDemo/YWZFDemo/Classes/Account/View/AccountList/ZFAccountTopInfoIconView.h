//
//  ZFAccountTopInfoIconView.h
//  ZZZZZ
//
//  Created by YW on 2018/5/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFAccountTopInfoIconViewType) {
    ZFAccountTopInfoIconViewTypeOrder = 0,
    ZFAccountTopInfoIconViewTypeWishlist,
    ZFAccountTopInfoIconViewTypeCoupon,
    ZFAccountTopInfoIconViewTypeZPoint,
};

@interface ZFAccountTopInfoIconView : UIView

@property (nonatomic, assign) ZFAccountTopInfoIconViewType          type;

@property (nonatomic, copy) NSString                                *badgeText;

@end
