//
//  ZFCMSSectionModel.m
//  ZZZZZ
//
//  Created by YW on 2018/12/8.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCMSSectionModel.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFBannerModel.h"
#import "ZFApiDefiner.h"
#import "ZFAccountRecentlyCCell.h"

@implementation ZFCMSItemModel


+ (CGFloat)cmsCouponSpace {
    return 10;
}
// 自定义
+ (CGFloat)cmsCouponWidth:(CGFloat)width calculatHeight:(NSInteger)count {
    if (width <= 0) {
        width = KScreenWidth - 12;
    }
    
    CGFloat height = 0;
    if (count == 1 || count == 2) {
        height = width * 90.0 / 353.0;
    } else if (count == 3) {
        width = (width - 2 * [ZFCMSItemModel cmsCouponSpace]) / 3.0;
        height = width * 94.0 / 111.0;
    } else if(count == 4) {
        width = (width - 3 * [ZFCMSItemModel cmsCouponSpace]) / 4.0;
        height = width * 76.0 / 81.0;
    }
    if (height <= 0) {
        height = 0;
    }
    return height;
}
@end


@implementation ZFCMSAttributesModel

//防止数据异常: 显示几列
- (NSInteger)text_size {
    if (_text_size <= 10) {
        return 10;
    }
    if (_text_size > 25) {
        return 25;
    }
    return _text_size;
}

//防止为空: 给一个默认文案
- (NSString *)text {
    if (!_text || ZFIsEmptyString(_text)) {
        return @"";//ZFLocalizedString(@"native_banner_share", nil);
    }
    return _text;
}

// 文本颜色 默认颜色
- (UIColor *)textColor {
    if (!_textColor) {
        return [UIColor blackColor];
    }
    return _textColor;
}

// 文本Sale颜色，默认黑色
- (UIColor *)textSaleColor {
    if (!_textSaleColor) {
        return [UIColor blackColor];
    }
    return _textSaleColor;
}

// 组件的背景色 默认颜色
- (UIColor *)bgColor {
    if (!_bgColor) {
        return ZFCOLOR_WHITE;
    }
    return _bgColor;
}

@end




@implementation ZFCMSSectionModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"list"        : [ZFCMSItemModel class],
             @"attributes"  : [ZFCMSAttributesModel class],
             };
}

// 防止数据异常: 显示几列
-(NSString *)display_count{
    if ([_display_count isEqualToString:@"0"] || ZFIsEmptyString(_display_count)) {
        return @"1";
    } else {
        CGFloat value = [_display_count floatValue];
        if (value < 0) {
            return @"1";
        }
    }
    return _display_count;
}

// 防止数据异常: 图片宽高比 - 宽
-(NSString *)prop_w{
    if ([_prop_w isEqualToString:@"0"] || ZFIsEmptyString(_prop_w)) {
        return [NSString stringWithFormat:@"%f",KScreenWidth];
    } else {
        CGFloat value = [_prop_w floatValue];
        if (value < 0) {
            return [NSString stringWithFormat:@"%f",KScreenWidth];
        }
    }
    return _prop_w;
}

// 防止数据异常: 图片宽高比 - 高
-(NSString *)prop_h{
    if ([_prop_h isEqualToString:@"0"] || ZFIsEmptyString(_prop_h)) {
        return [NSString stringWithFormat:@"%f",KScreenWidth];
    } else {
        CGFloat value = [_prop_h floatValue];
        if (value < 0) {
            return [NSString stringWithFormat:@"%f",KScreenWidth];
        }
    }
    return _prop_h;
}

// 组件的背景色 默认颜色
- (UIColor *)bgColor {
    if (!_bgColor) {
        return ZFCOLOR_WHITE;
    }
    return _bgColor;
}

// 配置Deeplink跳转模型
- (ZFBannerModel *)configDeeplinkBannerModel {
    if (self.list.count <= 0) return nil;
    ZFCMSItemModel *itemModel = self.list[0];
    
    ZFBannerModel *bannerModel = [[ZFBannerModel alloc] init];
    bannerModel.image = itemModel.image;
    bannerModel.banner_width = self.prop_w;
    bannerModel.banner_height = self.prop_h;
    bannerModel.name = itemModel.name;
    
    //如果actionType=-2,则特殊处理自定义完整ddeplink
    if (itemModel.actionType.integerValue == -2) {
        bannerModel.deeplink_uri = ZFToString(ZFEscapeString(itemModel.url, YES));
    } else {
        bannerModel.deeplink_uri = [NSString stringWithFormat:ZFCMSConvertDeepLinkString, ZFToString(itemModel.actionType), ZFToString(ZFEscapeString(itemModel.url, YES)),  ZFToString(itemModel.name)];
    }
    return bannerModel;
}

@end
