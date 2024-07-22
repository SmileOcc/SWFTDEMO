

//
//  ZFMyOrderListEmptyFooterView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFMyOrderListEmptyFooterView.h"
#import "ZFThemeManager.h"

@interface ZFMyOrderListEmptyFooterView()

@end

@implementation ZFMyOrderListEmptyFooterView
#pragma mark - init methods
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = ZFCOLOR(239, 239, 239, 1.f);
    }
    return self;
}

@end
