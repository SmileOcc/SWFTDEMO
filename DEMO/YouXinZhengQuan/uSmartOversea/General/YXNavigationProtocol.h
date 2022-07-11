//
//  YXNavigationProtocol.h
//  uSmartOversea
//
//  Created by RuiQuan Dai on 2018/7/3.
//Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXViewModel.h"
typedef void (^VoidBlock)(void);



/**
 跳转协议
 */
@protocol YXNavigationProtocol <NSObject>



- (void)pushViewModel:(YXViewModel * _Nonnull)viewModel animated:(BOOL)animated;


- (void)popViewModelAnimated:(BOOL)animated;


- (void)popToViewModel:(YXViewModel * _Nonnull)viewModel animated:(BOOL)animated;


- (void)popToRootViewModelAnimated:(BOOL)animated;


- (void)presentViewModel:(YXViewModel * _Nonnull)viewModel animated:(BOOL)animated completion:(VoidBlock _Nullable)completion;


- (void)dismissViewModelAnimated:(BOOL)animated completion:(VoidBlock _Nullable)completion;


- (void)resetRootViewModel:(YXViewModel * _Nonnull)viewModel;


@end
