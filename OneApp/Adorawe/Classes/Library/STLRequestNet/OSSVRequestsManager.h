//
//  OSSVRequestsManager.h
//  OSSVRequestsManager
//
//  Created by Sunnyyoung on 16/3/21.
//  Copyright © 2016年 Sunnyyoung. All rights reserved.
//

#import <Foundation/Foundation.h>


@class OSSVBasesRequests;

@interface OSSVRequestsManager : NSObject

+ (OSSVRequestsManager *)sharedInstance;

- (void)addRequest:(OSSVBasesRequests *)request;
- (void)removeRequest:(OSSVBasesRequests *)request completion:(void (^)())completion;
- (void)removeAllRequest;


@end
