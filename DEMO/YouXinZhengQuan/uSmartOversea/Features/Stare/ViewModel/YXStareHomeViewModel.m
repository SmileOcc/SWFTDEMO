//
//  YXStareHomeViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStareHomeViewModel.h"
#import "NSDictionary+Category.h"
#import "uSmartOversea-Swift.h"
#import "YXStareUtility.h"

@implementation YXStareHomeViewModel

- (void)initialize {
    
    NSString *market = [self.params yx_stringValueForKey:@"market"];

    if ([market isEqualToString:@"hk"]) {
        self.type = 0;
    } else if ([market isEqualToString:@"us"]) {
        self.type = 1;
    } else if ([market isEqualToString:@"hs"]) {
        self.type = 2;
    } else {
        self.type = 3;
    }

    YXSecuGroup *selfGroup = [[YXSecuGroupManager shareInstance] allSecuGroup];
    YXSecuGroup *holdGroup = [[YXSecuGroupManager shareInstance] holdSecuGroup];
    if (selfGroup.list.count > 0 || holdGroup.list.count > 0) {
        self.type = 3;
        if (selfGroup.list.count > 0) {
            [YXStareUtility resetHoldSubType: 0];
        } else {
            [YXStareUtility resetHoldSubType: 1];
        }
    } else {
        [YXStareUtility resetHoldSubType:0];
    }

}

@end
