//
//  ZFVideoLiveGoodsAlertView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "ExchangeManager.h"

#import "ZFTitleArrowTipView.h"
#import "ZFCommunityVideoLiveGoodsModel.h"


@interface ZFVideoLiveGoodsAlertView : UIView

- (instancetype)initTipArrowOffset:(CGFloat)offset
                      leadingSpace:(CGFloat)leading
                     trailingSpace:(CGFloat)trailing
                            direct:(ZFTitleArrowTipDirect)direct
                       contentView:(UIView *)content;

/*
 * time: 设置自动隐藏时间
 * completion:
 */
- (void)hideViewWithTime:(NSInteger)time complectBlock:(void (^)(void))completion;
@end


@interface ZFVideoLiveGoodsAlertItemView : UIView

- (instancetype)initFrame:(CGRect)frame goodsModel:(ZFCommunityVideoLiveGoodsModel *)goodsModel;

- (instancetype)initFrame:(CGRect)frame goodsModel:(ZFCommunityVideoLiveGoodsModel *)goodsModel tryOn:(BOOL)tryOn;

@property (nonatomic, copy) void (^addCartBlock)(ZFCommunityVideoLiveGoodsModel *goodsModel);

@property (nonatomic, copy) void (^closeBlock)(BOOL flag);

- (void)updateCloseSize:(CGSize)size;

@end
