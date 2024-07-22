//
//  ZFCarRecommendGoodsHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFGoodsModel, AFparams;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZFRecommendHeaderSelectGoodsBlock)(NSString *goodsId, UIImageView *imageView);

@interface ZFCarRecommendGoodsHeaderView : UITableViewHeaderFooterView

@property (nonatomic, copy) ZFRecommendHeaderSelectGoodsBlock selectGoodsBlock;

@property (nonatomic, assign) BOOL isEmptyCart;

- (void)setDataArray:(NSArray<ZFGoodsModel *> *)dataArray afParams:(AFparams *)afParams;

@end

NS_ASSUME_NONNULL_END
