//
//  ZFAccountVCProtocol.h
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#ifndef ZFAccountVCProtocol_h
#define ZFAccountVCProtocol_h


#import "ZFGoodsModel.h"
#import "ZFAccountGoodsListView.h"
#import "ZFAccountHeaderCReusableView.h"

/*!
 *  @brief 用于布局
 */
@protocol ZFAccountVCProtocol <ZFAccountHeaderCReusableViewDelegate>

- (void)requestAccountPageAllData;

- (void)refreshNavgationBackgroundColorAlpha:(CGFloat)colorAlpha;

- (CGFloat)fetchNavgationMaxY;

- (CGFloat)fetchTabberHeight;

- (void)selectedGoods:(ZFGoodsModel *)goodsModel dataType:(ZFAccountRecommendSelectType)dataType;

@end

#endif /* ZFAccountVCProtocol_h */
