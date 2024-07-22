//
//  ZFMergeRequestManager.h
//  ZZZZZ
//
//  Created by YW on 2019/3/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  ZF 合并请求管理工具

#import <Foundation/Foundation.h>
#import "ZFRequestModel.h"

typedef void(^complation)(NSDictionary<NSString *, NSDictionary *> *mergeSuccessResult, NSDictionary<NSString *, NSDictionary *> *mergeFailResult, NSError *error);

@interface ZFMergeRequest : NSObject

- (void)addRequest:(ZFRequestModel *)requestModel;

- (void)addRequestList:(NSArray<ZFRequestModel *> *)requestModelList;

- (void)startRequest;

- (void)requestResult:(complation)result;

@end
