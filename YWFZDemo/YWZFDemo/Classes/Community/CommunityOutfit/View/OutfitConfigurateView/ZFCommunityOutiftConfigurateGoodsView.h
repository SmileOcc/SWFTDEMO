//
//  ZFCommunityOutiftConfigurateGoodsView.h
//  ZZZZZ
//
//  Created by YW on 2019/2/28.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityOutfitGoodsCateModel.h"
#import "ZFGoodsModel.h"
#import "CategoryRefineSectionModel.h"


@class ZFCommunityOutiftConfigurateGoodsMenuView;

@interface ZFCommunityOutiftConfigurateGoodsView : UIView

@property (nonatomic, strong) ZFCommunityOutiftConfigurateGoodsMenuView   *menuView;

/** 选择的商品*/
@property (nonatomic, copy) void (^selectBlock)(ZFGoodsModel *goodModel);

/** 获取请求的菜单数据*/
@property (nonatomic, copy) void (^menuDatasBlock)(BOOL hasData);

- (void)updateMenuViewDatas:(NSArray <ZFCommunityOutfitGoodsCateModel*> *)menuDatas;

/** 是否显示菜单选择视图*/
- (void)showMenuView:(BOOL)isShow;

/** 刷新筛选*/
- (void)refineCurrentSelectAttr:(NSString *)attr_list;

/** 获取当前筛选数据*/
- (CategoryRefineSectionModel *)currentGoodsRefine;

@end



@interface ZFCommunityOutiftConfigurateGoodsMenuView : UIView

@property (nonatomic, strong) NSArray<ZFCommunityOutfitGoodsCateModel *>       *datasArray;
@property (nonatomic, assign) NSInteger                                        selectIndex;
@property (nonatomic, assign) BOOL                                             isHiddenUnderLineView;

///选择菜单
@property (nonatomic, copy) void (^selectBlock)(NSInteger index);


@end
