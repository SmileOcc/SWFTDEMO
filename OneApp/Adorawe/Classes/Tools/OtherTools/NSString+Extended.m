//
//  NSString+Extended.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "NSString+Extended.h"

@implementation NSString (Extended)


/*
 *  时间戳对应的NSDate
 */
- (NSDate *)date {
    
    NSTimeInterval timeInterval=self.floatValue;
    
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}

/**
 * 去掉回车与换行符
 */
- (NSString *)replaceBrAndEnterChar
{
    NSString *str = self;
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return str;
}


- (NSString*) decodeFromPercentEscapeString:(NSString *) string {
    return REMOVE_URLENCODING(string);
}

- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
//    CGSize textSize;
//    if (CGSizeEqualToSize(size, CGSizeZero))
//    {
//        //            NSDictionary *attributes = @{NSFontAttributeName:font}
//        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
//        //            textSize = [self sizeWithAttributes:attributes];
//        //            textSize = []
//        
//        textSize = [self sizeWithAttributes:attributes];
//    }
//    else
//    {
//        NSStringDrawingOptions option = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
//        //NSStringDrawingTruncatesLastVisibleLine如果文本内容超出指定的矩形限制，文本将被截去并在最后一个字符后加上省略号。 如果指定了NSStringDrawingUsesLineFragmentOrigin选项，则该选项被忽略 NSStringDrawingUsesFontLeading计算行高时使用行间距。（译者注：字体大小+行间距=行高）
//        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
//        CGRect rect = [self boundingRectWithSize:size
//                                         options:option
//                                      attributes:attributes
//                                         context:nil];
//        
//        textSize = rect.size;
//    }
//    return textSize;
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        
        if (lineBreakMode == NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            paragraphStyle.lineSpacing = 3;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode paragraphStyle:(NSMutableParagraphStyle *)paragraphStyle
{
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        
        if (lineBreakMode == NSLineBreakByWordWrapping) {
            if (paragraphStyle) {
                attr[NSParagraphStyleAttributeName] = paragraphStyle;
            } else {
                NSMutableParagraphStyle *tempParagraphStyle = [NSMutableParagraphStyle new];
                tempParagraphStyle.lineBreakMode = lineBreakMode;
                tempParagraphStyle.lineSpacing = 3;
                attr[NSParagraphStyleAttributeName] = paragraphStyle;
            }
        }

        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}


- (void)calculateHTMLText:(CGSize)contentSize
                labelFont:(UIFont *)labelFont
                lineSpace:(NSNumber *)lineSpace
                alignment:(NSTextAlignment)alignment
               completion:(void (^)(NSAttributedString *stringAttributed, CGSize calculateSize))completion
{
    if ([labelFont isKindOfClass:[UIFont class]]) {
        labelFont = [UIFont systemFontOfSize:14];
    }
    
    NSString *showString = [self stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                              labelFont.fontName,
                                              labelFont.pointSize]];
    
    // 使用 NSHTMLTextDocumentType 时，要在子线程初始化，在主线程赋值，否则会不定时出现 webthread crash
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithData:[showString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
        
        if (lineSpace) {
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = lineSpace.floatValue;
            paragraphStyle.alignment = alignment;
            [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,attributeString.string.length)];
        }
        
        if (CGSizeEqualToSize(contentSize, CGSizeZero)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion([attributeString mutableCopy], CGSizeZero);
                }
            });
            return ;
        }
        
        NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        CGRect rect = [attributeString boundingRectWithSize:contentSize options:options context:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion([attributeString mutableCopy], rect.size);
            }
        });
    });
}


/**
 *  获取属性文字
 *
 *  @param textArr   需要显示的文字数组,如果有换行请在文字中添加 "\n"换行符
 *  @param fontArr   字体数组, 如果fontArr与textArr个数不相同则获取字体数组中最后一个字体
 *  @param colorArr  颜色数组, 如果colorArr与textArr个数不相同则获取字体数组中最后一个颜色
 *  @param spacing   换行的行间距
 *  @param alignment 换行的文字对齐方式
 */
+ (NSMutableAttributedString *)getAttriStrByTextArray:(NSArray *)textArr
                                              fontArr:(NSArray *)fontArr
                                             colorArr:(NSArray *)colorArr
                                          lineSpacing:(CGFloat)spacing
                                            alignment:(NSTextAlignment)alignment
{
    //文字,颜色,字体 每个数组至少有一个
    if (textArr.count > 0 && fontArr.count>0 && colorArr.count>0) {
        
        NSMutableString *allString = [NSMutableString string];
        for (NSString *tempText in textArr) {
            [allString appendFormat:@"%@",tempText];
        }
        
        NSRange lastTextRange = NSMakeRange(0, 0);
        NSMutableArray *rangeArr = [NSMutableArray array];
        
        for (NSString *tempText in textArr) {
            NSRange range = [allString rangeOfString:tempText];
            
            //如果存在相同字符,则换一种查找的方法
            if ([allString componentsSeparatedByString:tempText].count>2) { //存在多个相同字符
                range = NSMakeRange(lastTextRange.location+lastTextRange.length, tempText.length);
            }
            
            [rangeArr addObject:NSStringFromRange(range)];
            lastTextRange = range;
        }
        
        //设置属性文字
        NSMutableAttributedString *textAttr = [[NSMutableAttributedString alloc] initWithString:allString];
        for (int i=0; i<textArr.count; i++) {
            NSRange range = NSRangeFromString(rangeArr[i]);
            
            UIFont *font = (i > fontArr.count-1) ? [fontArr lastObject] : fontArr[i];
            [textAttr addAttribute:NSFontAttributeName value:font range:range];
            
            UIColor *color = (i > colorArr.count-1) ? [colorArr lastObject] : colorArr[i];
            [textAttr addAttribute:NSForegroundColorAttributeName value:color range:range];
        }
        
        //段落 <如果有换行>
        if ([allString rangeOfString:@"\n"].location != NSNotFound && spacing>0) {
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = spacing;
            paragraphStyle.alignment = alignment;
            [textAttr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,allString.length)];
        }
        return textAttr;
    }
    return nil;
}
@end
