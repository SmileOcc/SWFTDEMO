//
//  UILabel+create.h
//  uSmartOversea
//
//  Created by RuiQuan Dai on 2018/7/2.
//Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (create)

/**
 快速创建label
 
 @param text text
 @param textColor textColor
 @param textFont textFont
 @return return UILabel
 */
+ (instancetype)labelWithText:(NSString *)text
                 textColor:(UIColor *)textColor
                  textFont:(UIFont *)textFont;



/**
 快速创建label
 
 @param text text
 @param textColor textColor
 @param textFont textFont
 @param textAlignment textAlignment
 @return return UILabel
 */
+ (instancetype)labelWithText:(NSString *)text
                 textColor:(UIColor *)textColor
                  textFont:(UIFont *)textFont
             textAlignment:(NSTextAlignment)textAlignment;

+ (UILabel *)delayLabel;

+ (UILabel *)ipoLabel;

+ (UILabel *)grayLabel;
@end
