//
//  YXRouter.h
//  uSmartOversea
//
//  Created by RuiQuan Dai on 2018/7/2.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YXViewController.h"
#import "YXViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXRouter : NSObject


+ (instancetype)sharedInstance;

/**
 根据viewModel返回viewController

 @param viewModel
 @return vc
 */
- (YXViewController *)viewControllerForViewModel:(YXViewModel *)viewModel;


@end

NS_ASSUME_NONNULL_END
