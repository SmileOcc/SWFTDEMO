//
//  YXStockFilterGroupViewModel.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockFilterGroupViewModel.h"

@implementation YXStockFilterGroupViewModel
- (void)initialize {
    [super initialize];

    if(self.params[@"market"] != nil) {
        self.market = self.params[@"market"];
    } else {
        self.market = @"";
    }

}


@end
