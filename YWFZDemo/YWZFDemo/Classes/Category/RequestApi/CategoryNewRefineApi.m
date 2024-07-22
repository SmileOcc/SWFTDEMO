//
//  CategoryRefineApi.m
//  ListPageViewController
//
//  Created by YW on 3/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryNewRefineApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation CategoryNewRefineApi {
    NSString *_cat_id;
    NSString *_attr_version;

}

- (instancetype)initWithCategoryRefineApiCat_id:(NSString *)cateId attr_version:(NSString *)attr_version {
    self = [super init];
    if (self) {
        _cat_id = cateId;
        _attr_version = attr_version;
    }
    return  self;
}

- (BOOL)enableCache {
    return YES;
}

- (BOOL)enableAccessory {
    return YES;
}

-(BOOL)encryption {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return ENCPATH;
}

- (id)requestParameters {
    return @{
             @"action"      :   @"category/get_attr_list",
             @"cat_id"      :   [NSStringUtils emptyStringReplaceNSNull:_cat_id],
             @"attr_version":   [NSStringUtils emptyStringReplaceNSNull:_attr_version],
             @"is_enc"      :   @"0"
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
