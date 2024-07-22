//
//  ZFCommunityPostResultModel.h
//  ZZZZZ
//
//  Created by YW on 2018/4/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFCommunityPostResultModel : NSObject

@property (nonatomic, copy) NSString                *msg;
@property (nonatomic, copy) NSString                *contact_us;
@property (nonatomic, assign) BOOL                  is_show_popup;
@property (nonatomic, copy) NSString                *goodsId;
@property (nonatomic, copy) NSString                *reviewId;
@property (nonatomic, copy) NSString                *code;
@property (nonatomic, copy) NSString                *errors;

@end
