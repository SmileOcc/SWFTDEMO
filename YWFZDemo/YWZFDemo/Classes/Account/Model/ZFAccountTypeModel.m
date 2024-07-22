
//
//  ZFAccountTypeModel.m
//  ZZZZZ
//
//  Created by YW on 2018/5/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAccountTypeModel.h"

@implementation ZFAccountTypeModel
- (instancetype)initWithAccountTypeModel:(ZFAccountTypeModelType)type rowHeight:(CGFloat)rowHeight {
    self = [super init];
    if (self) {
        self.type = type;
        self.rowHeight = rowHeight;
    }
    return self;
}
@end
