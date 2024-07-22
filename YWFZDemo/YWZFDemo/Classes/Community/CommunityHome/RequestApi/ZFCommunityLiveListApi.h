//
//  ZFCommunityLiveListApi.h
//  ZZZZZ
//
//  Created by YW on 2019/4/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "SYBaseRequest.h"
#import "YWLocalHostManager.h"
#import "ZFApiDefiner.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveListApi : SYBaseRequest

- (instancetype)initWithcurPage:(NSInteger)curPage pageSize:(NSInteger)pageSize;

@end

NS_ASSUME_NONNULL_END
