//
//  YXReminderModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXReminderModel.h"
#import "uSmartOversea-Swift.h"

@implementation YXReminderModel

- (void)setNotifyType:(int)notifyType {
    _notifyType = notifyType;
    if (notifyType == 1) {
        self.notifyStr = [YXLanguageUtility kLangWithKey:@"remind_once"];
    } else if (notifyType == 2) {
        self.notifyStr = [YXLanguageUtility kLangWithKey:@"remind_everyday"];
    } else if (notifyType == 3) {
        self.notifyStr = [YXLanguageUtility kLangWithKey:@"remind_keeping"];
    }
}

@end


@implementation YXReminderListModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"stockForms": [YXReminderModel class],
             @"stockNtfs": [YXReminderModel class]
    };
}

#pragma YXAuthorityReminderToolGroupingDelegate
- (NSString *)getMarketType {
    return self.stockMarket;
}

- (NSString *)getSymbol {
    return self.stockCode;
}

@end
