//
//  STLNetworkStateManager.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RealReachability.h"

@interface STLNetworkStateManager : NSObject <UIAlertViewDelegate>

@property (nonatomic, assign) ReachabilityStatus curStatus;

+ (STLNetworkStateManager *)sharedManager;

//- (void)networkStateCheck:(void (^)())executeBlock exception:(void (^)())exceptionBlock ;
- (void)networkState:(void (^)())executeBlock exception:(void (^)())exceptionBlock;
@end
