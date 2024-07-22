//
//  ZFNewUserRushViewController.h
//  ZZZZZ
//
//  Created by mac on 2019/1/10.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//  新人秒杀商品列表页

#import "ZFBaseViewController.h"

typedef void(^footerBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@class YNPageCollectionView;

@interface ZFNewUserRushViewController : ZFBaseViewController

@property (nonatomic, strong) NSArray *dataArray;
/** 活动是否开始 */
@property (nonatomic, assign) BOOL isNotStart;

@property (nonatomic, strong) footerBlock footerBlock;

- (YNPageCollectionView *)querySubScrollView;

@end

NS_ASSUME_NONNULL_END
