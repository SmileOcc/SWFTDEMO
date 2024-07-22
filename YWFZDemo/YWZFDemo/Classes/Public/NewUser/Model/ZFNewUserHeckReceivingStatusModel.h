//
//  ZFNewUserHeckReceivingStatusModel.h
//  ZZZZZ
//
//  Created by mac on 2019/1/14.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFNewUserHeckReceivingStatusModel : NSObject
/** 0:领取成功 1:领取失败 2:已领取过 3:未登录 4:已领取 5:老用户 */
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *rules;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *instructions;

@end

NS_ASSUME_NONNULL_END
