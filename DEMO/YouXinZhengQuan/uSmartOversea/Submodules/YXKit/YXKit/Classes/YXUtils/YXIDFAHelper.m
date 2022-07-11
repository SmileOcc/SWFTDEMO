//
//  YXIDFAHelper.m
//  Alamofire
//
//  Created by 付迪宇 on 2019/8/23.
//

#import "YXIDFAHelper.h"

@implementation YXIDFAHelper

+ (nullable NSString *)getIDFA {
    NSString *idfa = nil;
    @try {
        Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
        if (ASIdentifierManagerClass) {
            SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
            id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
            SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
            NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
            NSString *temp = [uuid UUIDString];
            // 在 iOS 10.0 以后，当用户开启限制广告跟踪，advertisingIdentifier 的值将是全零
            // 00000000-0000-0000-0000-000000000000
            if (temp && ![temp hasPrefix:@"00000000"]) {
                idfa = temp;
            }
        }
        return idfa;
    } @catch (NSException *exception) {
        return idfa;
    }
}

@end
