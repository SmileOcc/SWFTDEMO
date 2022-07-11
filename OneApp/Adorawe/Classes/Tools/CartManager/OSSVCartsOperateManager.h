//
//  OSSVCartsOperateManager.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CartModel,CommendModel;
@interface OSSVCartsOperateManager : NSObject
+ (OSSVCartsOperateManager *)sharedManager;

//购物车有效商品种类
//- (void)cartSaveValidGoodsCount:(NSInteger)count;
//- (NSInteger)cartValidGoodsCount;

//购物车有效商品种类
- (void)cartSaveValidGoodsAllCount:(NSInteger)count;
- (NSInteger)cartValidGoodsAllCount;

//存储购物车对象
- (void)saveCart:(CartModel *)cartModel completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

//移除本地购物车对象
- (BOOL)removeLocalCart:(CartModel *)cartModel;
//清空购物车对象
- (BOOL)removeAllCart;
//更新购物车对象--选中字段的更新
- (BOOL)updateLocalCart:(CartModel *)cartModel;
//更新购物车对象
//- (void)updateCart:(NSArray<CartModel*> *)cartModels showView:(UIView *)showView completion:(void (^)(id obj))completion;
//更新购物车对象
- (void)updateLocalCartList:(NSArray *)cartList;
//同步购物车数据
- (void)cartSyncServiceDataGoods:(NSArray<CartModel*> *)goods showView:(UIView *)showView Completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

//取消选中购物车数据
- (void)cartUncheckServiceDataGoods:(NSArray *)cartIds showView:(UIView *)showView Completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

//推荐商品列表
- (NSArray *)commendList;
//添加推荐商品
- (BOOL)saveCommend:(CommendModel *)commendModel;

@end

@interface OperationTempModel : NSObject
@property (nonatomic,copy) NSString *goods_id;
@property (nonatomic,assign) NSInteger goods_number;
@property (nonatomic,copy) NSString *wid;
@property (nonatomic,copy) NSString *last_modify;
@property (nonatomic,assign) NSInteger flag;

- (instancetype)initWithCartModel:(CartModel *)cartModel;

@end
