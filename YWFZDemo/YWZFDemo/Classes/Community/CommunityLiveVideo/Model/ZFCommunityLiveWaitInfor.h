//
//  ZFCommunityLiveWaitInfor.h
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveWaitInfor : NSObject

/** 倒计时秒*/
@property (nonatomic, copy) NSString *time;
/** 活动文案*/
@property (nonatomic, copy) NSString *content;
/** 倒计时标识key*/
@property (nonatomic, copy) NSString *startTimerKey;

@end

NS_ASSUME_NONNULL_END
