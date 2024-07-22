//
//  ZFCommunityHomeCMSViewAOP.h
//  ZZZZZ
//
//  Created by YW on 2019/6/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnalyticsInjectManager.h"
#import <UIKit/UIKit.h>


@interface ZFCommunityHomeCMSViewAOP : NSObject
<
ZFAnalyticsInjectProtocol
>

///如果不为空就是首页，为空就是推荐分区
@property (nonatomic, assign) BOOL isHomePage;

///首页推荐商品实验id
@property (nonatomic, strong) NSDictionary *af_params;

///channel_id
@property (nonatomic, copy) NSString *channel_id;

///频道名
@property (nonatomic, copy) NSString *channel_name;

@end

