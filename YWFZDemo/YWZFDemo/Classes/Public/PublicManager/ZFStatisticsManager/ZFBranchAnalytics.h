//
//  ZFBranchAnalytics.h
//  ZZZZZ
//
//  Created by YW on 2019/3/26.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GoodsDetailModel,ZFOrderCheckDoneDetailModel,ZFOrderCheckInfoDetailModel,ZFBaseOrderModel,BranchUniversalObject;

@interface ZFBranchAnalytics : NSObject

+ (ZFBranchAnalytics *)sharedManager;

/**
 登录
 */
- (void)branchLoginWithUserId:(NSString *)userId;
/**
 登出
 */
- (void)branchLogout;
/**
 Complete Registration
 
 @param type 注册类型
 */
- (void)branchCompleteRegistrationType:(NSString *)type;
/**
 Complete Login
 
 @param type 登陆类型
 */
- (void)branchLoginType:(NSString *)type;
/**
 搜索事件
 @param searchKey 搜索词
 */
- (void)branchSearchEvenWithSearchKey:(NSString *)searchKey  searchType:(NSString *)searchType;
/**
 商品详情展示
 @param product 商品
 */
- (void)branchViewItemDetailWithProduct:(GoodsDetailModel *)product;
/**
 加入购物车事件
 
 @param product 商品
 */
- (void)branchAddToCartWithProduct:(GoodsDetailModel *)product number:(NSInteger)number;
/**
 订单确认事件 checkout
 */
- (void)branchProcessToPayWithCheckModel:(ZFOrderCheckInfoDetailModel *)checkOutModel;
/**
 创建订单成功事件
 
 @param goodsArray 订单商品列表
 @param orderSn 订单号
 */
- (void)branchInitiatePurchaseWithCheckModel:(ZFOrderCheckDoneDetailModel *)checkDoneModel checkoutModel:(ZFOrderCheckInfoDetailModel *)checkOutModel;
/**
 订单结算统计
 
 @param goodsList 订单商品列表
 */
- (void)branchAnalyticsOrderModel:(ZFBaseOrderModel *)orderModel goodsList:(NSMutableArray<BranchUniversalObject *> *)goodsList;
/**
 社区帖子浏览
 
 @param postId 帖子ID
 @param postType 帖子类型
 */
- (void)branchAnalyticsPostViewWithPostId:(NSString *)postId postType:(NSString *)postType;
/**
 帖子点赞
 
 @param postId 帖子ID
 @param postType 帖子类型
 @param isLike 点攒/取消点攒
 */
- (void)branchAnalyticsPostLikeWithPostId:(NSString *)postId postType:(NSString *)postType isLike:(BOOL)isLike;
/**
 帖子收藏
 
 @param postId 帖子ID
 @param postType 帖子类型
 @param isSave 收藏/取消收藏
 */
- (void)branchAnalyticsPostSaveWithPostId:(NSString *)postId postType:(NSString *)postType isSave:(BOOL)isSave;
/**
 帖子评论
 
 @param postId 帖子ID
 @param postType 帖子类型
 */
- (void)branchAnalyticsPostReviewWithPostId:(NSString *)postId postType:(NSString *)postType;
/**
 帖子分享
 
 @param postId 帖子ID
 @param postType 帖子类型
 @param shareType 分享类型
 */
- (void)branchAnalyticsPostShareWithPostId:(NSString *)postId postType:(NSString *)postType shareType:(NSString *)shareType;
@end

NS_ASSUME_NONNULL_END
