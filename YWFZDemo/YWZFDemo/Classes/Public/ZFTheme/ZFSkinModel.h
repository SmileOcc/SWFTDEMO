//
//  ZFSkinModel.h
//  ZZZZZ
//
//  Created by YW on 2018/5/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"

/**
 首页换肤模型
 */
@interface ZFSkinModel : NSObject <YYModel, NSCoding>

// 当前国家id
@property (nonatomic, strong) NSString *countryId;
// 多个国家id, 分逗号隔开
@property (nonatomic, strong) NSString *countries;


// 主页自定义顶部导航栏
@property (nonatomic, copy) NSString *bgImg;
@property (nonatomic, assign) NSInteger bgUseType;  // 1 颜色 2 图片
@property (nonatomic, copy) NSString *bgColor;
@property (nonatomic, copy) NSString *cartIcon;
@property (nonatomic, copy) NSString *searchIcon;
@property (nonatomic, copy) NSString *homeLogoIcon;



// 子页面系统顶部导航栏
@property (nonatomic, copy) NSString *navBgImageUrl;
@property (nonatomic, copy) NSString *accountHeadImageUrl;
@property (nonatomic, copy) NSString *navColor;
@property (nonatomic, copy) NSString *navFontColor;
@property (nonatomic, copy) NSString *navIconColor;
@property (nonatomic, strong) NSNumber *subNavStatusBarType;//(0:黑色, 1:白色)
@property (nonatomic, strong) NSNumber *homeNavStatusBarType;//(0:黑色, 1:白色)



// tabbar
@property (nonatomic, copy) NSString *bottomImg;
@property (nonatomic, copy) NSString *bottomColor;
@property (nonatomic, assign) NSInteger bottomUseType; // 1 颜色 2 图片


@property (nonatomic, copy) NSString *categoryIcon;
@property (nonatomic, copy) NSString *categoryIconOn;
@property (nonatomic, copy) NSString *communityIcon;
@property (nonatomic, copy) NSString *communityIconOn;
@property (nonatomic, copy) NSString *personalIcon;
@property (nonatomic, copy) NSString *personalIconOn;
@property (nonatomic, copy) NSString *zomeIcon;
@property (nonatomic, copy) NSString *zomeIconOn;

@property (nonatomic, copy) NSString *channelBackColor;
@property (nonatomic, copy) NSString *lange;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, copy) NSString *theme;
@property (nonatomic, copy) NSString *lastUpdateTime;
@property (nonatomic, assign) NSInteger ID;

/// V4.4.0 增加频道字体颜色
@property (nonatomic, copy) NSString *channelSelectedColor;
@property (nonatomic, copy) NSString *channelTextColor;


/// 自定义 若是YES，皮肤则不请求，默认 NO
@property (nonatomic, assign) BOOL hasRepeatSkin;


@end



@interface ZFLoadSkinModel : NSObject

@property (nonatomic, copy) NSString    *imageUrl;
@property (nonatomic, assign) BOOL      loading;

@end
