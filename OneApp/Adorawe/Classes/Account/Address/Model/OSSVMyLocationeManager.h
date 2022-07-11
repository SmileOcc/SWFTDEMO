//
//  OSSVMyLocationeManager.h
// XStarlinkProject
//
//  Created by Kevin on 2021/9/6.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface OSSVMyLocationeManager : NSObject
/// 开始定位
+ (void)startLocation:(void(^)(CLLocation *location))success address:(void(^)(NSString *addressString))addressString failure:(void(^)(CLAuthorizationStatus status, NSError *error))failure;

/// 结束定位
+ (void)stopLocation;

@end

