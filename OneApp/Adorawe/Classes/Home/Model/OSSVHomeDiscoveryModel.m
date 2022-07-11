//
//  OSSVHomeDiscoveryModel.m
// OSSVHomeDiscoveryModel
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeDiscoveryModel.h"
#import "OSSVCartGoodsModel.h"
#import "OSSVScrollAdvsConfigsModel.h"

@implementation OSSVHomeDiscoveryModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"bannerArray"     : @"banner",
             @"threeArray"      : @"three",
             @"topicArray"      : @"topic",
             @"blocklist"       : @"blocklist",
             @"goodsList"       : @"goodslist",
             @"newuser"         : @"newuser",
             @"scrollArray"     : @"slide",
             @"secondArray"     : @"second_kill",
             @"exchange"        : @"exchange",
             @"marqueeArray"    : @"marquee",
             @"tabsArray"       : @"tabs",
             @"marqueeArray"    : @"marquee",  //文字跑马灯数据
             @"slideImgArray"   : @"slide_img",
             @"flashSale"       : @"flash_sale",
             @"slide_img_background": @"slide_img_background",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"bannerArray"      : [OSSVAdvsEventsModel class],
             @"threeArray"       : [OSSVAdvsEventsModel class],
             @"topicArray"       : [OSSVAdvsEventsModel class],
             @"newuser"          : [OSSVAdvsEventsModel class],
             @"secondArray"      : [OSSVSecondsKillsModel class],
             @"scrollArray"      : [OSSVSecondsKillsModel class],
             @"index_venue"      : [OSSVHomeCThemeModel class],
             @"exchange"         : [OSSVAdvsEventsModel class],
             @"marqueeArray"     : [OSSVAdvsEventsModel class],
             @"blocklist"        : [OSSVDiscoverBlocksModel class],
             @"tabsArray"        : [STLHomeCThemeChannelModel class],
             @"marqueeArray"     : [OSSVAdvsEventsModel class],
             @"blocklist"        : [OSSVDiscoverBlocksModel class],
             @"slideImgArray"    : [OSSVAdvsEventsModel class],
             @"flashSale"        : [OSSVSecondsKillsModel class],
             @"slide_img_background": [OSSVScrollAdvsConfigsModel class],
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"bannerArray",
             @"listArray",
             @"threeArray",
             @"topicArray",
             @"blocklist",
             @"goodsList",
             @"newuser",
             @"scrollArray",
             @"secondArray",
             @"index_venue",
             @"exchange",
             @"marqueeArray",
             @"tabsArray",
             @"slideImgArray",
             @"flashSale",
             @"slide_img_background",
             ];
}


@end
