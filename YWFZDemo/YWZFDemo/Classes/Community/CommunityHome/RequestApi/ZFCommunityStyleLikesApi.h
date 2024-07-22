//
//  ZFCommunityStyleLikesApi.h
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface ZFCommunityStyleLikesApi : SYBaseRequest
- (instancetype)initWithUserid:(NSString *)userid currentPage:(NSInteger)currentPage;
@end
