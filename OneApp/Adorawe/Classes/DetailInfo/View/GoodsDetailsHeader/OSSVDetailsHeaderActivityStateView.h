//
//  OSSVDetailsHeaderActivityStateView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GoodsDetailsHeaderActivityNormalView;
@class GoodsDetailsHeaderActivityVeritcalView;

typedef NS_ENUM(NSInteger, STLActivityStyle) {
    STLActivityStyleNormal = 0,
    STLActivityStyleFlashSale = 1,
};

typedef NS_ENUM(NSInteger, STLActivityDirectStyle) {
    STLActivityDirectStyleNormal = 0,//高度30
    STLActivityDirectStyleVertical = 1,//高度36
};

@interface OSSVDetailsHeaderActivityStateView : UIView


@property (nonatomic, assign) STLActivityDirectStyle               directStyle;
@property (nonatomic, assign) STLActivityStyle                     activityStyle;
@property (nonatomic, strong) GoodsDetailsHeaderActivityNormalView *activityNormalView;
@property (nonatomic, strong) GoodsDetailsHeaderActivityVeritcalView *activityVerticalView;

@property (nonatomic, assign) NSInteger  fontSize;
@property (nonatomic, assign) NSInteger  flashImageSize;
@property (nonatomic, assign) BOOL       samllImageShow;

- (instancetype)initWithFrame:(CGRect)frame showDirect:(STLActivityDirectStyle)direct;
- (void)updateState:(STLActivityStyle )state discount:(NSString *)discountStr;
@end



@interface GoodsDetailsHeaderActivityNormalView : UIView

/** 打折标识*/
@property (nonatomic, strong) UILabel          *discountLabel;
@property (nonatomic, strong) UIImageView           *flashSaleImgView;
@property (nonatomic, assign) NSInteger  fontSize;
@property (nonatomic, assign) NSInteger  flashImageSize;
@property (nonatomic, assign) BOOL       samllImageShow;

- (void)updateState:(STLActivityStyle )state discount:(NSString *)discountStr;

@end



@interface GoodsDetailsHeaderActivityVeritcalView : UIView

/** 打折标识*/
@property (nonatomic, strong) UILabel          *discountLabel;
@property (nonatomic, strong) UIImageView           *flashSaleImgView;
@property (nonatomic, assign) NSInteger  fontSize;
@property (nonatomic, assign) NSInteger  flashImageSize;
@property (nonatomic, assign) BOOL       samllImageShow;
- (void)updateState:(STLActivityStyle )state discount:(NSString *)discountStr;

@end
