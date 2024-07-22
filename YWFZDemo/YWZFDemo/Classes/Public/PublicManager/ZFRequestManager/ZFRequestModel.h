//
//  ZFReuqestModel.h
//  ZZZZZ
//
//  Created by YW on 2018/5/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFNetworkRequestModel.h"
#import "ZFNetwork.h"
#import "ZFApiDefiner.h"
#import "ZFBaseViewController.h"
#import <GGBrainKeeper/BKSpanModel.h>

@interface ZFRequestModel : ZFNetworkRequestModel

#pragma mark ----------- 链路监控参数 -------------
/// 请求所属的控制器
@property (nonatomic, weak) id taget;
/// 接口链路过程对象
@property (nonatomic, strong)  BKSpanModel *span;
/// 是否自动提交链路,默认自动提交
@property (nonatomic, assign) BOOL notAutoSubmit;
/// 是否为链式请求, 默认为否
@property (nonatomic, assign) BOOL isChained;
/// 链路名称 (事件链路时可传可不传，页面链路不需要传)
@property (nonatomic, copy) NSString *pageName;
/// 链路事件名称 (事件链路时传，页面链路不需要传) 该字段用于区分页面链路与事件链路
@property (nonatomic, copy) NSString *eventName;

#pragma mark ----------- 链路监控参数 -------------

/// 控制接口是否加公共参数, (公共参数存在差异性无法CDN缓存需求,因此需要在页面上单独控制)
@property (nonatomic, assign) BOOL forbidAddPublicArgument;


@end
