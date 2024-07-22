//
//  ZFZegoUtils.m
//  ZZZZZ
//
//  Created by YW on 2019/8/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFZegoUtils.h"

#if TARGET_OS_OSX
#import <IOKit/IOKitLib.h>
#elif TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

NSString* kZFUserIDKey = @"user_id";

@interface ZFZegoUtils ()

@property (class, copy ,nonatomic) NSString *userID;

@end

static NSString *_userID = nil;

@implementation ZFZegoUtils

+ (NSUserDefaults *)myUserDefaults {
    return [[NSUserDefaults alloc] initWithSuiteName:@"group.liveRoomPlayground"];
}

+ (NSString *)userID {
    if (_userID.length == 0) {
        NSUserDefaults *ud = [self myUserDefaults];
        NSString *userID = [ud stringForKey:kZFUserIDKey];
        if (userID.length > 0) {
            _userID = userID;
        }
        else {
            srand((unsigned)time(0));
            userID = [NSString stringWithFormat:@"%u", (unsigned)rand()];
            _userID = userID;
            [ud setObject:userID forKey:kZFUserIDKey];
            [ud synchronize];
        }
    }
    
    return _userID;
}

+ (void)setUserID:(NSString *)userID {
    _userID = userID;
}

#if TARGET_OS_OSX
+ (NSString *)getDeviceUUID {
    io_service_t platformExpert;
    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    if (platformExpert) {
        CFTypeRef serialNumberAsCFString;
        serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, CFSTR("IOPlatformUUID"), kCFAllocatorDefault, 0);
        IOObjectRelease(platformExpert);
        if (serialNumberAsCFString) {
            return (__bridge_transfer NSString*)(serialNumberAsCFString);
        }
    }
    
    return @"hello";
}
#elif TARGET_OS_IOS
+ (NSString *)getDeviceUUID {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}
#endif

@end
