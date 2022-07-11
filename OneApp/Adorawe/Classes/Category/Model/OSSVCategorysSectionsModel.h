//
//  OSSVCategorysSectionsModel.h
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVCategoryFiltersModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface OSSVCategorysSectionsModel : NSObject

@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *ad_name;
@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, copy) NSString *item_type;
@property (nonatomic, copy) NSString *item_title;
@property (nonatomic, copy) NSString *item_count;
@property (nonatomic, copy) NSString *item_color_code;
@property (nonatomic, copy) NSString *price_max;//是价格栏才有值
@property (nonatomic, copy) NSString *price_min;//是价格栏才有值
@property (nonatomic, strong) NSArray <OSSVCategoryFiltersModel *> *child_item;


@end

NS_ASSUME_NONNULL_END
