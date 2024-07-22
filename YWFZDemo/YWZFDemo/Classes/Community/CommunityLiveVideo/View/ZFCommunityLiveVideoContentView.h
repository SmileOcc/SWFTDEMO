//
//  ZFCommunityLiveVideoContentView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"
#import "ZFCommunityLiveListModel.h"
#import "ZFGoodsDetailCouponModel.h"

@class ZFCommunityLiveVideoMenuCateModel;
@class ZFCommunityLiveVideoContentMenuView;
NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveVideoContentView : UIView

@property (nonatomic, strong) ZFCommunityLiveVideoContentMenuView *menuView;

/** 是否有历史评论数据*/
@property (nonatomic, assign) BOOL isZegoHistoryComment;

/** 返回当前的直播推荐商品数据*/
- (NSMutableArray<ZFGoodsModel *> *)currentRecommendGoodsArray;

/** 获取请求的菜单数据*/
@property (nonatomic, copy) void (^goodsArrayBlock)(NSMutableArray<ZFGoodsModel *> *goodsArray);

/** 触发商品购买按钮*/
@property (nonatomic, copy) void (^videoAddCartBlock)(ZFGoodsModel *goodsModel);
/** 选择商品*/
@property (nonatomic, copy) void (^videoSelectGoodsBlock)(ZFGoodsModel *goodsModel);
/** 触发商品相似按钮*/
@property (nonatomic, copy) void (^videoSimilarGoodsBlock)(ZFGoodsModel *goodsModel);
/** 博主活动deeplink*/
@property (nonatomic, copy) void (^videoActivityBllock)(NSString *deeplink);

- (void)updateMenuViewDatas:(NSArray <ZFCommunityLiveVideoMenuCateModel*> *)menuDatas liveModel:(ZFCommunityLiveListModel *)liveModel;


/**
 更新序号菜单显示
 @param menuModel
 @param index
 */
- (void)updateMenuModel:(ZFCommunityLiveVideoMenuCateModel *)menuModel index:(NSInteger)index;



/** 释放前，清空配置*/
- (void)clearAllSeting;

- (void)fullScreen:(BOOL)isFull;

@end



@interface ZFCommunityLiveVideoContentMenuView : UIView

@property (nonatomic, strong) NSArray<ZFCommunityLiveVideoMenuCateModel *>     *datasArray;
@property (nonatomic, assign) NSInteger                                        selectIndex;
@property (nonatomic, assign) BOOL                                             isHiddenUnderLineView;

///选择菜单
@property (nonatomic, copy) void (^selectBlock)(NSInteger index);

///更新对应的内容
- (void)updateMode:(ZFCommunityLiveVideoMenuCateModel *)cateModel index:(NSInteger)index;
///强制选择
- (void)updateSelectIndex:(NSInteger)index;

@end


@interface ZFCommunityLiveVideoMenuCateModel : NSObject

@property (nonatomic, copy) NSString     *cateName;
@property (nonatomic, copy) NSString     *cateId;
@property (nonatomic, copy) NSString     *skus;
@property (nonatomic, assign) BOOL       isChat;


@end

NS_ASSUME_NONNULL_END
