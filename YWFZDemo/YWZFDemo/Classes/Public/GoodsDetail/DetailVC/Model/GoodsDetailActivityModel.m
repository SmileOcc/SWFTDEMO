//
//  GoodsDetailActivityModel.m
//  ZZZZZ
//
//  Created by YW on 15/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "GoodsDetailActivityModel.h"
#import "YYText.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"

@implementation GoodsDetailActivityModel

- (NSAttributedString *)flashingTotalText {
    if (!_flashingTotalText) {
        NSString *countString = ZFToString(self.total);
        NSString *flashingString = [NSString stringWithFormat:ZFLocalizedString(@"Detail_Only_count_left", nil), countString];
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        NSRange range = [flashingString rangeOfString:countString];

        NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] initWithString:flashingString];
        titleAttribute.yy_font = [UIFont systemFontOfSize:12];
        [titleAttribute yy_setFont:font range:range];
        _flashingTotalText = titleAttribute;
    }
    return _flashingTotalText;
}

@end
