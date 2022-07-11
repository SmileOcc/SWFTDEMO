//
//  OSSVRequestsConfigs.h
//  OSSVRequestsConfigs
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFSecurityPolicy.h"

@interface OSSVRequestsConfigs : NSObject

@property (nonatomic, copy) NSString                    *baseURL;
@property (nonatomic, assign) NSUInteger                maxConcurrentOperationCount;
@property (nonatomic, strong) AFSecurityPolicy          *securityPolicy;
@property (nonatomic, assign) BOOL                      uploadResponseJsonToLogSystem;
@property (nonatomic, assign) BOOL                      closeUrlResponsePrintfLog;

+ (OSSVRequestsConfigs *)sharedInstance;

@end
