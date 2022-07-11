//
//  YXHkVolumnModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/3/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXHkVolumnModel.h"

@implementation YXHkVolumnSubModel

@end


@implementation YXHkVolumnModel

// 声明自定义类参数类型
+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"list" : [YXHkVolumnSubModel class]};
}


@end
