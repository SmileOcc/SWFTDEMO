//
//  OSSVChainsRequestsManager.h
//  STLRequestHeader
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSVChainsRequest;

@interface OSSVChainsRequestsManager : NSObject

+ (OSSVChainsRequestsManager *)sharedInstance;

- (void)addChainRequest:(OSSVChainsRequest *)chainRequest;
- (void)removeChainRequest:(OSSVChainsRequest *)chainRequest;

@end
