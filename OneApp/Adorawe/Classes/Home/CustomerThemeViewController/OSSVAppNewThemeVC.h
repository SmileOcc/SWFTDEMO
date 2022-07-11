//
//  OSSVAppNewThemeVC.h
// OSSVAppNewThemeVC
//
//  Created by odd on 2021/3/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSAPPThemesMainView.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVAppNewThemeVC : STLBaseCtrl

@property (nonatomic, copy) NSString *customId;  //专题ID
@property (nonatomic, copy) NSString *deepLinkId;  //由deeplink生成的ID  用于后台在数据中插入广告数据
@property (nonatomic, copy) NSString *customName;

// 滑动时是否显示右下角小浮窗
@property (nonatomic, copy) void (^showFloatBannerBlock)(BOOL show);

// 滑动时是否显示顶部搜索框视图
@property (nonatomic, copy) void (^showFloatInputBarBlock)(BOOL show, CGFloat offsetY);
@end

NS_ASSUME_NONNULL_END
