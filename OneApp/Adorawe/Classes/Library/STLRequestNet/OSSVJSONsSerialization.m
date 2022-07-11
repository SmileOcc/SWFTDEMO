//
//  OSSVJSONsSerialization.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/8.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVJSONsSerialization.h"

@implementation OSSVJSONsSerialization
+(NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError *__autoreleasing  _Nullable *)error{
    if (!obj) {
        return nil;
    }
    if (@available(iOS 11.0, *)) {
        NSData *data = [super dataWithJSONObject:obj options:NSJSONWritingSortedKeys error:error];
        return data;
    } else {
        return [super dataWithJSONObject:obj options:opt error:error];
    }
}
@end
