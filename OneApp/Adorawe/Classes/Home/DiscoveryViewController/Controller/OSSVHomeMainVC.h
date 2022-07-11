//
//  OSSVHomeMainVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"

@interface OSSVHomeMainVC : STLBaseCtrl

@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, copy) NSString *channelName_en;
@property (nonatomic, copy) NSString *channel_id;

// 滑动时是否显示右下角小浮窗
@property (nonatomic, copy) void (^showFloatBannerBlock)(BOOL show);
@property (nonatomic, copy) void (^requestCompleteBlock)(BOOL state);

@property (nonatomic, assign) NSInteger   index;
@property (nonatomic, assign) BOOL        isCache;
@end
