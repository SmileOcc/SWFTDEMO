//
//  YXHomeHoldViewController.h
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXHomeHoldViewController : YXTableViewController

@property (nonatomic, assign) BOOL isExpand;
@property (nonatomic, assign) BOOL isHKSectionExpand;
@property (nonatomic, assign) BOOL isUSSectionExpand;
@property (nonatomic, assign) BOOL isSGSectionExpand;
@property (nonatomic, assign) BOOL isUSOptionSectionExpand;
@property (nonatomic, assign) BOOL isUSFractionSectionExpand;


//重置点击展开的状态
- (void)resetExpandState;

@end

NS_ASSUME_NONNULL_END
