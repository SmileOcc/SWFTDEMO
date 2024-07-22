//
//  ZFRegisterCellTypeModel.m
//  ZZZZZ
//
//  Created by YW on 30/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFRegisterCellTypeModel.h"

@implementation ZFRegisterCellTypeModel

- (instancetype)initWithType:(RegisterCellType)type cellHeight:(CGFloat)cellHeight {
    self = [super init];
    if (self) {
        self.type = type;
        self.cellHeight = cellHeight;
    }
    return self;
}

@end
