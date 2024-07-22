//
//  ZFFreeGiftsViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/5/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFFreeGiftsViewModel : NSObject
/*
 * 请求赠品列表信息
 */
+ (void)requestFreeGiftListNetwork:(id)parmaters
                        completion:(void (^)(NSMutableArray *dataArray))completion
                           failure:(void (^)(id obj))failure;

@end
