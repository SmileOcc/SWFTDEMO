//
//  CheckReviewApi.h
//  ZZZZZ
//
//  Created by DBP on 16/12/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface CheckReviewApi : SYBaseRequest
- (instancetype)initWithGoodsSn:(NSString *)goodsSn;
@end