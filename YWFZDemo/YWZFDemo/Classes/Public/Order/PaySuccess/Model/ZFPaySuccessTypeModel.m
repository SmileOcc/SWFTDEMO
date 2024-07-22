//
//  ZFPaySuccessTypeModel.m
//  ZZZZZ
//
//  Created by YW on 7/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPaySuccessTypeModel.h"

@implementation ZFPaySuccessTypeModel

- (instancetype)initWithPaySuccessModel:(ZFPaySuccessType)type rowCount:(NSInteger)rowCount {
    self = [super init];
    if (self) {
        self.type = type;
        self.rowCount = rowCount;
    }
    return self;
}

@end
