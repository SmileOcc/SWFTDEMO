//
//  CartOperationManager.h
//  Yoshop
//
//  Created by YW on 16/6/6.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CartModel,CommendModel;
@interface CartOperationManager : NSObject
+ (CartOperationManager *)sharedManager;

//推荐商品列表
- (NSArray *)commendList;

//推荐商品列表
- (NSArray *)recentList;

//添加推荐商品
- (BOOL)saveCommend:(CommendModel *)commendModel;

//更新推荐商品
- (void)updateCommend:(CommendModel *)commendModel;

@end
