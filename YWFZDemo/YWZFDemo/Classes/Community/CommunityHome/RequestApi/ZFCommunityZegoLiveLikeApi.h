//
//  ZFCommunityZegoLiveLikeApi.h
//  ZZZZZ
//
//  Created by YW on 2019/8/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "SYBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityZegoLiveLikeApi : SYBaseRequest

- (instancetype)initWithLiveID:(NSString *)liveID isLive:(NSString *)isLive nickname:(NSString *)nickname phase:(NSString *)phase;

@end

NS_ASSUME_NONNULL_END
