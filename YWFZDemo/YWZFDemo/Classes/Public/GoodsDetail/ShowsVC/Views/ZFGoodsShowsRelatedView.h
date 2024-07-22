//
//  ZFGoodsShowsRelatedView.h
//  ZZZZZ
//
//  Created by YW on 2019/3/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFGoodsShowsRelatedView : UIView

- (void)relatedDataWithGoods_sn:(NSString *)goods_sn;

- (void)setCollectionViewCanScroll:(BOOL)canScroll;

- (BOOL)fetchScrollStatus;

@end

NS_ASSUME_NONNULL_END
