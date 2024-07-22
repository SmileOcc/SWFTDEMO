//
//  ZFCommunityLabelDetailApi.h
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface ZFCommunityLabelDetailApi : SYBaseRequest
- (instancetype)initWithcurPage:(NSInteger)curPage pageSize:(NSString*)pageSize topicLabel:(NSString *)topicLabel;

@end
