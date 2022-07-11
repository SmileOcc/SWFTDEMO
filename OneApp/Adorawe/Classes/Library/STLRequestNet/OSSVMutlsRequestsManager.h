//
//  OSSVMutlsRequestsManager.h
//  STLRequestHeader
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSVMutlsRequest;

@interface OSSVMutlsRequestsManager : NSObject

+ (OSSVMutlsRequestsManager *)sharedInstance;

- (void)addMutlRequest:(OSSVMutlsRequest *)batchRequest;
- (void)removeBatchRequest:(OSSVMutlsRequest *)batchRequest;

@end
