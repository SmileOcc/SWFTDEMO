//
//  YXNewsTimeLineModel.m
//  LIne
//
//  Created by Kelvin on 2019/4/4.
//  Copyright © 2019年 Kelvin. All rights reserved.
//

#import "YXTimeLineModel.h"

@implementation YXTimeLineSingleModel


@end

@implementation YXTimeLineModel

+ (NSDictionary *)modelContainerPropertyGenericClass{
    
    return @{@"list": [YXTimeLineSingleModel class]};
    
}

@end
