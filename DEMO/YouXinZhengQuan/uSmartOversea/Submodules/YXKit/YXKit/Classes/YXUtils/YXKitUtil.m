//
//  YXKitUtil.m
//  YXKit
//
//  Created by 胡华翔 on 2019/09/23.
//

#import "YXKitUtil.h"
#import <YYCategories/YYCategories.h>

@implementation YXKitUtil

+ (NSString * _Nonnull)xTokenGenerateWithXTransId:(NSString * _Nonnull)xTransId xTime:(NSString * _Nonnull)xTime xDt:(NSString * _Nonnull)xDt xDevId:(NSString * _Nonnull)xDevId xUid:(NSString * _Nonnull)xUid xLang:(NSString * _Nonnull)xLang xType:(NSString * _Nonnull)xType xVer:(NSString * _Nonnull)xVer {
    return [[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", xTransId, xTime, xDt, xDevId, xUid, xLang, xType, xVer] md5String];
}

@end
