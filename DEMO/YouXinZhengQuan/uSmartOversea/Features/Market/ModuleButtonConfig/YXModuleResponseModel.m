//
//  YXModuleResponseModel.m
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2021/4/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXModuleResponseModel.h"

@implementation YXModuleResponseModel
+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"appModuleVOS": [YXModuleModel class]};
}

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"appModuleVOS": @"data.appModuleVOS",
             };
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return [self isEqual:object];
}

@end

@implementation YXModuleModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"moduleName": @"moduleName",
             @"icon": @"icon",
             @"jumpMethod": @"jumpMethod",
             @"jumpAddress": @"jumpAddress",
             };
}
@end
