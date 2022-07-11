//
//  UIFont+utility.m
//  uSmartEducation
//
//  Created by RuiQuan Dai on 2018/7/3.
//Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "UIFont+utility.h"

@implementation UIFont (utility)

//DINPro字体
+ (UIFont *)font_DINPro_Black:(float)font_size{
    
    return [UIFont fontWithName:@"DINPro-Black" size:font_size];
    
}

+ (UIFont *)font_DINPro_Bold:(float)font_size{
    
    return  [UIFont fontWithName:@"DINPro-Bold" size:font_size];
    
}

+ (UIFont *)font_DINPro_Light:(float)font_size{
    
    return [UIFont fontWithName:@"DINPro-Light" size:font_size];
    
}

+ (UIFont *)font_DINPro_Medium:(float)font_size{
    
    return  [UIFont fontWithName:@"DINPro-Medium" size:font_size];
    
}

+ (UIFont *)font_DINPro_Regular:(float)font_size{
    
    return  [UIFont fontWithName:@"DINPro-Regular" size:font_size];

}

//PingFang默认字体
+ (UIFont *)font_PingF_Regular:(float)font_size{
    
    return [UIFont systemFontOfSize:font_size];
    
}

+ (UIFont *)font_PingF_Medium:(float)font_size{
    
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 9.0) {
        return [UIFont fontWithName:@"PingFangSC-Medium" size:font_size];
    }else{
        return [UIFont boldSystemFontOfSize:font_size];
    }
    
}

+ (UIFont *)font_PingF_Bold:(float)font_size{
    
    return [UIFont boldSystemFontOfSize:font_size];
    
}

+ (UIFont *)font_PingF_Semibold:(float)font_size{
    
    return [UIFont fontWithName:@"PingFangSC-Semibold" size: font_size];
    
}

//字体相关
+ (UIFont *)normalFont10 {
    return [UIFont systemFontOfSize:10];
}

+ (UIFont *)normalFont11 {
    return [UIFont systemFontOfSize:11];
}

+ (UIFont *)normalFont12 {
    return [UIFont systemFontOfSize:12];
}
+ (UIFont *)normalFont13 {
    return [UIFont systemFontOfSize:13];
}
+ (UIFont *)normalFont14 {
    return [UIFont systemFontOfSize:14];
}
+ (UIFont *)normalFont16 {
    return [UIFont systemFontOfSize:16];
}
+ (UIFont *)normalFont18 {
    return [UIFont systemFontOfSize:18];
}
+ (UIFont *)normalFont9 {
    return [UIFont systemFontOfSize:9];
}

+ (UIFont *)normalFont8 {
    return [UIFont systemFontOfSize:8];
}

+ (UIFont *)normalFont20 {
    return [UIFont systemFontOfSize:20];
}

+ (UIFont *)normalFont22 {
    return [UIFont systemFontOfSize:22];
}

+ (UIFont *)normalFont24 {
    return [UIFont systemFontOfSize:24];
}



#pragma mark ----- DINPro Font -----
+ (UIFont *)dinProFont8 {
    return [UIFont font_DINPro_Regular:8];
}

+ (UIFont *)dinProFont10 {
    return [UIFont font_DINPro_Regular:10];
}

+ (UIFont *)dinProFont12 {
    return [UIFont font_DINPro_Regular:12];
}

+ (UIFont *)dinProFont14 {
    return [UIFont font_DINPro_Regular:14];
}

+ (UIFont *)dinProFont16 {
    return [UIFont font_DINPro_Regular:16];
}

+ (UIFont *)dinProFont18 {
    return [UIFont font_DINPro_Regular:18];
}

+ (UIFont *)dinProFont20 {
    return [UIFont font_DINPro_Regular:20];
}

+ (UIFont *)dinProFont22 {
    return [UIFont font_DINPro_Regular:22];
}

#pragma mark ----- Medium DINPro Font -----

+ (UIFont *)mediumDinProFont8 {
    return [UIFont font_DINPro_Medium:8];
}

+ (UIFont *)mediumDinProFont10 {
    return [UIFont font_DINPro_Medium:10];
}

+ (UIFont *)mediumDinProFont12 {
    return [UIFont font_DINPro_Medium:12];
}

+ (UIFont *)mediumDinProFont13 {
    return [UIFont font_DINPro_Medium:13];
}

+ (UIFont *)mediumDinProFont14 {
    return [UIFont font_DINPro_Medium:14];
}

+ (UIFont *)mediumDinProFont15 {
    return [UIFont font_DINPro_Medium:15];
}

+ (UIFont *)mediumDinProFont16 {
    return [UIFont font_DINPro_Medium:16];
}

+ (UIFont *)mediumDinProFont18 {
    return [UIFont font_DINPro_Medium:18];
}

+ (UIFont *)mediumDinProFont20 {
    return [UIFont font_DINPro_Medium:20];
}

+ (UIFont *)mediumDinProFont22 {
    return [UIFont font_DINPro_Medium:22];
}

+ (UIFont *)mediumDinProFont24 {
    return [UIFont font_DINPro_Medium:24];
}

+ (UIFont *)mediumDinProFont26 {
    return [UIFont font_DINPro_Medium:26];
}

+ (UIFont *)mediumDinProFont30 {
    return [UIFont font_DINPro_Medium:30];
}

+ (UIFont *)mediumDinProFont38 {
    return [UIFont font_DINPro_Medium:38];
}

#pragma mark ----- Medium Font -----
+ (UIFont *)mediumFont10 {
    return [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
}

+ (UIFont *)mediumFont12 {
    return [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
}

+ (UIFont *)mediumFont14 {
    return [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
}

+ (UIFont *)mediumFont16 {
    return [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
}

+ (UIFont *)mediumFont18 {
    return [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
}

+ (UIFont *)mediumFont20 {
    return [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
}

+ (UIFont *)mediumFont22 {
    return [UIFont systemFontOfSize:22 weight:UIFontWeightMedium];
}

+ (UIFont *)mediumFont24 {
    return [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
}




@end
