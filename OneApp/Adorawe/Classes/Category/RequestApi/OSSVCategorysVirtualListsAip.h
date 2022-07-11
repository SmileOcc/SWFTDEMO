//
//  OSSVCategorysVirtualListsAip.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVCategorysVirtualListsAip : OSSVBasesRequests

- (instancetype)initWithCategoriesListCatName:(NSString *)catName
                                         page:(NSInteger)page
                                     pageSize:(NSInteger)pageSize
                                      orderBy:(NSInteger)orderBy
                                   relatedId:(NSString *)relatedId
                                      tpye:(NSString *)type;
@end
