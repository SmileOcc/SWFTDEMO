//
//  UILabel+create.m
//  uSmartOversea
//
//  Created by RuiQuan Dai on 2018/7/2.
//Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "UILabel+create.h"
#import <UIColor+YYAdd.h>

@implementation UILabel (create)



+ (instancetype)labelWithText:(NSString *)text textColor:(UIColor *)textColor textFont:(UIFont *)textFont {
    UILabel *label = [[self alloc] init];
    label.text = text;
    label.font = textFont;
    label.textColor = textColor;
    return label;
}

+ (instancetype)labelWithText:(NSString *)text textColor:(UIColor *)textColor textFont:(UIFont *)textFont textAlignment:(NSTextAlignment)textAlignment {
    UILabel *label = [self labelWithText:text textColor:textColor textFont:textFont];
    label.textAlignment = textAlignment;
    return label;
}

+ (UILabel *)delayLabel {
    QMUILabel *delayLabel = [[QMUILabel alloc] init];
    delayLabel.text = @"Delay";
    delayLabel.textColor = [QMUITheme textColorLevel3];
    delayLabel.font = [UIFont systemFontOfSize:8];
    delayLabel.layer.cornerRadius = 2;
    delayLabel.layer.borderWidth = 0.5;
    delayLabel.layer.borderColor = [QMUITheme textColorLevel3].CGColor;
    delayLabel.layer.masksToBounds = YES;
    delayLabel.contentEdgeInsets = UIEdgeInsetsMake(1, 2, 1, 2);
    
    return delayLabel;
}

+ (UILabel *)ipoLabel {
    QMUILabel *label = [[QMUILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithHexString:@"#C1901B"];
    label.layer.borderWidth = 0.5;
    label.layer.borderColor = [UIColor colorWithHexString:@"#C1901B"].CGColor;
    label.font = [UIFont systemFontOfSize:10];
    label.layer.cornerRadius = 1.0;
    label.layer.masksToBounds = true;
    label.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    
    return label;
}

+ (UILabel *)grayLabel {
    QMUILabel *label = [[QMUILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.layer.borderWidth = 0.5;
    label.backgroundColor = [[UIColor colorWithHexString:@"#FF7127"] colorWithAlphaComponent:0.8];
    label.layer.borderColor = [[UIColor colorWithHexString:@"#FF7127"] colorWithAlphaComponent:0.8].CGColor;
    label.font = [UIFont systemFontOfSize:9];
    label.layer.cornerRadius = 2.0;
    label.layer.masksToBounds = true;
    label.adjustsFontSizeToFitWidth = true;
    label.minimumScaleFactor = 0.3;
    label.numberOfLines = 2;
    label.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    
    return label;
}
@end
