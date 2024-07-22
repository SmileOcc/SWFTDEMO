//
//  ZFUpgradeModel.h
//  ZZZZZ
//
//  Created by YW on 2018/12/22.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFUpgradeModel : NSObject

@property (nonatomic, copy) NSString *is_forced;//是否强制更新 1 是 0 不是
@property (nonatomic, copy) NSString *show_update_time;//弹窗次数 1 仅提醒一次，2 每天提醒一次，4一直提醒
@property (nonatomic, copy) NSString *show_update;//是否提示 1 是 0 不是
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *upgradeDesc;
@end

NS_ASSUME_NONNULL_END
