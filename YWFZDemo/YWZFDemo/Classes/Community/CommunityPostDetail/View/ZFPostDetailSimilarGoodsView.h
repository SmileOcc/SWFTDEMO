//
//  ZFPostDetailSimilarGoodsView.h
//  ZZZZZ
//
//  Created by YW on 2018/7/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityPostSameGoodsViewModel.h"
#import "ZFAppsflyerAnalytics.h"

@interface ZFPostDetailSimilarGoodsView : UIView

@property (nonatomic, copy) void(^tapActionHandle)(void);
@property (nonatomic, copy) void(^selectedGoodsHandle)(NSString *goodsID, NSString *goodsSN);
@property (nonatomic, copy) void(^tapMoreHandle)(void);
@property (nonatomic, copy) void(^addCartHandle)(ZFCommunityGoodsInfosModel *model);

@property (nonatomic, assign) ZFAppsflyerInSourceType  sourceType;
@property (nonatomic, strong) ZFCommunityPostSameGoodsViewModel  *viewModel;


- (instancetype)initWithReviewID:(NSString *)reviewID;
- (void)show;
- (void)dismiss;

- (void)showView:(UIView *)superView;


@end
