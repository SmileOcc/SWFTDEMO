//
//  OSSVReviewsApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVReviewsApi.h"

@implementation OSSVReviewsApi {
    NSString *_sku;
    NSString *_goodsID;
    NSString *_page;
    NSString *_pageSize;
    NSString *_spu;
}

- (instancetype)initWithSKU: (NSString *)sku spu:(NSString *)spu goodsID:(NSString *)goodsID page:(NSString *)page pageSize:(NSString *)pageSize{
    if (self = [super init]) {
        _sku  = sku;
        _page = page;
        _goodsID = goodsID;
        _pageSize = pageSize;
        _spu = STLToString(spu);
    }
    return self;
}

- (BOOL)enableCache {
    if ([_page isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

//- (NSString *)baseURL {
//    return @"http://review.cloudsdlk.com.feature-ios-sign.fpm.testsdlk.com/api/goods/review-list";
//}
//
//- (NSString *)requestPath {
//    return @"";
//}

- (NSDictionary *)requestHeader {
    NSString *timestamp = [OSSVNSStringTool getCurrentTimestamp];
    NSString *paramsToken = [OSSVLocaslHosstManager reviewSystemKey];
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@",@"s",STLToString(paramsToken),timestamp,@"s"];
    NSString *api_sign = [OSSVRequestsUtils md5StringWithString:str];
    return @{@"api-salt":@"s",@"timestamp":timestamp,@"api-sign":api_sign,@"sign-version":@"1"};
}


- (NSString *)requestPath {
    return kApi_ItemGetGoodsCommentNew;
}

-(NSString *)domainPath{
//    return masterDomain;
    return commentDomain;
}


- (id)requestParameters {
    
    NSString *currentLang = [STLLocalizationString shareLocalizable].nomarLocalizable;

    NSString *pageSize = STLIsEmptyString(_pageSize) ? @"20" : _pageSize;
    NSDictionary *data = @{@"sku":STLToString(_sku),
                           @"num":@([pageSize integerValue]),
                           @"page":@([_page integerValue]),
                           @"type":@(0),
                           @"lang":STLToString(currentLang)};
    if (!STLIsEmptyString(_spu)) {
        data = @{@"sku":STLToString(_sku),
                 @"spu":STLToString(_spu),
                 @"num":@([pageSize integerValue]),
                 @"page":@([_page integerValue]),
                 @"type":@(0),
                 @"lang":STLToString(currentLang)};
    }

    NSString *countrSiteCode = [STLWebsitesGroupManager currentCountrySiteCode];
    if (STLIsEmptyString(countrSiteCode)) {
        countrSiteCode = [OSSVLocaslHosstManager appName].lowercaseString;
    }
    NSMutableDictionary *postData = @{@"client": @(1),
                                      @"data":data,
                                      @"lang":STLToString(currentLang),
                               @"site": countrSiteCode,
                               @"version":@"4.5.3",
                               
                               }.mutableCopy;

    
    return  postData;
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}

- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
