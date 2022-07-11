//
//  HotSearchWordApi.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVHotsSearchsWordsAip : OSSVBasesRequests

- (instancetype)initWithGroupId:(NSString *)groupId cateId:(NSString *)cateId;

@end
