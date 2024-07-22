//
//  ZFFullReductionViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/9/20.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFFullReductionViewModel : NSObject

/**
 * 获取详情页满减活动列表商品列表
 */
- (void)requestFullReductionData:(BOOL)isFirstPage
                        reduc_id:(NSString *)reduc_id
                   activity_type:(NSString *)activity_type
                  finishedHandle:(void (^)(NSArray *goodsArray, NSDictionary *pageDict))finishedHandle;

@end
