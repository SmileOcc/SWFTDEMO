//
//  ZFCommunityFavesApi.h
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface ZFCommunityFavesApi : SYBaseRequest

- (instancetype)initWithcurrentPage:(NSInteger)currentPage listUserId:(NSString *)listUserId;

@end
