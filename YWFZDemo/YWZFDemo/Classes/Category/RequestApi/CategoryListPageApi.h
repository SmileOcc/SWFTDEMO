//
//  CategoryListPageApi.h
//  ListPageViewController
//
//  Created by YW on 23/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface CategoryListPageApi : SYBaseRequest

- (instancetype)initListPageApiWithParameter:(id)parameter virtual:(BOOL)isVirtual;

@end

