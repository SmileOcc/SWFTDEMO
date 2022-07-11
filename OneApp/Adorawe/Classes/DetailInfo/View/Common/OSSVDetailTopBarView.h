//
//  GoodsDetailTopView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"
#import "SDCycleScrollView.h"
#import "Adorawe-Swift.h"

@class GoodsDetailTopBarEventView;

typedef NS_ENUM(NSInteger, GoodsDetailTopBarEvent){
    GoodsDetailTopBarEventBack = 0,
    GoodsDetailTopBarEventCart,
    GoodsDetailTopBarEventMore
};

@protocol OSSVDetailTopBarViewDelegate<NSObject>

- (void)OSSVDetailTopBarViewEvent:(GoodsDetailTopBarEvent)topEvent;

@end;

@interface OSSVDetailTopBarView : UIView

@property (nonatomic, weak) id<OSSVDetailTopBarViewDelegate> delegate;

@property (nonatomic, strong) GoodsDetailTopBarEventView      *eventView;
@property (nonatomic, strong) GoodsDetailTopBarEventView      *grayEvent;
@property (nonatomic, assign) NSInteger                       cartNumber;

@property (nonatomic, strong) YYAnimatedImageView    *imgView;
@property (nonatomic, copy)   NSString               *imgUrl;
@property (nonatomic, strong) UIView                 *cartPositionView;
@property (nonatomic, strong) MyLottieView           *cartAnimateView;
@property (nonatomic, strong) JSBadgeView            *badgeView;


- (void)updateItemAlpha:(CGFloat)alpha;

- (void)playCartAnimate:(BOOL)play;

@end


@interface GoodsDetailTopBarEventView : UIView <SDCycleScrollViewDelegate>
@property (nonatomic, strong) UIView                 *bottomLineView;
@property (nonatomic, strong) UIButton               *backButton;
@property (nonatomic, strong) UIButton               *cartButton;
@property (nonatomic, strong) UIButton               *moreButton;
@property (nonatomic, strong) JSBadgeView            *badgeView;
@property (nonatomic, strong) UIView                 *searchBgView;
@property (nonatomic, strong) UIImageView            *searchImageView;
@property (nonatomic, strong) SDCycleScrollView      *searchScrollView;
@property (nonatomic, copy)   NSArray                *hotWordsArray;
@property (nonatomic, strong) NSMutableArray         *titleArary;
@property (nonatomic, strong) UITextField             *inputField;

@property (nonatomic, copy) void (^eventBlock)(NSInteger tag);
@property (nonatomic, copy) void (^searchBlock)(NSString *searchKey);
@end

