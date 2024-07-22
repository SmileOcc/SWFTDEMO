//
//  ZFRRPTools.m
//  ZZZZZ
//
//  Created by YW on 2019/10/15.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFRRPTools.h"
#import <UIKit/UIKit.h>
#import "ExchangeManager.h"
#import "AccountManager.h"
#import "YWCFunctionTool.h"
#import "ZFThemeManager.h"

@implementation ZFRRPTools

+ (ZFRRPModel *)gainZFRRPAttributedString:(NSString *)price marketPrice:(NSString *)marketPrice
{
    NSString *shopPrice = [ExchangeManager transforPrice:price];
    NSString *marketP = [ExchangeManager transforPrice:marketPrice];
    NSString *RRP = ZFToString([AccountManager sharedManager].initializeModel.rrp);
    NSString *line = @"#WR#";
    
    CGFloat cellMargin = 12.0f + 12.0f + 12.0f;
    CGFloat cellWidth = ([UIScreen mainScreen].bounds.size.width - cellMargin) / 2;
    
    if (!RRP.length) {
        RRP = @"";
        line = @" ";
        marketP = marketPrice;
    }

    NSString *text = [NSString stringWithFormat:@"%@%@%@ %@", shopPrice, line, RRP, marketP];
    
    NSMutableAttributedString *muteAttriString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSRange priceRange = [muteAttriString.string rangeOfString:shopPrice];
    [muteAttriString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
                                     NSForegroundColorAttributeName : ZFC0xFE5269()}
                             range:priceRange];
    
    NSRange marketRange = [muteAttriString.string rangeOfString:marketP];
    [muteAttriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],
                                     NSForegroundColorAttributeName : ZFC0x999999(),
                                     NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle],
                                     NSBaselineOffsetAttributeName:@(0)}
                             range:marketRange];
    
    NSRange RRPRange = [muteAttriString.string rangeOfString:RRP];
    [muteAttriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],
                                     NSForegroundColorAttributeName : ZFC0x999999()}
                             range:RRPRange];
    
    CGFloat width = [muteAttriString boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesFontLeading context:nil].size.width;
    BOOL needWrapLine = (width > cellWidth);
    
    NSRange wrapRange = [muteAttriString.string rangeOfString:line];
    
    ZFRRPModel *rrpModel = [[ZFRRPModel alloc] init];
    
    if (needWrapLine) {
        [muteAttriString replaceCharactersInRange:wrapRange withString:@"\n"];
        rrpModel.needWarp = YES;
    } else {
        [muteAttriString replaceCharactersInRange:wrapRange withString:@" "];
        rrpModel.needWarp = NO;
    }
    rrpModel.rrpString = muteAttriString;
    return rrpModel;
}

@end

@implementation ZFRRPModel

@end
