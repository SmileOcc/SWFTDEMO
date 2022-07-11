//
//  STLFunctionDefine.h
// XStarlinkProject
//
//  Created by 10010 on 20/10/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#ifndef STLFunctionDefine_h
#define STLFunctionDefine_h




/**
 适配屏幕

 @param value 数值
 @return 向下取整后的适配数值, 取整能减低图片的离屏渲染
 */
CG_INLINE double STLAutoLayout(double value) {
    static double dlayout = 1.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        BOOL is_iphone_6P = (fabs((double)[[UIScreen mainScreen ] bounds].size.height - (double)736)== 0);
        BOOL is_iphone_5  = (fabs((double)[[UIScreen mainScreen ] bounds].size.width - (double)320)== 0);
        
        if (is_iphone_5) {
            dlayout = (double)320/375;
        } else if(is_iphone_6P) {
            dlayout = (double)414/375;
        }
    });

    return floorf(dlayout * value);
}

/**
 16进制颜色字符串转为UIColor

 @param stringToConvert 16进制字符串
 @return 颜色
 */
CG_INLINE UIColor * hexStringToColor(NSString *stringToConvert)
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

/**
 添加渐变颜色
 
 @param view 添加视图
 @param fromHexColorStr 从16进制字符串
 @param toHexColorStr 到16进制字符串
 @return 渐变颜色
 */
CG_INLINE CAGradientLayer * setGradualChangingColor(UIView *view, NSString *fromHexColorStr, NSString *toHexColorStr) {
    //    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    //  创建渐变色数组，需要转换为CGColor颜色
    gradientLayer.colors = @[(__bridge id)hexStringToColor(fromHexColorStr).CGColor,(__bridge id)hexStringToColor(toHexColorStr).CGColor];
    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.cornerRadius=2;
    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0,@1];
    
    return gradientLayer;
}

/**
 计算文本宽度

 @param textStr 字符串
 @param font 字体
 @param size 大小
 @return 宽度
 */
CG_INLINE CGFloat textWidth(NSString *textStr ,UIFont *font, CGSize size){
    NSDictionary *dict = [NSDictionary dictionaryWithObject: font forKey:NSFontAttributeName];
    CGRect textRect = [textStr boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    CGSize textSize = textRect.size;
    return textSize.width;
}

/**
 计算文本高度
 
 @param textStr 字符串
 @param font 字体
 @param size 大小
 @return 高度
 */
CG_INLINE CGFloat textHeight(NSString *textStr ,UIFont *font, CGSize size){
    NSDictionary *dict = [NSDictionary dictionaryWithObject: font forKey:NSFontAttributeName];
    CGRect textRect = [textStr boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    CGSize textSize = textRect.size;
    return textSize.height;
}

/**
 URL编码

 @param textStr 字符串
 @return 编译后字符串
 */
CG_INLINE NSString * addEncodingToStr(NSString *textStr) {
    return [textStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

/**
 URL解码

 @param textStr 字符串
 @return 解码后字符串
 */
CG_INLINE NSString * remEncodingToStr(NSString *textStr) {
    return [textStr stringByRemovingPercentEncoding];
}


/**
* 是否支持黑暗模式系统
*/
#define kisSystemSupportDark STLisSystemDarkOrLight()
CG_INLINE BOOL STLisSystemDarkOrLight(void) {
    if (@available(iOS 13.0, *)) {
        return YES;
    } else {
        return NO;
    }
}

#endif /* STLFunctionDefine_h */
