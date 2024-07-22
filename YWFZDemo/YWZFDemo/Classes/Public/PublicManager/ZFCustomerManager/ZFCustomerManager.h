//
//  ZFCustomerManager.h
//  ZZZZZ
//
//  Created by YW on 2018/6/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFCustomerManager : NSObject

+ (instancetype)shareInstance;

/**
 * 弹出客服聊天页面 (可选: 携带商品信息, 没有传空串 @"")
 */
- (void)presentLiveChatWithGoodsInfo:(NSString *)goodsInfo;

@end
