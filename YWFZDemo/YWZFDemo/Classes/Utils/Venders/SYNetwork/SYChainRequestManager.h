//
//  SYChainRequestManager.h
//  SYNetwork
//
//  Created by YW on 16/5/28.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYChainRequest;

@interface SYChainRequestManager : NSObject

+ (SYChainRequestManager *)sharedInstance;

- (void)addChainRequest:(SYChainRequest *)chainRequest;
- (void)removeChainRequest:(SYChainRequest *)chainRequest;

@end
