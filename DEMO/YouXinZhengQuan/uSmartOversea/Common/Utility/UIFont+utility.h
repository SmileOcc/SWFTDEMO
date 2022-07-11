//
//  UIFont+utility.h
//  uSmartEducation
//
//  Created by RuiQuan Dai on 2018/7/3.
//Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (utility)

//DINPro字体
+ (UIFont *)font_DINPro_Black:(float)font_size;

+ (UIFont *)font_DINPro_Bold:(float)font_size;

+ (UIFont *)font_DINPro_Light:(float)font_size;

+ (UIFont *)font_DINPro_Medium:(float)font_size;

+ (UIFont *)font_DINPro_Regular:(float)font_size;


//PingFang默认字体
+ (UIFont *)font_PingF_Regular:(float)font_size;

+ (UIFont *)font_PingF_Medium:(float)font_size;

+ (UIFont *)font_PingF_Bold:(float)font_size;

+ (UIFont *)font_PingF_Semibold:(float)font_size;


//字体相关
+ (UIFont *)normalFont8;

+ (UIFont *)normalFont9;

+ (UIFont *)normalFont10;

+ (UIFont *)normalFont12;

+ (UIFont *)normalFont11;

+ (UIFont *)normalFont13;

+ (UIFont *)normalFont14;

+ (UIFont *)normalFont16;

+ (UIFont *)normalFont18;

+ (UIFont *)normalFont20;

+ (UIFont *)normalFont22;

+ (UIFont *)normalFont24;

#pragma mark ----- DINPro Font -----
+ (UIFont *)dinProFont8;

+ (UIFont *)dinProFont10;

+ (UIFont *)dinProFont12;

+ (UIFont *)dinProFont14;

+ (UIFont *)dinProFont16;

+ (UIFont *)dinProFont18;

+ (UIFont *)dinProFont20;

+ (UIFont *)dinProFont22;

#pragma mark ----- Medium DINPro Font -----

+ (UIFont *)mediumDinProFont8;

+ (UIFont *)mediumDinProFont10;

+ (UIFont *)mediumDinProFont12;

+ (UIFont *)mediumDinProFont13;

+ (UIFont *)mediumDinProFont14;

+ (UIFont *)mediumDinProFont15;

+ (UIFont *)mediumDinProFont16;

+ (UIFont *)mediumDinProFont18;

+ (UIFont *)mediumDinProFont20;

+ (UIFont *)mediumDinProFont22;

+ (UIFont *)mediumDinProFont24;

+ (UIFont *)mediumDinProFont26;

+ (UIFont *)mediumDinProFont30;

+ (UIFont *)mediumDinProFont38;


#pragma mark ----- Medium Font -----
+ (UIFont *)mediumFont10;

+ (UIFont *)mediumFont12;

+ (UIFont *)mediumFont14;

+ (UIFont *)mediumFont16;

+ (UIFont *)mediumFont18;

+ (UIFont *)mediumFont20;

+ (UIFont *)mediumFont22;

+ (UIFont *)mediumFont24;


@end

NS_ASSUME_NONNULL_END
