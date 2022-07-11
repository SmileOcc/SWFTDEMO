//
//  YXMarginAssetsViewModel.m
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2020/3/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXMarginAssetsViewModel.h"

@implementation YXMarginAssetsViewModel

- (void)initialize {
    self.title = @"保证金账户";
}

- (void)setExchangeType:(NSInteger)exchangeType {
    _exchangeType = exchangeType;
    
    if (exchangeType == 0) {
        self.title = @"港股保证金账户";
    } else if (exchangeType == 5) {
        self.title = @"美股保证金账户";
    }
}

@end
