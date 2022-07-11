//
//  YXNetworkUtil.h
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2019/1/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLNetWorkReachability.h"

NS_ASSUME_NONNULL_BEGIN
@interface YXNetworkUtil : NSObject
@property (nonatomic, strong) HLNetWorkReachability *reachability;

+ (instancetype)sharedInstance;

- (void)startReachabilityNotifier;
- (void)stopReachabilityNotifier;
- (NSString *)networkType;
+ (NSString *)operatorInfomation;
@end

NS_ASSUME_NONNULL_END
