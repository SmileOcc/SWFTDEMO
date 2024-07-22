//
//  ZFRRPLabel.m
//  ZZZZZ
//
//  Created by YW on 2019/8/28.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFRRPLabel.h"
#import "AccountManager.h"
#import "YWCFunctionTool.h"

@implementation ZFRRPLabel

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    NSString *RRP = [AccountManager sharedManager].initializeModel.rrp;
    
    if (attributedText && !ZFIsEmptyString(RRP)) {
        RRP = [NSString stringWithFormat:@"%@ ", RRP];
        NSMutableAttributedString *mutAttributedString = [[NSMutableAttributedString alloc] initWithString:RRP];
        
        NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
        attrDict[NSFontAttributeName] = self.font;
        if ([self.RRPColor isKindOfClass:[UIColor class]]) {
            attrDict[NSForegroundColorAttributeName] = self.RRPColor;
        }
        [mutAttributedString addAttributes:attrDict range:NSMakeRange(0, RRP.length)];
        [mutAttributedString appendAttributedString:attributedText];
        attributedText = mutAttributedString.copy;
    }
    
    [super setAttributedText:attributedText];
}

@end
