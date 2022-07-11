//
//  YXKlineAccessoryShadeView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2021/3/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YXKlineAccessoryShadeType) {
    YXKlineAccessoryShadeTypeUnsupport = 0,
    YXKlineAccessoryShadeTypeLogin = 1,
    YXKlineAccessoryShadeTypeUpdate = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface YXKlineAccessoryShadeView : UIView

@property (nonatomic, assign) YXKlineAccessoryShadeType status;

- (instancetype)initWithFrame:(CGRect)frame andStatus: (YXKlineAccessoryShadeType)status;

@end

NS_ASSUME_NONNULL_END
