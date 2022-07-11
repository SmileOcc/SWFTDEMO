//
//  STLTabbarModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLNaviModel.h"
#import "STLTabbarIconModel.h"
#import "STLAccountBackgroundModel.h"

#define DownLoadSuccess @"DownLoadSuccess"
#define TabbarDownLoadSuccess @"TabbarDownLoadSuccess"
#define NaviBarDownLoadSuccess @"NaviBarDownLoadSuccess"
#define AccountDownLoadSuccess @"AccountDownLoadSuccess"

@interface STLTabbarModel : NSObject

@property (nonatomic, strong)NSString                   *start_time;
@property (nonatomic, strong)NSString                   *end_time;
@property (nonatomic, strong)NSString                   *divider_line_color;

@property (nonatomic, strong)STLNaviModel               *title_bar;
@property (nonatomic, strong)STLAccountBackgroundModel  *my_header;
@property (nonatomic, strong)STLTabbarIconModel         *body;

@property (nonatomic, assign)BOOL isCache;
@property (nonatomic, assign)BOOL isNeedUpdateAccount;

///是否下载完tabbar图片 YES加载完 NO没有加载完
@property (nonatomic, assign) BOOL isDownLoadTabbarIcon;

///是否下载完navi图片 YES加载完 NO没有加载完
@property (nonatomic, assign) BOOL isDownLoadNaviIcon;

///是否下载完account YES加载完 NO没有加载完
@property (nonatomic, assign) BOOL isDownLoadAccountIcon;

@end
