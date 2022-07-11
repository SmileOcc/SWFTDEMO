//
//  YXSecret.m
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2019/9/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXSecret.h"

#include "YXDodmot.h"

@implementation YXSecret
+ (NSString * _Nullable)lDotMotString; {
    return [NSString stringWithUTF8String:lDotMot()];
}
@end
