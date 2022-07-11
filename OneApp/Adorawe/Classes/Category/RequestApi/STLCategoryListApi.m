//
//  OSSVCategoryListsAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategoryListsAip.h"

@implementation OSSVCategoryListsAip{
    NSString *_catId;
    NSInteger _page;
    NSInteger _pageSize;
    NSInteger _orderBy;
    NSString  *_filterIDString;
    NSString  *_filterPriceString;
    NSString *_deepLinkId;
    NSString *_isNewIN;
}

- (instancetype)initWithCategoriesListCatId:(NSString *)catId
                                       page:(NSInteger)page
                                   pageSize:(NSInteger)pageSize
                                    orderBy:(NSInteger)orderBy
                                  filterIDs:(NSString *)filterIDs
                                filterPrice:(NSString *)filterPrice
                                      isNew:(NSString *)isNew{
    self = [super init];
    if (self)
    {
        _catId    = catId;
        _page     = page;
        _pageSize = pageSize;
        _orderBy  = orderBy;
        _filterIDString    = filterIDs;
        _filterPriceString = filterPrice;
        _isNewIN = isNew;
    }
    return self;
}

- (instancetype)initWithCategoriesListCatId:(NSString *)catId
                                       page:(NSInteger)page
                                   pageSize:(NSInteger)pageSize
                                    orderBy:(NSInteger)orderBy
                                  filterIDs:(NSString *)filterIDs
                                filterPrice:(NSString *)filterPrice
                                 deepLinkId:(NSString *)deeplinkId
                                      isNew:(NSString *)isNew{
    self = [super init];
    if (self)
    {
        _catId    = catId;
        _page     = page;
        _pageSize = pageSize;
        _orderBy  = orderBy;
        _filterIDString    = filterIDs;
        _filterPriceString = filterPrice;
        _deepLinkId = deeplinkId;
        _isNewIN = isNew;
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
    return [NSStringTool buildRequestPath:kApi_CategorySearch];
}

- (id)requestParameters
{
    return @{
             @"cat_id"     : STLToString(_catId),
             @"page"       : @(_page),
             @"page_size"  : @(_pageSize),
             @"order_by"   : @(_orderBy),
             @"commparam"  : [NSStringTool buildCommparam],
             @"filter": _filterIDString ? _filterIDString : @{},
             @"price": STLToString(_filterPriceString),
             @"deep_link_id":STLToString(_deepLinkId),
             @"is_newin": STLToString(_isNewIN),
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
