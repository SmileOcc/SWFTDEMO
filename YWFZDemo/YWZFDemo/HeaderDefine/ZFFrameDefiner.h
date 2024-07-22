//
//  ZFFrameDefiner.h
//  ZZZZZ
//
//  Created by YW on 2018/3/30.
//  Copyright © 2018年 YW. All rights reserved.
//

#ifndef ZFFrameDefiner_h
#define ZFFrameDefiner_h

#pragma mark -===========================屏幕分辨率大小=============================
// 屏幕大小
#define KScale                          [UIScreen mainScreen].scale
#define MIN_PIXEL                       (1.0 / KScale)
#define KScreenWidth                    [UIScreen mainScreen].bounds.size.width
#define KScreenHeight                   [UIScreen mainScreen].bounds.size.height
#define ScreenHeight_SCALE              (KScreenHeight / 568.0)
#define ScreenWidth_SCALE               (KScreenWidth / 375.0)

#define KImage_SCALE                    0.75
#define KImageFadeDuration              0.5

#define IPHONE_4X_3_5                   (KScreenHeight==480.0f)
#define IPHONE_5X_4_0                   (KScreenHeight==568.0f)
#define IPHONE_6X_4_7                   (KScreenHeight==667.0f)
#define IPHONE_6P_5_5                   (KScreenHeight==736.0f || KScreenWidth==414.0f)
#define IPHONE_7P_5_5                   (KScreenHeight==736.0f)
#define IPHONE_X_5_15                   (KScreenHeight >= 812.0f)

#define NAVBARHEIGHT                    self.navigationController.navigationBar.frame.size.height
#define STATUSHEIGHT                    [UIApplication sharedApplication].statusBarFrame.size.height
#define TabBarHeight                    self.tabBarController.tabBar.bounds.size.height
/** 判断iphoneX 底部间距*/
#define kiphoneXHomeBarHeight           (IPHONE_X_5_15 ? 34 : 0)
/** 判断iphoneX 顶部间距*/
#define kiphoneXTopOffsetY              (IPHONE_X_5_15 ? 44.0f : 20.0f)

#define NavBarButtonSize                (36.0)

// 3列商品Cell的图片宽度
#define ThreeColumnGoodsImageWidth      (109 * ScreenWidth_SCALE)
// 3列商品Cell的图片高度
#define ThreeColumnGoodsImageHeight     (145 * ScreenWidth_SCALE)


#define EmptyViewTag                    8870

//社区首页布瀑流宽度
#define kCommunityHomeWaterfallWidth    (KScreenWidth - 10*3) / 2

// CMS 所有价格的高度
#define kGoodsPriceHeight               40.0
#define kHistorSkuHeaderHeight          40.0

#define kSecKillSkuHeaderHeight         50.0

// Cell的默认高度
#define kCellDefaultHeight              44.0

// 显示商品图片的宽高比 (间距为12一行显示3个商品)
#define kGoodsImageRatio                (3.0/4.0)

// 间距
#define kMarginSpace8                   8.0
#define kMarginSpace12                  12.0
#define kMarginSpace16                  16.0

#endif /* ZFFrameDefiner_h */
