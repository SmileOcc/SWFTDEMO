//
//  YXKlineSubIndexViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXKlineSubIndexViewModel.h"
#import "YXKLineConfigManager.h"
#import "YXStockConfig.h"

@implementation YXKlineSubIndexViewModel

- (void)initialize{

    NSNumber *number = self.params[@"indexType"];
    self.indexType = number.integerValue;
    [self resetData];
}

- (void)resetData {
    YXKlineSettingModel *model = [[YXKLineConfigManager shareInstance] getSettingModelWithType:self.indexType];
    self.model = model;
    if (self.indexType == YXStockMainAcessoryStatusMA || self.indexType == YXStockSubAccessoryStatus_MAVOL) {
        self.dataSource = @[model.firstArr, @[]];
    } else {
        self.dataSource = @[model.firstArr, model.secondArr, @[]];
    }
}

@end
