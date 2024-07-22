//
//  ZFOrderDetailStructModel.m
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDetailStructModel.h"

@interface ZFOrderDetailStructModel()
@property (nonatomic, assign) ZFOrderDetailStructType           type;
@property (nonatomic, assign) NSInteger                         cellsCount;
@end

@implementation ZFOrderDetailStructModel
#pragma mark - init methods
- (instancetype)initWithType:(ZFOrderDetailStructType)type cellsCount:(NSInteger)cellsCount {
    self = [super init];
    if (self) {
        self.type = type;
        self.cellsCount = cellsCount;
    }
    return self;
}
@end
