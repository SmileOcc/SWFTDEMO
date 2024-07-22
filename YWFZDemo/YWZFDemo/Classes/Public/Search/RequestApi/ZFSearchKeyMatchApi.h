//
//  ZFSearchKeyMatchApi.h
//  ZZZZZ
//
//  Created by YW on 2017/12/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface ZFSearchKeyMatchApi : SYBaseRequest
- (instancetype)initSearchResultApiWithSearchString:(NSString *)searchString;
@end
