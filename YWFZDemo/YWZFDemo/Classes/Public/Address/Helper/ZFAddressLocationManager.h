//
//  ZFAddressLocationManager.h
//  ZZZZZ
//
//  Created by YW on 2017/12/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFLocationInfoModel.h"

@interface ZFAddressLocationManager : NSObject

@property (nonatomic, assign) BOOL              isOpenLocation;


+ (instancetype)shareManager;

- (void)parseLocationData:(NSArray<ZFLocationInfoModel *>*)locationArray;

- (NSArray<ZFLocationInfoModel *> *)queryRootLocationData;

- (NSArray<ZFLocationInfoModel *> *)querySubLocationDataWithParentID:(NSString *)parentID;

@end
