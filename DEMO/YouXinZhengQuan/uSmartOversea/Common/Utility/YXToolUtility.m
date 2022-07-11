//
//  YXToolUility.m
//  uSmartOversea
//
//  Created by RuiQuan Dai on 2018/7/5.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXToolUtility.h"
#import <NSDate+YYAdd.h>
#import <NSData+YYAdd.h>
#import "uSmartOversea-Swift.h"
#import <Accelerate/Accelerate.h>
#import "NSDate+YXExtension.h"

#define CYL_SOCKET_CONNECT_TIMEOUT 10 //单位秒
#define CYL_SOCKET_CONNECT_TIMEOUT_RTT 600000//10分钟 单位毫秒

#define YX_STOCK_ASSET_NAME @"uSMART"

@implementation YXToolUtility

+(BOOL)saveToLocalWithObject:(id)obj forKey:(NSString *)key
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:obj forKey:key];
    return [defaults synchronize];
}

+(id)getLocalObjectForKey:(NSString *)key
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return obj;
}

+ (BOOL)isValidPassword:(NSString *)PassWord{
    
    if (PassWord.length < 8 || PassWord.length > 24) {
        return NO;
    }
    return YES;
}


+ (BOOL)isNumber:(NSString*)number{
    
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

+ (NSString *)dateStringWithTimeIntervalSince1970:(NSInteger)interval {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSInteger timeOff = -[date timeIntervalSinceNow];
    if (timeOff < 3600 && timeOff>=0) {
        NSInteger minute = timeOff/60 + 1;
        return [NSString stringWithFormat:@"%ld%@", (NSInteger)minute, [YXLanguageUtility kLangWithKey: @"mins_ago"]];
    } else if (date.isToday) {
        return [date stringWithFormat:@"HH:mm"];
    }else{
        return [date stringWithFormat:@"MM-dd HH:mm"];
    }
    
    return @"";
}

+ (void)forceToPortraitOrientation {
    ((YXAppDelegate *)YXConstant.sharedAppDelegate).rotateScreen = NO;
    [YXToolUtility switchNewOrientation:UIInterfaceOrientationMaskPortrait];
}

+ (void)forceToLandscapeRightOrientation {
    ((YXAppDelegate *)YXConstant.sharedAppDelegate).rotateScreen = YES;
    [YXToolUtility switchNewOrientation:UIInterfaceOrientationMaskLandscapeRight];
}

+ (void)switchNewOrientation:(UIInterfaceOrientationMask)interfaceOrientationMask {

    UIDeviceOrientation orientation = [YXToolUtility deviceOrientationWithInterfaceOrientationMask:interfaceOrientationMask];
    if ([UIDevice currentDevice].orientation == orientation) {
        [UIViewController attemptRotationToDeviceOrientation];
        return;
    }

    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
}

+ (UIDeviceOrientation)deviceOrientationWithInterfaceOrientationMask:(UIInterfaceOrientationMask)mask {
    if ((mask & UIInterfaceOrientationMaskAll) == UIInterfaceOrientationMaskAll) {
        return [UIDevice currentDevice].orientation;
    }
    if ((mask & UIInterfaceOrientationMaskAllButUpsideDown) == UIInterfaceOrientationMaskAllButUpsideDown) {
        return [UIDevice currentDevice].orientation;
    }
    if ((mask & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait) {
        return UIDeviceOrientationPortrait;
    }
    if ((mask & UIInterfaceOrientationMaskLandscape) == UIInterfaceOrientationMaskLandscape) {
        return [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationLandscapeRight;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft) {
        return UIDeviceOrientationLandscapeRight;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight) {
        return UIDeviceOrientationLandscapeLeft;
    }
    if ((mask & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIDeviceOrientationPortraitUpsideDown;
    }
    return [UIDevice currentDevice].orientation;
}

+ (NSMutableAttributedString *)attributedStringWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor lineSpacing:(CGFloat)lineSpacing {
    
    if (text.length <= 0) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:lineSpacing];
    return [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor, NSParagraphStyleAttributeName : paragraphStyle1}];
    
}

+ (CGSize)getStringSizeWith:(NSString *)string andFont:(UIFont *)font andlimitWidth:(float)width andLineSpace:(float)lineSpace{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;
    NSDictionary *attribute = @{NSFontAttributeName: font, NSParagraphStyleAttributeName : paragraphStyle};
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:attribute
                                       context:nil].size;
    return size;
    
}

+ (CGSize)getStringSizeWith:(NSString *)string andFont:(UIFont *)font andlimitWidth:(float)width {
  
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:attribute
                                       context:nil].size;
    return size;
    
}

+ (CGSize)getStringSizeWith:(NSString *)string andFont:(UIFont *)font andlimitWidth:(float)width andLineHeight:(float)lineHeight {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = lineHeight;
    NSDictionary *attribute = @{NSFontAttributeName: font, NSParagraphStyleAttributeName : paragraphStyle};
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:attribute
                                       context:nil].size;
    return size;
}


+ (NSString *)stockPriceData:(double)data deciPoint:(NSInteger)deciPoint priceBase:(NSInteger)priceBase {
    
    NSInteger square = priceBase > 0 ? priceBase : 0;
    NSInteger priceBasic = pow(10.0, square);
    double num = data / priceBasic;
    NSString *priceBaseFormat = [NSString stringWithFormat:@"%%.%ldf", (long)deciPoint];
    return [NSString stringWithFormat:priceBaseFormat, num];
    
}

+ (NSString *)stockData:(double)data deciPoint:(NSInteger)deciPoint stockUnit:(NSString *)unit priceBase:(NSInteger)priceBase {
    
    
    if (YXUserManager.isENMode) {
        return [self stockEnData:data deciPoint:deciPoint stockUnit:unit priceBase:priceBase];
    }
    
    NSString *deciPointFormat = [NSString stringWithFormat:@"%%.%ldf", (long)deciPoint];
    if (deciPoint == 0) {
        deciPointFormat = @"%lld";
    }
    
    // 万
    NSString *tenThousand = [YXLanguageUtility kLangWithKey:@"stock_detail_ten_thousand"];
    // 亿
    NSString *hundredMillion = [YXLanguageUtility kLangWithKey:@"common_billion"];
    // 万亿
    NSString *billion = [NSString stringWithFormat:@"%@%@", tenThousand, hundredMillion];
    
    NSInteger square = priceBase > 0 ? priceBase : 0;
    NSInteger priceBasic = pow(10.0, square);
    
    double num = data / priceBasic;
    NSString *str;
    NSString *unitString;
    
    if ((num < 10000 && num >= 0) || (num > -10000 && num <= 0)) {
        NSString *numFormat = [NSString stringWithFormat:@"%@%@",deciPointFormat, unit];
        if (deciPoint == 0) {
            str = [NSString stringWithFormat:numFormat, (long long)num];
        } else {
            str = [NSString stringWithFormat:numFormat, num];
        }
    } else if ((num < 100000000 && num >= 10000) || (num > -100000000 && num <= -10000)) {  //万
        
        if (unit.length > 0) {
            unitString = [NSString stringWithFormat:@"%@%@", tenThousand, unit];
        }else{
            unitString = tenThousand;
        }
        double stockNum = num / 10000.0;
        
        NSString *stockNumStr;
        if (deciPoint == 0) {
            stockNumStr = [NSString stringWithFormat:deciPointFormat, (long long)stockNum];
        } else {
            stockNumStr = [NSString stringWithFormat:deciPointFormat, stockNum];
        }
        
        
        if (stockNumStr.floatValue >= 10000) {
            stockNum = stockNumStr.floatValue / 10000.0;
            unitString = hundredMillion;
        }
        NSString *stockNumFormat = [NSString stringWithFormat:@"%@%@",deciPointFormat, unitString];
        if (deciPoint == 0) {
            str = [NSString stringWithFormat:stockNumFormat, (long long)stockNum];
        } else {
            str = [NSString stringWithFormat:stockNumFormat, stockNum];
        }
    } else if ((num >= 100000000 && num / 10000.0 < 100000000) || (num <= 100000000 && num / 10000.0 > -100000000)){
        
        if (unit.length > 0) {
            unitString = [NSString stringWithFormat:@"%@%@", hundredMillion, unit];
        }else{
            unitString = hundredMillion;
        }
        double stockNum = num / (10000.0 * 10000.0);
        
        NSString *stockNumStr;
        if (deciPoint == 0) {
            stockNumStr = [NSString stringWithFormat:deciPointFormat, (long long)stockNum];
        } else {
            stockNumStr = [NSString stringWithFormat:deciPointFormat, stockNum];
        }
        
        if (stockNumStr.floatValue >= 10000) {
            stockNum = stockNumStr.floatValue / 10000.0;
            unitString = billion;
        }
        NSString *stockNumFormat = [NSString stringWithFormat:@"%@%@",deciPointFormat, unitString];
        if (deciPoint == 0) {
            str = [NSString stringWithFormat:stockNumFormat, (long long)stockNum];
        } else {
            str = [NSString stringWithFormat:stockNumFormat, stockNum];
        }
    } else {
        
        if (unit.length > 0) {
            unitString = [NSString stringWithFormat:@"%@%@", billion, unit];
        }else{
            unitString = billion;
        }
        double stockNum = num / (10000.0 * 10000.0 * 10000.0);
        NSString *stockNumFormat = [NSString stringWithFormat:@"%@%@",deciPointFormat, unitString];
        if (deciPoint == 0) {
            str = [NSString stringWithFormat:stockNumFormat, (long long)stockNum];
        } else {
            str = [NSString stringWithFormat:stockNumFormat, stockNum];
        }
    }
    return str;
}


+ (NSString *)stockEnData:(double)data deciPoint:(NSInteger)deciPoint stockUnit:(NSString *)unit priceBase:(NSInteger)priceBase {
    
    // 千
    NSString *tenThousand = @"K";
    // 百万
    NSString *hundredMillion = @"M";
    // 十亿
    NSString *billion = @"B";
    
    NSInteger square = priceBase > 0 ? priceBase : 0;
    NSInteger priceBasic = pow(10.0, square);
    
    double num = data / priceBasic;
    NSString *str;
    NSString *unitString;
    
    NSString *deciPointFormat = [NSString stringWithFormat:@"%%.%ldf", (long)deciPoint];
    if (deciPoint == 0) {
        deciPointFormat = @"%lld";
    }

    double compareNum = fabs(num);

    if (compareNum < 1E3 && compareNum >= 0) {
        NSString *numFormat = [NSString stringWithFormat:@"%@%@",deciPointFormat, unit];
        if (deciPoint == 0) {
            str = [NSString stringWithFormat:numFormat, (long long)num];
        } else {
            str = [NSString stringWithFormat:numFormat, num];
        }
    } else if (compareNum >= 1E3 && compareNum < 1E6) {
        
        if (unit.length > 0) {
            unitString = [NSString stringWithFormat:@"%@%@", tenThousand, unit];
        }else{
            unitString = tenThousand;
        }
        double stockNum = num / (1000);
        
        NSString *stockNumFormat = [NSString stringWithFormat:@"%@%@",deciPointFormat, unitString];
        if (deciPoint == 0) {
            if (stockNum < 1) {
                str = [NSString stringWithFormat:@"%.2f%@", stockNum, unitString];
            } else {
                str = [NSString stringWithFormat:stockNumFormat, (long long)stockNum];
            }
        } else {
            str = [NSString stringWithFormat:stockNumFormat, stockNum];
        }
        
    } else if (compareNum >= 1E6 && compareNum < 1E9) {

        if (unit.length > 0) {
            unitString = [NSString stringWithFormat:@"%@%@", hundredMillion, unit];
        }else{
            unitString = hundredMillion;
        }
        double stockNum = num / (1E6);

        NSString *stockNumFormat = [NSString stringWithFormat:@"%@%@",deciPointFormat, unitString];
        if (deciPoint == 0) {
            if (stockNum < 1) {
                str = [NSString stringWithFormat:@"%.2f%@", stockNum, unitString];
            } else {
                str = [NSString stringWithFormat:stockNumFormat, (long long)stockNum];
            }
        } else {
            str = [NSString stringWithFormat:stockNumFormat, stockNum];
        }

    } else {
        
        if (unit.length > 0) {
            unitString = [NSString stringWithFormat:@"%@%@", billion, unit];
        }else{
            unitString = billion;
        }
        double stockNum = num / (1E9);
        
        NSString *stockNumFormat = [NSString stringWithFormat:@"%@%@",deciPointFormat, unitString];
        if (deciPoint == 0) {
            str = [NSString stringWithFormat:stockNumFormat, (long long)stockNum];
        } else {
            str = [NSString stringWithFormat:stockNumFormat, stockNum];
        }
    }
    return str;
}



+ (NSString *)stockPercentData:(double)data priceBasic:(NSInteger)priceBasic deciPoint:(NSInteger)deciPoint {
    
    NSInteger square = priceBasic > 0 ? priceBasic : 0;
    NSInteger priceBase = pow(10.0, square);
    NSString *dataString;
    if (deciPoint == 2) {
        dataString = [NSString stringWithFormat:@"%.2f", data / priceBase];
    } else {
        dataString = [NSString stringWithFormat:@"%.3f", data / priceBase];
    }
    NSString *positiveString = @"";
    if (data < 0) {
        if (![dataString containsString:@"-"]) {            
            positiveString = @"-";
        }
    } else if (data > 0) {
        positiveString = @"+";
    }
    return [NSString stringWithFormat:@"%@%@%@", positiveString, dataString, @"%"];
}

+ (NSString *)stockPercentDataNoPositive:(double)data priceBasic:(NSInteger)priceBasic deciPoint:(NSInteger)deciPoint {
    
    NSInteger square = priceBasic > 0 ? priceBasic : 0;
    NSInteger priceBase = pow(10.0, square);
    NSString *dataString;
    if (deciPoint == 2) {
        dataString = [NSString stringWithFormat:@"%.2f", data / priceBase];
    } else {
        dataString = [NSString stringWithFormat:@"%.3f", data / priceBase];
    }
    return [NSString stringWithFormat:@"%@%@" , dataString, @"%"];
}

+ (BOOL)isPureInt:(NSString *)string{
    
    if (string.length <= 0) {
        
        return NO;
        
    } else {
        
        NSScanner *scan = [NSScanner scannerWithString:string];
        int val;
        return [scan scanInt:&val] && [scan isAtEnd];
        
    }
}

+ (UIColor *)stockColorWithData:(double)data compareData:(double)comparedData {
     
     if (data > comparedData) {
          
          return [QMUITheme stockRedColor];
          
     } else if (data < comparedData) {
          
          return [QMUITheme stockGreenColor];
          
     } else {
          
          return [QMUITheme stockGrayColor];
          
     }
     
}

+ (UIColor *)stockChangeColor:(double)change{
     
     if (change > 0) {
          
          return [QMUITheme stockRedColor];
          
     } else if (change < 0) {
          
          return [QMUITheme stockGreenColor];
          
     } else {
          
          return [QMUITheme stockGrayColor];
     }
     
}

/**
 判断字符串是否是纯Float类型
 
 @param string
 @return YES/NO
 create date: 2019-08-12
 auth: huang sengoln
 */
+ (BOOL)isPureFloat:(NSString *)string {
    if (string.length <= 0) {
        return NO;
    } else {
        NSScanner *scan = [NSScanner scannerWithString:string];
        float val;
        return [scan scanFloat:&val] && [scan isAtEnd];
        
    }
}

//1-人民币，2-美元，3-港币，5-新加坡币，6-日元，7-英镑，8-欧元，9-加元，10-澳元，11-新西兰元，12-法郎 13
+ (NSArray<NSString *> * _Nonnull)moneyUnitArray {
    
    return @[
        @"",
        [YXLanguageUtility kLangWithKey:@"common_rmb"],
        [YXLanguageUtility kLangWithKey:@"common_us_dollar"],
        [YXLanguageUtility kLangWithKey:@"common_hk_dollar"],
        @"", @"新加坡币", @"日元", @"英镑", @"欧元", @"加元", @"澳元", @"新西兰元", @"法郎", @"马来西亚林吉特", @"马来西亚林吉特", @"秘鲁索尔", @"智利比索", @"委内瑞拉玻璃瓦尔", @"特立尼达和多巴哥元", @"墨西哥比索", @"哥伦比亚比索", @"牙买加元", @"阿根廷比索", @"百慕大美元"];
}

/**
 获取当前的货币表示（人民币、港币，美元）,新股中心使用
 
 @param moneyType 类型
 @return 币种
 */
+ (NSString * _Nonnull)moneyUnit:(NSInteger)moneyType {
    if (moneyType == 0) {
        return [YXLanguageUtility kLangWithKey:@"common_rmb"];
    } else if (moneyType == 1) {
        return [YXLanguageUtility kLangWithKey:@"common_us_dollar"];
    } else {
        return [YXLanguageUtility kLangWithKey:@"common_hk_dollar"];
    }
}

/**
 注意：行情接口返回的货币类型使用
 获取当前的货币表示（人民币、港币，美元）
 
 @param currency 类型
 @return 币种
 */
+ (NSString *)quoteCurrency:(NSInteger)currency {
    if (currency == 1) {
        return [YXLanguageUtility kLangWithKey:@"common_rmb"];
    } else if (currency == 2) {
        return [YXLanguageUtility kLangWithKey:@"common_us_dollar"];
    } else if (currency == 3) {
        return [YXLanguageUtility kLangWithKey:@"common_hk_dollar"];
    } else if (currency == 5){
        return [YXLanguageUtility kLangWithKey:@"common_sg_dollar"];
    } else {
        return @"";
    }
}

//单位K, M, B
+ (NSString *)stockVolumeUnit:(NSInteger)num {
    
    if (num < 1000) {
        return [NSString stringWithFormat:@"%ld", num];
    }
    if (num >= 1000 & num < 1000000) {
        return [NSString stringWithFormat:@"%.1fK", num / 1000.0];
    }
    else if (num >= 1000 * 1000.0 && num < 1000.0 * 1000.0 * 1000.0) {
        return [NSString stringWithFormat:@"%.1fM", num / (1000 * 1000.0)];
    } else {
        return [NSString stringWithFormat:@"%.1fB", num / (1000 * 1000.0 * 1000.0)];
    }
    
}

+ (NSString *)formatNumberDecimalValue:(double)value {
    NSString * string = [NSNumberFormatter localizedStringFromNumber:@(value) numberStyle:NSNumberFormatterDecimalStyle];
    return string;
}

//价格
+ (UIColor *)priceTextColor:(double)data comparedData:(double)compareData {
    if (data > compareData) {
        return [QMUITheme stockRedColor];
    } else if (data < compareData) {
        return [QMUITheme stockGreenColor];
    } else {
        return [QMUITheme stockGrayColor];
    }
    
}
//roc, change
+ (UIColor *)changeColor:(double)change {
    
    if (change > 0) {
        return [QMUITheme stockRedColor];
    } else if (change < 0) {
        return [QMUITheme stockGreenColor];
    } else {
        return [QMUITheme stockGrayColor];
    }
    
}

/**
 *  获取相簿
 *
 *  @return 获取到的相簿
 */

+ (PHAssetCollection *)assetCollection {
    //获取所有相簿
    PHFetchResult *reult = [PHAssetCollection fetchAssetCollectionsWithType:(PHAssetCollectionTypeAlbum) subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //遍历所有相簿查找名字叫做 ZKQtitle的相簿
    for (PHAssetCollection *collection in reult) {
        //如果有 返回
        if ([collection.localizedTitle isEqualToString:YX_STOCK_ASSET_NAME]) {
            return collection;
        }
    }
    
    //没有则创建
    //相簿的本地标识符
    __block NSString *collectionIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //获取相簿本地标识符
        collectionIdentifier= [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:YX_STOCK_ASSET_NAME].placeholderForCreatedAssetCollection.localIdentifier;
        
    } error:nil];
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionIdentifier] options:nil].firstObject;
}

/**
 当前月份的英文简写 (顺序1， 2， 。。。 11， 12)
 
 @param month 月份索引
 @return 对应月份英文简写
 */
+ (NSString *)shortMonthName:(NSInteger)month {
    
    NSArray *months = @[@"", @"Jan.", @"Feb.", @"Mar.", @"Apr.", @"May", @"Jun.", @"Jul.", @"Aug.", @"Sept.", @"Oct.", @"Nov.", @"Dec."];
    if (month >= months.count || month < 0) {
        return months.firstObject;
    }
    return months[month];
}

/**
 当前月份的英文简写 (顺序1， 2， 。。。 11， 12)
 
 @param month 月份索引
 @return 对应月份英文简写，不带.
 */
+ (NSString *)enMonthName:(NSInteger)month {
    
    NSArray *months = @[@"", @"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sept", @"Oct", @"Nov", @"Dec"];
    if (month >= months.count || month < 0) {
        return months.firstObject;
    }
    return months[month];
}

/**
 是否是5系列, SE或4s手机
 */
+ (BOOL)is4InchScreenWidth {
    if (YXConstant.screenWidth == 320) {
        return YES;
    }
    return NO;
}

+ (nullable NSString *)getIDFA {
    NSString *idfa = nil;
    @try {
        Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
        if (ASIdentifierManagerClass) {
            SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
            id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
            SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
            NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
            NSString *temp = [uuid UUIDString];
            // 在 iOS 10.0 以后，当用户开启限制广告跟踪，advertisingIdentifier 的值将是全零
            // 00000000-0000-0000-0000-000000000000
            if (temp && ![temp hasPrefix:@"00000000"]) {
                idfa = temp;
            }
        }
        return idfa;
    } @catch (NSException *exception) {
        return idfa;
    }
}

+ (NSArray<UIColor *> * _Nonnull)stockColorArrays {
    UIColor *colorOne = [UIColor qmui_colorWithHexString:@"#414FFF"];
    UIColor *colorTwo = [UIColor qmui_colorWithHexString:@"#34C767"];
    UIColor *colorThree = [UIColor qmui_colorWithHexString:@"#EE3D3D"];
    UIColor *colorFour = [UIColor qmui_colorWithHexString:@"#FF7D34"];
    UIColor *colorFive = [UIColor qmui_colorWithHexString:@"#FFC034"];
    UIColor *colorSix = [UIColor qmui_colorWithHexString:@"#0BC5FD"];
    UIColor *colorSeven = [UIColor qmui_colorWithHexString:@"#42A154"];
    UIColor *colorEight = [UIColor qmui_colorWithHexString:@"#DE449A"];
    UIColor *colorNine = [UIColor qmui_colorWithHexString:@"#E59C24"];
    UIColor *colorTen = [UIColor qmui_colorWithHexString:@"#42459E"];
    UIColor *colorEleven = [UIColor qmui_colorWithHexString:@"#4E8C81"];
    UIColor *colorTwelve = [UIColor qmui_colorWithHexString:@"#8556D7"];
    UIColor *colorThirteen = [UIColor qmui_colorWithHexString:@"#EE3DDC"];
    UIColor *colorFourteen = [UIColor qmui_colorWithHexString:@"#C0A912"];
    UIColor *colorFifteen = [UIColor qmui_colorWithHexString:@"#39D79F"];
    UIColor *colorSixteen = [UIColor qmui_colorWithHexString:@"#546AD6"];
    UIColor *colorSeventeen = [UIColor qmui_colorWithHexString:@"#72EB5B"];
    UIColor *colorEightteen = [UIColor qmui_colorWithHexString:@"#A6106F"];
    UIColor *colorNineteen = [UIColor qmui_colorWithHexString:@"#D14949"];
    return @[colorOne, colorTwo, colorThree, colorFour, colorFive, colorSix, colorSeven, colorEight, colorNine, colorTen, colorEleven, colorTwelve, colorThirteen, colorFourteen, colorFifteen, colorFifteen, colorSixteen, colorSeventeen, colorEightteen, colorNineteen];
}


//判断手机是否越狱
+ (BOOL)JailBreak {
    BOOL status1 = NO;
    BOOL status2 = NO;
    //根据是否能打开cydia判断
    status1 = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]];
    //根据是否能获取所有应用的名称判断 没有越狱的设备是没有读取所有应用名称的权限的
    status2 = [[NSFileManager defaultManager] fileExistsAtPath:@"User/Applications/"];
    if (status1 || status2) {  //如果有一只方式判定为设备越狱了那么设备就越狱了不接受任何反驳
        return  YES;
    }else{
        return  NO;
    }
}

+ (NSData *)dataWithScreenshotInPNGFormat
{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
            
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    if (((YXAppDelegate *)YXConstant.sharedAppDelegate).rotateScreen == YES) {
        image = [image qmui_imageWithOrientation:UIImageOrientationRight];
    }
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}


/**
 *  返回截取到的图片
 *
 *  @return UIImage *
 */
+ (UIImage *)imageWithScreenshot
{
    NSData *imageData = [YXToolUtility dataWithScreenshotInPNGFormat];
    UIImage *image = [UIImage imageWithData:imageData];
    return [YXToolUtility coreGaussianBlurImage:image blurNumber:0.4];
}

+ (UIImage *)coreGaussianBlurImage:(UIImage * _Nonnull)image blurNumber:(CGFloat)blur{
    
    if (image==nil)
    {
        return nil;
    }
    //模糊度,
    if (blur < 0.025f) {
        blur = 0.025f;
    } else if (blur > 1.0f) {
        blur = 1.0f;
    }
    
    //boxSize必须大于0
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    NSLog(@"boxSize:%i",boxSize);
    //图像处理
    CGImageRef img = image.CGImage;
    //需要引入#import <Accelerate/Accelerate.h>
    
    //图像缓存,输入缓存，输出缓存
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    //像素缓存
    void *pixelBuffer;
    
    //数据源提供者，Defines an opaque type that supplies Quartz with data.
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    // provider’s data.
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    //宽，高，字节/行，data
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //像数缓存，字节行*图片高
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    // 第三个中间的缓存区,抗锯齿的效果
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    //Convolves a region of interest within an ARGB8888 source image by an implicit M x N kernel that has the effect of a box filter.
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    //    NSLog(@"字节组成部分：%zu",CGImageGetBitsPerComponent(img));
    //颜色空间DeviceRGB
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    
    //根据上下文，处理过的图片，重新组件
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    //CGColorSpaceRelease(colorSpace);   //多余的释放
    CGImageRelease(imageRef);
    return returnImage;
}

+ (NSString * _Nonnull)xTokenGenerateWithXTransId:(NSString * _Nonnull)xTransId xTime:(NSString * _Nonnull)xTime xDt:(NSString * _Nonnull)xDt xDevId:(NSString * _Nonnull)xDevId xUid:(NSString * _Nonnull)xUid xLang:(NSString * _Nonnull)xLang xType:(NSString * _Nonnull)xType xVer:(NSString * _Nonnull)xVer {
    return [[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", xTransId, xTime, xDt, xDevId, xUid, xLang, xType, xVer] qmui_md5];
}

+ (UIImage * _Nullable)conventToImageWithBase64String:(id _Nullable)base64String; {
    if (base64String == nil || (![base64String isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    NSString *imageDataString = base64String;
    UIImage *image = nil;
    NSArray<NSString *> *array = [imageDataString componentsSeparatedByString:@","];
    if ([array count] > 1) {
        NSString *picture = array[1];
        NSData *imageData = [NSData dataWithBase64EncodedString: picture];

        if (imageData == nil) {
            imageData = [NSData dataWithBase64EncodedString: [NSString stringWithFormat:@"%@==", picture]];
        }
        
        if (imageData != nil) {
            image = [UIImage imageWithData:imageData];
        }
    }
    return image;
}

+ (NSMutableAttributedString *)stocKNumberData:(int64_t)value deciPoint:(NSInteger)deciPoint stockUnit:(NSString *)unit priceBase:(NSInteger)priceBase {
     NSString *dataString = [@(value) stringValue];
     NSString *priceBaseString = [@(priceBase) stringValue];
     return [self stockDataString:dataString deciPoint:deciPoint stockUnit:unit priceBase:priceBaseString];
}

+ (NSMutableAttributedString *)stocKNumberData:(int64_t)value deciPoint:(NSInteger)deciPoint stockUnit:(NSString *)unit priceBase:(NSInteger)priceBase numberFont:(UIFont *)numberFont unitFont:(UIFont*)unitFont {
     NSString *dataString = [@(value) stringValue];
     NSString *priceBaseString = [@(priceBase) stringValue];
     return [self stockData:dataString deciPoint:deciPoint stockUnit:unit priceBase:priceBaseString numberFont:numberFont unitFont:unitFont];
}

+ (NSMutableAttributedString *)stocKNumberData:(int64_t)value deciPoint:(NSInteger)deciPoint stockUnit:(NSString *)unit priceBase:(NSInteger)priceBase numberFont:(UIFont *)numberFont unitFont:(UIFont*)unitFont color:(UIColor *)color {
    NSString *dataString = [@(value) stringValue];
    NSString *priceBaseString = [@(priceBase) stringValue];
    return [self stockData:dataString deciPoint:deciPoint stockUnit:unit priceBase:priceBaseString numberFont:numberFont unitFont:unitFont isShowPlus:YES andTextColor:color];
}

+ (NSMutableAttributedString *)stockData:(NSString *)data deciPoint:(NSInteger)deciPoint stockUnit:(NSString *)unit priceBase:(NSString *)priceBase numberFont:(UIFont *)numberFont unitFont:(UIFont*)unitFont{
    return [self stockData:data deciPoint:deciPoint stockUnit:unit priceBase:priceBase numberFont:numberFont unitFont:unitFont isShowPlus:NO andTextColor:[QMUITheme textColorLevel1]];
}

+ (NSMutableAttributedString *)stockDataString:(NSString *)data deciPoint:(NSInteger)deciPoint stockUnit:(NSString *)unit priceBase:(NSString *)priceBase{
     return [self stockData:data deciPoint:deciPoint stockUnit:unit priceBase:priceBase numberFont:[UIFont systemFontOfSize:14] unitFont:[UIFont systemFontOfSize:10]];
}

+ (NSMutableAttributedString *)stockData:(NSString *)data deciPoint:(NSInteger)deciPoint stockUnit:(NSString *)unit priceBase:(NSString *)priceBase numberFont:(UIFont *)numberFont unitFont:(UIFont*)unitFont isShowPlus:(BOOL)isShowPlus andTextColor:(UIColor *)textColor {

    if (YXUserManager.isENMode) {
        NSString *string = [self stockEnData:data.doubleValue deciPoint:deciPoint stockUnit:unit priceBase:priceBase.intValue];
        NSString *op = @"";
        int square = priceBase.length > 0 ? priceBase.intValue : 0;
        double priceBasic = pow(10.0, square);
        double num = data.doubleValue / priceBasic;
        if (num > 0 && isShowPlus) {
            op = @"+";
            string = [NSString stringWithFormat:@"%@%@", op, string];
        }
        return [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: numberFont, NSForegroundColorAttributeName: textColor}];
    }
     if (data.length < 0) {
          
          return [[NSMutableAttributedString alloc] initWithString:@"--" attributes:@{NSFontAttributeName: numberFont, NSForegroundColorAttributeName: textColor}];
          
     } else {
          int square = priceBase.length > 0 ? priceBase.intValue : 0;
          double priceBasic = pow(10.0, square);
          
          double num = data.doubleValue / priceBasic;
          NSString *str;
          NSString *unitString;
         NSString *op = @"";
         if (num > 0 && isShowPlus) {
             op = @"+";
         }
          
          if ((num < 10000 && num >= 0) || (num > -10000 && num <= 0)) {
               if (unit.length > 0) {
                    unitString = unit;
               } else {
                    unitString = @"";
               }
               if (deciPoint == 2) { //保留2位小数
                    str = [NSString stringWithFormat:@"%.2f%@", num, unit];
               }else{
                    str = [NSString stringWithFormat:@"%.3f%@", num, unit];
               }
          }
          
          else if ((num < 100000000 && num >= 10000) || (num > -100000000 && num <= -10000)) {  //万
               
               if (unit.length > 0) {
                    unitString = [NSString stringWithFormat:@"%@%@", [YXLanguageUtility kLangWithKey:@"stock_detail_ten_thousand"], unit];
               }else{
                    unitString = [YXLanguageUtility kLangWithKey:@"stock_detail_ten_thousand"];
               }
               double stockNum = num / 10000.0;
               NSString *stockNumStr;
               if (deciPoint == 2) { //保留2位小数
                    stockNumStr = [NSString stringWithFormat:@"%.2f", stockNum];
               } else {
                    stockNumStr = [NSString stringWithFormat:@"%.3f", stockNum];
               }
               
               if (stockNumStr.floatValue >= 10000) {
                    stockNum = stockNumStr.floatValue / 10000.0;
                    unitString = [YXLanguageUtility kLangWithKey:@"common_billion"];
               }
               if (deciPoint == 2) {
                    str = [NSString stringWithFormat:@"%.2f%@", stockNum, unitString];
               } else {
                    str = [NSString stringWithFormat:@"%.3f%@", stockNum, unitString];
               }
               
          } else if ((num >= 100000000 && num / 10000.0 < 100000000) || (num <= 100000000 && num / 10000.0 > -100000000)){
               
               if (unit.length > 0) {
                    unitString = [NSString stringWithFormat:@"%@%@", [YXLanguageUtility kLangWithKey:@"common_billion"], unit];
               }else{
                    unitString = [YXLanguageUtility kLangWithKey:@"common_billion"];
               }
               double stockNum = num / (10000.0 * 10000.0);
               
               NSString *stockNumStr;
               if (deciPoint == 2) { //保留2位小数
                    stockNumStr = [NSString stringWithFormat:@"%.2f", stockNum];
               } else {
                    stockNumStr = [NSString stringWithFormat:@"%.3f", stockNum];
               }
               
               if (stockNumStr.floatValue >= 10000) {
                    stockNum = stockNumStr.floatValue / 10000.0;
                    unitString = [NSString stringWithFormat:@"%@%@", [YXLanguageUtility kLangWithKey:@"stock_detail_ten_thousand"], [YXLanguageUtility kLangWithKey:@"common_billion"]];
               }
               if (deciPoint == 2) {
                    str = [NSString stringWithFormat:@"%.2f%@", stockNum, unitString];
               } else {
                    str = [NSString stringWithFormat:@"%.3f%@", stockNum, unitString];
               }
          }else{

               unitString = [NSString stringWithFormat:@"%@%@", [YXLanguageUtility kLangWithKey:@"stock_detail_ten_thousand"], [YXLanguageUtility kLangWithKey:@"common_billion"]];
               if (unit.length > 0) {
                    unitString = [NSString stringWithFormat:@"%@%@", unitString,  unit];
               }
               double stockNum = num / (10000.0 * 10000.0 * 10000.0);
               if (deciPoint == 2) { //保留2位小数
                    str = [NSString stringWithFormat:@"%.2f%@", stockNum, unitString];
               }else{
                    str = [NSString stringWithFormat:@"%.3f%@", stockNum, unitString];
               }
          }
          str = [NSString stringWithFormat:@"%@%@", op, str];
          NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:str];
          [attriString addAttributes:@{NSFontAttributeName: numberFont, NSForegroundColorAttributeName : textColor} range:NSMakeRange(0, str.length)];
          [attriString addAttribute:NSFontAttributeName value:unitFont range:NSMakeRange(str.length - unitString.length, unitString.length)];
          
          return attriString;
     }
}

+ (NSString *)stringValue:(id)value {
     if (value == nil) {
          return nil;
     }
     
     if ([value isKindOfClass:[NSString class]]) {
          return (NSString *)value;
     }
     if ([value isKindOfClass:[NSURL class]]) {
          return [(NSURL *)value absoluteString];
     } else if ([value isKindOfClass:[NSNull class]]) {
          return nil;
     }
     if ([value respondsToSelector:@selector(stringValue)]) {
          return [value stringValue];
     }
     return [value description];
}

+ (BOOL)boolValue:(id)value def:(BOOL)def {
     if ([value respondsToSelector:@selector(boolValue)]) {
          return [value boolValue];
     }
     return def;
}

+ (BOOL)boolValue:(id)value {
     return [self boolValue:value def:NO];
}

+ (double)doubleValue:(id)value {
     return [self doubleValue:value def:0];
}

+ (double)doubleValue:(id)value def:(double)def {
     return [self doubleValue:value def:def valid:NULL];
}

+ (double)doubleValue:(id)value def:(double)def valid:(BOOL *)isValid {
     if ([value respondsToSelector:@selector(doubleValue)]) {
          if (isValid != NULL)
               *isValid = YES;
          return [value doubleValue];
     }
     return def;
}

+ (int)intValue:(id)value def:(int)def valid:(BOOL *)isValid {
     if ([value respondsToSelector:@selector(intValue)]) {
          if (isValid != NULL) {
               *isValid = YES;
          }
          return [value intValue];
     }
     if (isValid != NULL) {
          *isValid = NO;
     }
     return def;
}

+ (int)intValue:(id)value def:(int)def {
     return [self intValue:value def:def valid:NULL];
}

+ (int)intValue:(id)value {
     return [self intValue:value def:0];
}

+ (CGFloat)floatValue:(id)value def:(CGFloat)def {
     return [self floatValue:value def:def valid:NULL];
}

+ (CGFloat)floatValue:(id)value def:(CGFloat)def valid:(BOOL *)isValid {
     if ([value respondsToSelector:@selector(floatValue)]) {
          if (isValid != NULL)
               *isValid = YES;
          return [value floatValue];
     }
     if (isValid != NULL) {
          *isValid = NO;
     }
     return def;
}

+ (CGFloat)floatValue:(id)value {
     return [self floatValue:value def:NSNotFound];
}


+ (float)yx_roundFloat:(float)price andDeciPoint:(NSInteger)deciPoint {
    if (deciPoint == 0) {
        return (int)price;
    } else if ((deciPoint > 0)){
        int priceBasic = pow(10, deciPoint);
        return (floorf(price * priceBasic + 0.5)) / priceBasic;
    } else {
        return 0;
    }
}

+ (CGFloat)screenWidth {
    CGFloat screenWidth;
    if (!((YXAppDelegate *)YXConstant.sharedAppDelegate).rotateScreen) {
        screenWidth = MIN(YXConstant.screenWidth, YXConstant.screenHeight);
    } else {
        screenWidth = MAX(YXConstant.screenWidth, YXConstant.screenHeight);
    }
    return screenWidth;
}

+ (CGFloat)screenHeight {
    CGFloat screenHeight;
    if (!((YXAppDelegate *)YXConstant.sharedAppDelegate).rotateScreen) {
        screenHeight = MAX(YXConstant.screenWidth, YXConstant.screenHeight);
    } else {
        screenHeight = MIN(YXConstant.screenWidth, YXConstant.screenHeight);
    }
    return screenHeight;
}

//去除html格式 返回attributeString
+ (NSString * _Nullable)reverseTransformHtmlString:(NSString * _Nullable)htmlString {
    if (htmlString.length == 0) {
        return @"";
    }
    NSString * html = htmlString.length > 0 ? htmlString : @"";
    NSScanner * scanner = [NSScanner scannerWithString:htmlString];
       NSString * text = nil;
       while([scanner isAtEnd]==NO)
       {
           //找到标签的起始位置
           [scanner scanUpToString:@"<" intoString:nil];
           //找到标签的结束位置
           [scanner scanUpToString:@">" intoString:&text];
           //替换字符
           html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
       }
   //    NSString * regEx = @"<([^>]*)>";
   //    html = [html stringByReplacingOccurrencesOfString:regEx withString:@""];
       return html;
}
  


+ (void)saveImageToAlbum:(UIImage *)image completionHandler:(void (^ _Nullable)(BOOL result))completionHandler{
    if (image !=nil) {
       
        QMUIAssetAuthorizationStatus status = [QMUIAssetsManager authorizationStatus];
        if (status == QMUIAssetAuthorizationStatusNotDetermined) {
            [QMUIAssetsManager requestAuthorization:^(QMUIAssetAuthorizationStatus status) {
                if (status == QMUIAssetAuthorizationStatusAuthorized) {
                    [self _saveImage:image completionHandler:completionHandler];
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                       if (completionHandler) {
                           completionHandler(NO);
                       }
                    });
                }
            }];
        }else if (status == QMUIAssetAuthorizationStatusAuthorized){
            [self _saveImage:image completionHandler:completionHandler];
        }else{
            if (completionHandler) {
                completionHandler(NO);
            }
        }
    }
}

+ (void)_saveImage:(UIImage*)image completionHandler:(void (^ _Nullable)(BOOL result))completionHandler{
    QMUIImageWriteToSavedPhotosAlbumWithAlbumAssetsGroup(image, [[QMUIAssetsGroup alloc] initWithPHCollection:[YXToolUtility assetCollection]], ^(QMUIAsset *asset, NSError *error) {
        if (asset) {
            if (completionHandler) {
                completionHandler(YES);
            }
        }else {
            if (completionHandler) {
                completionHandler(NO);
            }
        }
    });
}
#pragma mark ---- 时间的处理
+ (NSString * _Nullable)compareCurrentTime:(NSString * _Nullable)timeStr
{
    if (timeStr.length == 0) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [NSDateFormatter en_US_POSIXFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate *timeDate = [dateFormatter dateFromString:timeStr];

    NSString *result;

    if (timeDate.isThisYear) {  //今年内
        //得到与当前时间差
        NSTimeInterval timeInterval = [timeDate timeIntervalSinceNow];
        timeInterval = -timeInterval;
        long temp = 0;

        if (timeDate.isToday) {
            if (timeInterval < 60) {  //1分钟内显示刚刚
             result = [YXLanguageUtility kLangWithKey:@"time_ganggang"];
            } else if (timeInterval < 120) {
                result = [YXLanguageUtility kLangWithKey:@"one_minute_pre"];
            } else if((temp = timeInterval/3600) < 1 ){ //1小时内
                if((temp = timeInterval/60) < 60){
                    result = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"time_minute_pre"],temp];
                }
            }else{ //大于1小时 小于1天
                result = [timeDate stringWithFormat:@"HH:mm"];
            }
        }else{
            result = [YXDateHelper commonDateString:timeStr format:YXCommonDateFormatDF_MDHM scaleType:YXCommonDateScaleTypeScale showWeek:NO];
        }

    }else{
        //跨年
       result = [YXDateHelper commonDateString:timeStr format:YXCommonDateFormatDF_MDYHM scaleType:YXCommonDateScaleTypeScale showWeek:NO];

    }

    return result;

}

+ (void)showCommentShareViewWithIsShowTopStatus:(BOOL)isShowTopStatus bizId:(NSString *)bizId shortUrl:(NSString * _Nullable)shortUrl image:(UIImage *) image {
}



+ (BOOL)checkPhotoAlbumPermissions {
     PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
     if (status == PHAuthorizationStatusRestricted ||
         status == PHAuthorizationStatusDenied) {
          return NO;
     }else {
          return YES;
     }
}

+ (BOOL)checkCameraAlbumPermissions {
     AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
     if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
          return NO;
     } else {
          return YES;
     }
}

+ (void)showCameraPermissionsAlertInVc:(UIViewController *)vc {
     NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
     NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
     NSString *title = [NSString stringWithFormat:@"“%@”想访问您的相机", appName];
     [self showPermissionsAlertInVc:vc title:title message:@"盈立智投需要您的同意才能使用相机"];
}

+ (void)showPermissionsAlertInVc:(UIViewController *)vc title:(NSString *)title message:(NSString *)message {
     
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"不允许" style:UIAlertActionStyleCancel handler:nil];
     UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
          
          UIApplication *application = [UIApplication sharedApplication];
          NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
          if ([application canOpenURL:url]) {
              [application openURL:url options:@{} completionHandler:nil];
          }
     }];
     [alertController addAction:cancelAction];
     [alertController addAction:defaultAction];
     if (vc) {
          [vc presentViewController:alertController animated:YES completion:nil];
     }
}

+ (NSArray *)getWidgetGroupData {
        
    NSMutableArray * datas = [[NSMutableArray alloc]init];
    
    for (YXSecuGroup *model in [YXSecuGroupManager shareInstance].allGroupsForShow) {

        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
        NSString * countStr = [NSString stringWithFormat:@"%lu",(unsigned long)model.list.count];
        [dic setObject:model.name forKey:@"name"];
        [dic setObject:countStr forKey:@"count"];
        [dic setObject:@(model.ID).stringValue forKey:@"groupId"];

        NSMutableArray * dataArr = [[NSMutableArray alloc]init];
        for (int k = 0; k < model.list.count; k++) {
            NSMutableDictionary * mudic = [[NSMutableDictionary alloc]init];
            YXSecuID * item =  model.list[k];
            [mudic setObject:item.market forKey:@"market"];
            [mudic setObject:item.symbol forKey:@"symbol"];
            [dataArr addObject:mudic];
        }
        [dic setObject:dataArr forKey:@"list"];
        [datas addObject:dic];
        NSLog(@"%@",datas);
    }

    return [datas copy];
    
}


//得到字节数函数
+ (int)stringConvertToInt:(NSString*)strtemp {
     int strlength = 0;
     char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
     for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++)
     {
          if (*p) {
               p++;
               strlength++;
          }
          else {
               p++;
          }
     }
     return strlength;
}

+ (NSRegularExpression *)stockDiscussImageSizeRegex {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\_[0-9]+?x[0-9]+?\\." options:kNilOptions error:NULL];
    });
    return regex;
}

+ (CGSize)findStockDiscussImageSizeWithUrl:(NSString *)url {
    NSRegularExpression *regex = [self stockDiscussImageSizeRegex];
    NSTextCheckingResult *match = [regex firstMatchInString:url options:0 range:NSMakeRange(0, [url length])];
    if (match) {
        NSString *matchsStr = [url substringWithRange:match.range];
        NSString *result = [matchsStr stringByReplacingOccurrencesOfString:@"_" withString:@""];
        NSString *final = [result stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSArray *arr = [final componentsSeparatedByString:@"x"];
        
        if (arr.count > 1) {
            NSString *widthStr = arr.firstObject;
            NSString *heightStr = arr.lastObject;
            
            return CGSizeMake(widthStr.floatValue, heightStr.floatValue);
        }
    }
    
    return CGSizeZero;
}

+(NSString *)moveEnterSymbol:(NSString *) text withString:(NSString *) value {
    NSString * temp = text;
    if (temp.length >  0) {
        temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:value];
    }
    
    return temp;
}

+ (NSString *)maxCharacterWithString:(NSString*)string maxCount:(NSInteger)count {
     
     for (int i = 0; i<=string.length; i++) {
          NSString *tempStr = [string substringToIndex:i];
          if ([YXToolUtility stringConvertToInt:tempStr] > count) {
               return [NSString stringWithFormat:@"%@...", [string substringToIndex:i-1]];
          }
     }
     return string;
}

+ (void)alertNoFullScreen:(UIViewController *)viewController; {
        
    viewController.view.frame = CGRectMake(0, 0, YXConstant.screenWidth, YXConstant.screenHeight - YXConstant.navBarHeight - 120);
    TYAlertController *alertViewController = [TYAlertController alertControllerWithAlertView:viewController.view preferredStyle:TYAlertControllerStyleActionSheet];
    alertViewController.backgoundTapDismissEnable = YES;
    [alertViewController addChildViewController:viewController];
        
    [[UIViewController currentViewController] presentViewController:alertViewController animated:YES completion:^{
        
    }];
}

+ (UIImage * _Nullable)normalSnapShotImage:(CALayer * _Nonnull)layer {
    if (layer == nil) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, [UIScreen mainScreen].scale);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

+ (UIImage *)createCodeImage:(NSString *)codeString {
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2、恢复滤镜的默认属性
    [filter setDefaults];
    // 3、设置内容
    NSData *data = [codeString dataUsingEncoding:NSUTF8StringEncoding];
    // 使用KVO设置属性
    [filter setValue:data forKey:@"inputMessage"];
    // 4、获取输出文件
    CIImage *outputImage = [filter outputImage];
    // 5、显示二维码
    UIImage *image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:500.0f];

    return [self createQRCodeWithImage:image logoImage:[UIImage imageNamed:@"logo_60"] ratio:0.2];
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(cs);
    UIImage *imageResult = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return imageResult;
}

+ (UIImage *)createQRCodeWithImage:(UIImage *)image logoImage:(UIImage *)logoImage ratio:(CGFloat)ratio {
    if (logoImage == nil) return image;
    if (ratio < 0.0 || ratio > 0.5) {
        ratio = 0.25;
    }
    CGFloat logoImageW = ratio * image.size.width;
    CGFloat logoImageH = ratio * image.size.height;
    CGFloat logoImageX = 0.5 * (image.size.width - logoImageW);
    CGFloat logoImageY = 0.5 * (image.size.height - logoImageH);
    CGRect logoImageRect = CGRectMake(logoImageX, logoImageY, logoImageW, logoImageH);
    // 绘制logo
    UIGraphicsBeginImageContextWithOptions(image.size, false, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [logoImage drawInRect:logoImageRect];
    UIImage *QRCodeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return QRCodeImage;
}

+(BOOL) needFinishQuoteNotify {
    if ((([[YXUserManager shared] extendStatusBit] & YXExtendStatusBitTypeHqAuthority) != YXExtendStatusBitTypeHqAuthority) &&
        [YXUserManager isLogin]) {
        return YES;
    }
    return NO;
}

//是否跳过行情声明
+(BOOL) isJumpOverQuoteNotify {
    if (([[YXUserManager shared] extendStatusBit] & YXOrgStatusBitOtherTypeQuoteStatement) == YXOrgStatusBitOtherTypeQuoteStatement) {
        return YES;
    }
    return NO;
}

+ (NSString *)getQuoteExchangeEnName:(int64_t)exchangeId {
    NSString *exchangeStr = @"--";
    if (exchangeId == OBJECT_MARKETExchange_Nasdaq) {
        exchangeStr = @"NASDAQ";
    } else if (exchangeId == OBJECT_MARKETExchange_Nyse) {
        exchangeStr = @"NYSE";
    } else if (exchangeId == OBJECT_MARKETExchange_Arca) {
        exchangeStr = @"ARCA";
    } else if (exchangeId == OBJECT_MARKETExchange_Amex) {
        exchangeStr = @"AMEX";
    } else if (exchangeId == OBJECT_MARKETExchange_Bats) {
        exchangeStr = @"BATS";
    } else if (exchangeId == OBJECT_MARKETExchange_Otc) {
        exchangeStr = @"OTC";
    } else if (exchangeId == OBJECT_MARKETExchange_Iex) {
        exchangeStr = @"IEX";
    } else if (exchangeId == OBJECT_MARKETExchange_Finra) {
        exchangeStr = @"FINRA";
    } else if (exchangeId == OBJECT_MARKETExchange_Edgx) {
        exchangeStr = @"EDGX";
    } else if (exchangeId == OBJECT_MARKETExchange_Bzx) {
        exchangeStr = @"BZX";
    } else if (exchangeId == OBJECT_MARKETExchange_Iex) {
        exchangeStr = @"IEX";
    } else if (exchangeId == OBJECT_MARKETExchange_Memx) {
        exchangeStr = @"MEMX";
    } else if (exchangeId == OBJECT_MARKETExchange_Bx) {
        exchangeStr = @"BX";
    } else if (exchangeId == OBJECT_MARKETExchange_Edga) {
        exchangeStr = @"EDGA";
    } else if (exchangeId == OBJECT_MARKETExchange_Psx) {
        exchangeStr = @"PSX";
    } else if (exchangeId == OBJECT_MARKETExchange_Byx) {
        exchangeStr = @"BYX";
    } else if (exchangeId == OBJECT_MARKETExchange_Nsx) {
        exchangeStr = @"NSX";
    } else if (exchangeId == OBJECT_MARKETExchange_Miax) {
        exchangeStr = @"MIAX";
    } else if (exchangeId == OBJECT_MARKETExchange_Chx) {
        exchangeStr = @"CHX";
    }

    return exchangeStr;
}

@end

