//
//  OSSVDetailsRecommendApi.m
// XStarlinkProject
//
//  Created by odd on 2021/3/24.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailsRecommendApi.h"
@import RangersAppLog;

@implementation OSSVDetailsRecommendApi
{
    NSString *_goodsId;
    NSString *_wid;
    NSString *_specialId;
    NSInteger _page;
    NSInteger _page_size;
    NSString *_is_cart_recommend;
}

- (instancetype)initWithGoodsDetailRecommends:(NSDictionary *)params {
    if (self = [super init]) {
        _goodsId = STLToString(params[@"goods_id"]);
        _wid = STLToString(params[@"wid"]);
        _page = [params[@"page"] integerValue];
        _page_size = [params[@"page_size"] integerValue];
        _is_cart_recommend = STLToString(params[@"is_cart_recommend"]);
        //is_cart_recommend 1 点击推荐商品，不获取推荐商品数据
    }
    return self;
}

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_ItemRecommend];
}

- (id)requestParameters {
    
    NSString *newRecommand_ab = [BDAutoTrack ABTestConfigValueForKey:@"Recommand_Ab" defaultValue:@("")];

    NSMutableDictionary *params = [@{
        @"goods_id" : STLToString(_goodsId),
        @"wid" : STLToString(_wid),
        @"is_cart_recommend":STLToString(_is_cart_recommend),
        @"page_size" : @(20),
        @"page" : @(_page),
        @"commparam" : [OSSVNSStringTool buildCommparam]
    } mutableCopy];

    if (OSSVAccountsManager.sharedManager.sysIniModel.recommend_abtest_switch){
        [params setObject:STLToString(newRecommand_ab) forKey:@"rec_engine"];
    }
    
#if DEBUG
    ///test recommend
//    [params setObject:@"BT" forKey:@"rec_engine"];
#endif
    return params;
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}

/// 请求的SerializerType
- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
