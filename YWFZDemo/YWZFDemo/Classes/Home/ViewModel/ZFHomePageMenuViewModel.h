//
//  ZFHomePageMenuViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/11/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFHomePageMenuModel.h"
#import "BaseViewModel.h"

@class ZFCMSSectionModel, ZFBTSModel;

@interface ZFHomePageMenuViewModel : BaseViewModel

// 主页列表数据源
@property (nonatomic, strong, readonly) NSArray<ZFCMSSectionModel *> *homeSectionModelArr;

@property (nonatomic, strong) ZFBTSModel *homeBtsModel;

/**
 * 请求cms列表数据
 * isCMSMainUrlType-> YES:请求cms主站接口, NO:请求cms备份S3上的数据
 */
- (void)requestHomePageMenuData:(BOOL)isCMSMainUrlType completeHandler:(void (^)(BOOL isSucceess))completeHandler;

- (NSArray <NSString *> *)keys;
- (NSArray <NSString *> *)values;

- (NSArray *)tabMenuTitles;

/**
 * 重置菜单接口数据
 */
- (void)shouldResetMenuData;

@end
