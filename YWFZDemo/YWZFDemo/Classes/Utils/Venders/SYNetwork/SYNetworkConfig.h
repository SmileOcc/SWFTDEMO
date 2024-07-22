//
//  SYNetworkConfig.h
//  SYNetwork
//
//  Created by YW on 16/5/28.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFSecurityPolicy.h"

@interface SYNetworkConfig : NSObject

@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, copy) NSString *communityBaseURL;
@property (nonatomic, assign) NSUInteger maxConcurrentOperationCount;
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

+ (SYNetworkConfig *)sharedInstance;

@end
