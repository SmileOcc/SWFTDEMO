//
//  ZFLiveRemindApi.h
//  ZZZZZ
//
//  Created by YW on 2019/12/23.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "SYBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFLiveRemindApi : SYBaseRequest

- (instancetype)initWithLiveID:(NSString *)liveID;
@end

NS_ASSUME_NONNULL_END
