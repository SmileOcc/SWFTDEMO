//
//  ZFCommunityTopicDetailApi.h
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"
//未使用，已废弃
@interface ZFCommunityTopicDetailApi : SYBaseRequest

- (instancetype)initWithcurPage:(NSInteger)curPage pageSize:(NSString*)pageSize topicId:(NSString *)topicId sort:(NSString *)sort;

@end
