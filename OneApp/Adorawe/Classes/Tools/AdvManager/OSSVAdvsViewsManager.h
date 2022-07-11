//
//  OSSVAdvsViewsManager.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVAdvsEventsModel.h"
#import "OSSVHomesActivtyAdvView.h"
#import "OSSVHomesBottomAdvsView.h"


@interface OSSVAdvsViewsManager : NSObject

+ (OSSVAdvsViewsManager *)sharedManager;

@property (nonatomic, strong) OSSVAdvsEventsModel              *lastDeeplinkModel;

/** =================== 强制 =================== */
@property (nonatomic, assign) BOOL                          isUpdateApp;
/**必须更新*/
@property (nonatomic, assign) BOOL                          is_force;
@property (nonatomic, assign) BOOL                          isLaunchAdv;

/**更新市场地址*/
@property (nonatomic, copy) NSString                        *trackUrl;
@property (nonatomic, copy) NSString                        *updateContent;

/** =================== 欧盟判断 =================== */
@property (nonatomic, assign) BOOL                          isEU;
@property (nonatomic, assign) BOOL                          isEURequrestSuccess;



/**广告源*/
@property (nonatomic, strong) NSMutableArray                *advsArray;
/**是否不显示 默认：NO 显示*/
@property (nonatomic, assign, readonly) BOOL                isNotShowAdv;
/**是否通过首页，修改isNotShowAdv状态*/
@property (nonatomic, assign) BOOL                          isAcrossHome;
/**结束标识*/
@property (nonatomic, assign) BOOL                          isEndSheetAdv;

@property (nonatomic, assign) BOOL                          isDidShowHomeBanner;

@property (nonatomic, strong) OSSVAdvsEventsModel                     *currentModel;
@property (nonatomic, strong) OSSVHomesActivtyAdvView           *currentAdvView;
@property (nonatomic, strong) OSSVHomesBottomAdvsView       *bannerView;

// 显示弹窗
- (void)showAdv:(BOOL)isShow startOpen:(BOOL)start;

- (void)showAdvEventModel:(OSSVAdvsEventsModel *)model;

- (void)removeHomeAdv;

// 显示更新
- (void)updateAppState:(NSDictionary *)dic;
- (void)goUpdateApp;

#pragma mark ---- 显示首页底部banner
- (void)handleHomeBottomBanner;
@end
