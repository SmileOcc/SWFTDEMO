//
//  ZFBKManager.h
//  ZZZZZ
//
//  Created by YW on 2019/7/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFRequestModel.h"

@interface ZFBKManager : NSObject <ZFNetworkDelegate>

+ (instancetype)sharedManager;

@end


