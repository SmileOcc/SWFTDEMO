//
//  ZFHomeCMSViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/12/8.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFBannerModel.h"

@class ZFCMSSectionModel, ZFBTSModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFHomeCMSViewController : ZFBaseViewController

@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, copy) NSString *firstChannelId;//第一个频道ChannelId

@property (nonatomic, strong) ZFBTSModel *btsModel;

//第一个频道的列表数据
@property (nonatomic, strong) NSArray<ZFCMSSectionModel *> *homeSectionModelArr;

// 滑动时是否显示右下角小浮窗
@property (nonatomic, copy) void (^showFloatBannerBlock)(BOOL show);

// 滑动时是否显示顶部搜索框视图
@property (nonatomic, copy) void (^showFloatInputBarBlock)(BOOL show, CGFloat offsetY);

@end

NS_ASSUME_NONNULL_END
