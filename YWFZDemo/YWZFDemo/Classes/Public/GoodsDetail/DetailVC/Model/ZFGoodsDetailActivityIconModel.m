//
//  ZFGoodsDetailActivityIconModel.m
//  ZZZZZ
//
//  Created by YW on 11/7/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsDetailActivityIconModel.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"

@implementation ZFGoodsDetailActivityIconModel

- (NSString *)height {
    if ([_height isEqualToString:@"0"] || _height == nil || ZFIsEmptyString(_height)) {
        return @"52";//防止数据异常,默认高度52
    }
    return _height;
}

- (NSString *)width {
    if ([_width isEqualToString:@"0"] || _width == nil || ZFIsEmptyString(_width)) {
        return [NSString stringWithFormat:@"%.2f",KScreenWidth];//防止数据异常
    }
    return _width;
}

@end
