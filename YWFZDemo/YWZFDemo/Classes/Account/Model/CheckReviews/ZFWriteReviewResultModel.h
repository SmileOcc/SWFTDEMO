//
//  ZFWriteReviewResultModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFOrderReviewInfoModel.h"

@interface ZFWriteReviewResultModel : NSObject
@property (nonatomic, copy)   NSString                            *msg;
@property (nonatomic, strong) ZFOrderReviewInfoModel              *review;
@property (nonatomic, assign) BOOL                                is_show_popup;
@property (nonatomic, copy)   NSString                            *contact_us;
@property (nonatomic, assign) NSInteger                           error;
@end
