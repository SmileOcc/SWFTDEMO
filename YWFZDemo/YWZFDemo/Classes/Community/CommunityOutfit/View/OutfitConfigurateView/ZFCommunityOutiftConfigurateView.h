//
//  ZFCommunityOutiftConfigurateView.h
//  ZZZZZ
//
//  Created by YW on 2019/2/28.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityOutiftConfigurateGoodsView.h"
#import "ZFCommunityOutiftConfigurateBordersView.h"
#import "ZFCommunityOutfitBorderModel.h"

typedef NS_ENUM(NSUInteger, OutiftConfigurateAlterState) {
    OutiftConfigurateAlterStateDown,
    OutiftConfigurateAlterStateUP,
};

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityOutiftConfigurateView : UIView

@property (nonatomic, strong) ZFCommunityOutiftConfigurateGoodsView *configureGoodsView;
@property (nonatomic, strong) ZFCommunityOutiftConfigurateBordersView *configureBordersView;
@property (nonatomic, assign) OutiftConfigurateAlterState alterState;

@property (nonatomic, copy) void (^tapShowBlock)(BOOL isShow);
@property (nonatomic, copy) void (^selectGoodsBlock)(ZFGoodsModel *goodModel);
@property (nonatomic, copy) void (^selectBorderBlock)(ZFCommunityOutfitBorderModel *borderModel);



/**
 触发按钮事件
 */
- (void)actionShow;

/**
 显示与隐藏事件
 */
- (void)updateContentView:(BOOL)isShow;

/**
 两边半透明背景半透明
 */
- (void)updateTopMarkAlppa:(CGFloat)alpha;


/**
 底部选择菜单事件
 */
- (void)selectBottomMenuIndex:(NSInteger)index;

- (void)hideRefineView;
@end

NS_ASSUME_NONNULL_END
