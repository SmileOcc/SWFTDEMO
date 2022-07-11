//
//  YXOptionalDBManager.h
//  uSmartOversea
//
//  Created by ellison on 2018/11/29.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXOptionalSecu.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXOptionalDBManager : NSObject

+ (instancetype)shareInstance;

- (BOOL)insertOrReplaceData:(id<YXSecuProtocol>)secuObject;

- (BOOL)insertOrReplaceDatas:(NSArray<YXOptionalSecu *> *)secus;

- (NSArray<YXOptionalSecu *> *)getDataWithSecus:(NSArray<id<YXSecuIDProtocol>> *)secus;

- (BOOL)updateAllSecuName;

@end

NS_ASSUME_NONNULL_END
