//
//  ZFGoodsDetailNavigationView.h
//  ZZZZZ
//
//  Created by YW on 2017/11/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsDetailEnumDefiner.h"

@interface ZFGoodsDetailNavigationView : UIView

@property (nonatomic, assign) CGFloat               refreshAlpha;
@property (nonatomic, copy) NSString                *imageUrl;
@property (nonatomic, strong, readonly) UIButton    *cartButton;

@property (nonatomic, copy) void (^navigationBlcok)(ZFDetailNavButtonActionType actionType);

- (UIImage *)fetchGoodsImage;

@end
