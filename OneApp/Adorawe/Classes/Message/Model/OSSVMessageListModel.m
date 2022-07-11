//
//  OSSVMessageListModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageListModel.h"

@implementation OSSVMessageListModel

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"bubbles" : [OSSVMessageModel class] };
}

@end
