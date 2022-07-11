//
//  YXReportTextParser.h
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYText/YYText.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXReportTextParser : NSObject<YYTextParser>

@property (nonatomic, strong) UIFont *font;
//@property (nonatomic, strong) UIFont *highlightFont;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *highlightTextColor;

@property (nonatomic, assign) BOOL editing;

+ (NSRegularExpression *)regexStock;

@end

NS_ASSUME_NONNULL_END
