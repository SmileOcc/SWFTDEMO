//
//  ZFMergeRequestManager.h
//  ZZZZZ
//
//  Created by YW on 2019/5/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFMergeRequest;
@interface ZFMergeRequestManager : NSObject

+ (ZFMergeRequestManager *)sharedInstance;

- (void)addBatchRequest:(ZFMergeRequest *)batchRequest;
- (void)removeBatchRequest:(ZFMergeRequest *)batchRequest;

@end

NS_ASSUME_NONNULL_END
