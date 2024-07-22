//
//  BannerModel.m
//  ZZZZZ
//
//  Created by DBP on 16/10/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBannerModel.h"
#import "YWCFunctionTool.h"
#import <YYModel/YYModel.h>
#import "ZFPubilcKeyDefiner.h"

@implementation ZFBannerModel
@synthesize registerClass = _registerClass;

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"banner_height"           : @"height",
             @"banner_width"            : @"width",
             @"deeplink_uri"            : @"url",
             @"community_deeplink_uri"  : @"deeplink_uri"
             };
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init]; return [self yy_modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}


-(NSString *)banner_width{
    if ([_banner_width isEqualToString:@"0"] || _banner_width == nil || ZFIsEmptyString(_banner_width)) {
        return @"150";//防止数据异常
    }
    return _banner_width;
}

-(NSString *)banner_height{
    if ([_banner_height isEqualToString:@"0"] || _banner_height == nil || ZFIsEmptyString(_banner_height)) {
        return @"150";//防止数据异常
    }
    return _banner_height;
}

/**
 * 非服务端返回 ,在请求到数据发现有倒计时定时器时才创建,页面上去接取这个key取对应的定时器
 */
- (NSString *)countDownTimerKey {
    if (!_countDownTimerKey || ZFIsEmptyString(_countDownTimerKey)) {
        return HomeTimerKey;//防止异常
    }
    return _countDownTimerKey;
}

#pragma mark - model protocol

- (NSString *)CollectionDatasourceCell:(NSIndexPath *)indexPath identifier:(id)identifier
{
    return @"ZFAccountBannerCCell";
}

- (Class)registerClass
{
    return NSClassFromString(@"ZFAccountBannerCCell");
}

@end


@implementation ZFNewBannerModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"banners"  :  [ZFBannerModel class],
             };
}

@end
