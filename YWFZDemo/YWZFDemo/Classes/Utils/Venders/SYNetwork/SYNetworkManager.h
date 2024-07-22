//
//  SYNetworkManager.h
//  SYNetwork
//
//  Created by Sunnyyoung on 16/3/21.
//  Copyright © 2016年 Sunnyyoung. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SYBaseRequest;

@interface SYNetworkManager : NSObject

+ (SYNetworkManager *)sharedInstance;

- (void)addRequest:(SYBaseRequest *)request;
- (void)removeRequest:(SYBaseRequest *)request completion:(void (^)(void))completion;
- (void)removeAllRequest;

@end
