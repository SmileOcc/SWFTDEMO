//
//  ZFBannerContentView.h
//  ZFBannerView
//
//  Created by YW on 22/11/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFBannerContentView;

typedef void(^ZFBannerContentViewBlock)(ZFBannerContentView * sender);

@interface ZFBannerContentView : UIView

/**
 图片占位图
 */
@property (nonatomic,strong) UIImage *placeHoldImage;

@property (nonatomic, copy) ZFBannerContentViewBlock   callBack;

- (void)setUserInteraction:(BOOL)enable;

- (void)setContentIMGWithStr:(NSString *)str;

- (void)setOffsetWithFactor:(float)value; //偏移的百分比

@end

NS_ASSUME_NONNULL_END
