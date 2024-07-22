//
//  CategoryRefineModel.h
//  ListPageViewController
//
//  Created by YW on 1/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryRefineDetailModel.h"

@interface CategoryRefineSectionModel : NSObject
@property (nonatomic, strong) NSArray<CategoryRefineDetailModel *>     *refine_list;
@property (nonatomic, copy)   NSString                                 *priceMax;
@property (nonatomic, copy)   NSString                                 *priceMin;

@property (nonatomic, copy) NSString   *selectPriceMin;
@property (nonatomic, copy) NSString   *selectPriceMax;

@end
