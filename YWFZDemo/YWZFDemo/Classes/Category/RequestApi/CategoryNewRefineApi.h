//
//  CategoryRefineApi.h
//  ListPageViewController
//
//  Created by YW on 3/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface CategoryNewRefineApi : SYBaseRequest

- (instancetype)initWithCategoryRefineApiCat_id:(NSString *)cateId attr_version:(NSString *)attr_version;

@end
