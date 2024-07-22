//
//  ZFFullLiveGoodsContentView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFVideoLiveConfigureInfoUtils.h"

#import "ZFFullLiveGoodsListView.h"
#import "ZFFullLiveGoodsAttributesListView.h"
#import "ZFCommunityLiveListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveGoodsContentView : UIView


@property (nonatomic, copy) void (^selectBlock)(ZFGoodsModel *goodModel);
@property (nonatomic, copy) void (^cartGoodsBlock)(ZFGoodsModel *goodModel);
@property (nonatomic, copy) void (^similarGoodsBlock)(ZFGoodsModel *goodModel);
@property (nonatomic, copy) void (^cartBlock)(void);
@property (nonatomic, copy) void (^commentListBlock)(GoodsDetailModel *goodDetailModel);
@property (nonatomic, copy) void (^goodsGuideSizeBlock)(NSString *sizeUrl);




@property (nonatomic, strong) ZFFullLiveGoodsListView *goodsListView;
@property (nonatomic, strong) ZFFullLiveGoodsAttributesListView *goodsAttributeListView;

- (void)cateName:(NSString *)cateName cateID:(NSString *)cateID skus:(NSString *)skus;

@property (nonatomic, copy) void (^closeBlock)(void);

@property (nonatomic, copy) NSString *currentRecommendGoodsId;

@property (nonatomic, strong) ZFCommunityLiveListModel *videoModel;

- (void)showGoodsView:(BOOL)show;

- (NSMutableArray<ZFGoodsModel *> *)currentGoodsArray;

@end

NS_ASSUME_NONNULL_END
