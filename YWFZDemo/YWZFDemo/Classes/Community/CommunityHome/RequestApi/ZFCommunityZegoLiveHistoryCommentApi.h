//
//  ZFCommunityZegoLiveHistoryCommentApi.h
//  ZZZZZ
//
//  Created by YW on 2019/8/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "SYBaseRequest.h"


NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityZegoLiveHistoryCommentApi : SYBaseRequest

- (instancetype)initWithLiveID:(NSString *)liveID page:(NSString *)curPage pageSize:(NSString *)pageSize;
@end

NS_ASSUME_NONNULL_END
