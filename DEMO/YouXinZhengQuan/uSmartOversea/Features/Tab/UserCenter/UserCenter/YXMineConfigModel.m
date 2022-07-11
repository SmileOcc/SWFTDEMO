//
//  YXMineConfigModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/16.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXMineConfigModel.h"

@implementation YXMineConfigLogModel

@end

@implementation YXMineConfigNameModel

@end

@implementation YXMineConfigElementModel

@end

@implementation YXMineConfigModuleModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"elements": [YXMineConfigElementModel class]};
}



@end

@implementation YXMineConfigModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"modules": [YXMineConfigModuleModel class]};
}



@end
