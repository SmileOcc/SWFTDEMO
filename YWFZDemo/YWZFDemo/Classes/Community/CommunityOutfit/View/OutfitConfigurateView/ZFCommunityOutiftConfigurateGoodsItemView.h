//
//  ZFCommunityOutiftConfigurateGoodsItemView.h
//  ZZZZZ
//
//  Created by YW on 2019/3/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityOutfitGoodsCateModel.h"
#import "CategoryRefineSectionModel.h"
#import "ZFGoodsModel.h"
#import "CategoryRefineSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityOutiftConfigurateGoodsItemView : UIView

- (instancetype)initWithFrame:(CGRect)frame goodsCate:(ZFCommunityOutfitGoodsCateModel *)cateModel;

/** 分类模型*/
@property (nonatomic, strong) ZFCommunityOutfitGoodsCateModel                  *cateModel;
/** 筛选条件*/
@property (nonatomic, strong) CategoryRefineSectionModel                       *refineModel;

@property (nonatomic, copy) void (^selectBlock)(ZFGoodsModel *goodModel);



- (void)zfViewWillAppear;

/** 筛选处理*/
- (void)refineSelectAttr:(NSString *)attr_list;
@end

NS_ASSUME_NONNULL_END
