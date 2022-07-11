//
//  OSSVCategoryListsAip.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVCategoryListsAip : OSSVBasesRequests

- (instancetype)initWithCategoriesListCatId:(NSString *)catId
                                       page:(NSInteger)page
                                   pageSize:(NSInteger)pageSize
                                    orderBy:(NSInteger)orderBy
                                  filterIDs:(NSString *)filterIDs
                                filterPrice:(NSString *)filterPrice
                                      isNew:(NSString *)isNew;

// 加入deepLinkId；
- (instancetype)initWithCategoriesListCatId:(NSString *)catId
                                       page:(NSInteger)page
                                   pageSize:(NSInteger)pageSize
                                    orderBy:(NSInteger)orderBy
                                  filterIDs:(NSString *)filterIDs
                                filterPrice:(NSString *)filterPrice
                                 deepLinkId:(NSString *)deeplinkId
                                      isNew:(NSString *)isNew;
@end
