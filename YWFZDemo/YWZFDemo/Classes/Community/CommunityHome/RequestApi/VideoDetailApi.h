//
//  VideoDetailApi.h
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface VideoDetailApi : SYBaseRequest

- (instancetype)initWithVideoId:(NSString*)videoId;

@end