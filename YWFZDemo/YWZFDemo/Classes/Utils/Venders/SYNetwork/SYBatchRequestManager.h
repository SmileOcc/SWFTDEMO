//
//  SYBatchRequestManager.h
//  SYNetwork
//
//  Created by YW on 16/5/28.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYBatchRequest;

@interface SYBatchRequestManager : NSObject

+ (SYBatchRequestManager *)sharedInstance;

- (void)addBatchRequest:(SYBatchRequest *)batchRequest;
- (void)removeBatchRequest:(SYBatchRequest *)batchRequest;

@end
