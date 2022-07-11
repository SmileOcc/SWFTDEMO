//
//  OSSVAccountsVCProtocol.h
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OSSVAccountsHeadView.h"
NS_ASSUME_NONNULL_BEGIN

@protocol OSSVAccountsVCProtocol <NSObject>

- (void)requestAccountPageAllData;

- (void)refreshNavgationBackgroundColorAlpha:(CGFloat)colorAlpha;

- (void)scrollContentOffsetY:(CGFloat)offsetY;

- (CGFloat)fetchNavgationMaxY;

- (CGFloat)fetchTabberHeight;

- (void)stl_selectedGoods:(id )goodsModel dataType:(AccountGoodsListType)dataType index:(NSInteger)index requestId:(NSString *)requestId;


@end

NS_ASSUME_NONNULL_END
