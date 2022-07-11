//
//  OSSVCategorysVirtualListsAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategorysVirtualListsAip.h"

@implementation OSSVCategorysVirtualListsAip{
    NSString *_catName;
    NSString *_relatedId;
    NSString *_type;

    NSInteger _page;
    NSInteger _pageSize;
    NSInteger _orderBy;
}

- (instancetype)initWithCategoriesListCatName:(NSString *)catName
                                         page:(NSInteger)page
                                     pageSize:(NSInteger)pageSize
                                      orderBy:(NSInteger)orderBy
                                   relatedId:(NSString *)relatedId
                                      tpye:(NSString *)type{
    self = [super init];
    if (self)
    {
        _catName = catName;
        _page = page;
        _pageSize = pageSize;
        _orderBy = orderBy;
        _relatedId = relatedId;
        _type = type;
    }
    return self;
}

- (BOOL)enableCache
{
    if (_page == 1)
    {
        return YES;
    }
    return NO;
}

- (BOOL)enableAccessory
{
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy
{
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath
{
    return [OSSVNSStringTool buildRequestPath:kApi_CategoryVirtual];
}

- (id)requestParameters
{
    return @{@"cat_name"     : STLToString(_catName),
             @"page"       : @(_page),
             @"page_size"  : @(_pageSize),
             @"order_by"   : @(_orderBy),
             @"id"   : STLToString(_relatedId),
             @"types"   : STLToString(_type),
             @"commparam"  : [OSSVNSStringTool buildCommparam]
             };
}

- (STLRequestMethod)requestMethod
{
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType
{
    return STLRequestSerializerTypeJSON;
}

@end
