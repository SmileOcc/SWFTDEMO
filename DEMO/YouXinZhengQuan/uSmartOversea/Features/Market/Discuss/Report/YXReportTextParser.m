//
//  YXReportTextParser.m
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXReportTextParser.h"


@implementation YXReportTextParser

+ (NSRegularExpression *)regexStock {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\$[^\u3000]+?\\([-.+*a-zA-Z0-9]+?\\.[a-zA-Z]{2,8}\\)\\$" options:kNilOptions error:NULL];
    });
    return regex;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.font = [UIFont systemFontOfSize:16];
//        self.highlightFont = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        self.color = QMUITheme.textColorLevel1;
        self.highlightTextColor = QMUITheme.themeTextColor;
    }
    return self;
}

- (BOOL)parseText:(NSMutableAttributedString *)text selectedRange:(NSRangePointer)selectedRange {
    if (self.editing) {
        text.yy_color = _color;
    }
    
    NSArray<NSTextCheckingResult *> *topicResults = [[YXReportTextParser regexStock] matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.length)];
    NSUInteger clipLength = 0;
    for (NSTextCheckingResult *topic in topicResults) {
        if (topic.range.location == NSNotFound && topic.range.length <= 1) continue;
        NSRange range = topic.range;
        range.location -= clipLength;
        
        __block BOOL containsBindingRange = NO;
        [text enumerateAttribute:YYTextBindingAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value) {
                containsBindingRange = YES;
                *stop = YES;
            }
        }];
        if (containsBindingRange) continue;
        
        NSString *subText = [text.string substringWithRange:range];
        
        NSMutableAttributedString *replace = [[NSMutableAttributedString alloc] initWithString:subText];
        YYTextBackedString *backed = [YYTextBackedString stringWithString:subText];
        [replace yy_setTextBackedString:backed range:NSMakeRange(0, replace.length)];
        
        [text replaceCharactersInRange:range withAttributedString:replace];
        [text yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:YES] range:NSMakeRange(range.location, replace.length)];
        [text yy_setColor:_highlightTextColor range:NSMakeRange(range.location, replace.length)];
        YYTextHighlight *highlight = [[YYTextHighlight alloc] init];
        [text yy_setTextHighlight:highlight range:NSMakeRange(range.location, replace.length)];
        //[text yy_setFont:_highlightFont range:NSMakeRange(range.location, replace.length)];
        
        if (selectedRange) {
            *selectedRange = [self _replaceTextInRange:range withLength:replace.length selectedRange:*selectedRange];
        }
    }
    
    [text enumerateAttribute:YYTextBindingAttributeName inRange:NSMakeRange(0, text.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value && range.length > 0) {
            [text yy_setColor:_highlightTextColor range:range];
            YYTextHighlight *highlight = [[YYTextHighlight alloc] init];
            [text yy_setTextHighlight:highlight range:range];
            //[text yy_setFont:_highlightFont range:range];
        }
    }];
    
    text.yy_font = _font;
    return YES;
}

- (NSRange)_replaceTextInRange:(NSRange)range withLength:(NSUInteger)length selectedRange:(NSRange)selectedRange {

    if (range.length == length) return selectedRange;

    if (range.location >= selectedRange.location + selectedRange.length) return selectedRange;

    if (selectedRange.location >= range.location + range.length) {
        selectedRange.location = selectedRange.location + length - range.length;
        return selectedRange;
    }

    if (NSEqualRanges(range, selectedRange)) {
        selectedRange.length = length;
        return selectedRange;
    }
    
    if ((range.location == selectedRange.location && range.length < selectedRange.length) ||
        (range.location + range.length == selectedRange.location + selectedRange.length && range.length < selectedRange.length)) {
        selectedRange.length = selectedRange.length + length - range.length;
        return selectedRange;
    }
    selectedRange.location = range.location + length;
    selectedRange.length = 0;
    return selectedRange;
}


@end
