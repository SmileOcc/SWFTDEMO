//
//  ZFShareView.h
//  HyPopMenuView
//
//  Created by YW on 6/8/17.
//  Copyright © 2017年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFShareTopView.h"
#import "ZFShareViewDelegate.h"

@class ZFShareButton;

typedef NS_ENUM(NSInteger,ZFShareViewType) {
    /**普通分享*/
    ZFShareViewTypeCommon,
    /**社区个人中心分享标识*/
    ZFShareViewTypeCommunityAccount,
};

@interface ZFShareView : UIView


@property (nonatomic, strong) NSArray<ZFShareButton*> *dataSource;

@property (nonatomic, assign) id<ZFShareViewDelegate> delegate;

@property (nonatomic, assign) ZFShareViewType         viewType;

/**
 *  默认为 10.0f         取值范围: 0.0f ~ 20.0f
 *  default is 10.0f    Range: 0 ~ 20
 */
@property (nonatomic, assign) CGFloat popMenuSpeed;

/**
 *  顶部自定义View
 */
@property (nonatomic, strong) ZFShareTopView *topView;

/**
 *  分享View上部自定义headerView
 */
@property (nonatomic, strong) UIView   *shareHeaderView;

- (void)open;

- (void)dismiss;

@end
