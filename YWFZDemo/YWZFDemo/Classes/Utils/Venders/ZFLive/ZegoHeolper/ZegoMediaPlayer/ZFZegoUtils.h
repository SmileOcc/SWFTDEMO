//
//  ZFZegoUtils.h
//  ZZZZZ
//
//  Created by YW on 2019/8/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFZegoUtils : NSObject

@property (class, copy ,nonatomic, readonly) NSString *userID;

+ (NSString *)getDeviceUUID;
@end

NS_ASSUME_NONNULL_END
