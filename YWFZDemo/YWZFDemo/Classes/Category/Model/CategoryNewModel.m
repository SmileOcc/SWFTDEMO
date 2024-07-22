//
//  CategoryNewModel.m
//  ListPageViewController
//
//  Created by YW on 26/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryNewModel.h"
#import "NSDictionary+SafeAccess.h"

@implementation CategoryNewModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self yy_modelInitWithCoder:aDecoder];
}

+ (instancetype)instanceWithDic:(NSDictionary *)dic {
    CategoryNewModel *model = [CategoryNewModel new];

    model.cat_id       = [dic ds_stringForKey:@"cat_id"];
    model.cat_name     = [dic ds_stringForKey:@"cat_name"];
    model.cat_pic      = [dic ds_stringForKey:@"cat_pic"];
    model.default_sort = [dic ds_stringForKey:@"default_sort"];
    model.is_child     = [dic ds_stringForKey:@"is_child"];
    model.parent_id    = [dic ds_stringForKey:@"parent_id"];
    
    return model;
}

- (id)copyWithZone:(NSZone *)zone {
    CategoryNewModel * model = [[CategoryNewModel allocWithZone:zone] init];
    model.cat_id       = self.cat_id;//self是被copy的对象
    model.cat_name     = self.cat_name;
    model.cat_pic      = self.cat_pic;
    model.default_sort = self.default_sort;
    model.is_child     = self.is_child;
    model.parent_id    = self.parent_id;
    model.isOpen     = self.isOpen;
    model.isSelect    = self.isSelect;
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    CategoryNewModel * model = [[CategoryNewModel allocWithZone:zone] init];
    model.cat_id       = self.cat_id;//self是被copy的对象
    model.cat_name     = self.cat_name;
    model.cat_pic      = self.cat_pic;
    model.default_sort = self.default_sort;
    model.is_child     = self.is_child;
    model.parent_id    = self.parent_id;
    model.isOpen     = self.isOpen;
    model.isSelect    = self.isSelect;
    return model;
}

- (NSString *)is_child {
    if (_childrenList.count > 0) {
        _is_child = @"1";
    }
    return _is_child;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"childrenList" : [CategoryNewModel class]
            };
}

@end
