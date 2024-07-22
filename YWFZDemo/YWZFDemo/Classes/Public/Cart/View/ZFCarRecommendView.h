//
//  ZFCarRecommendView.h
//  ZZZZZ
//
//  Created by YW on 2018/12/4.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZFCarRecommendSelectGoodsBlock)(NSString *goodsId, UIImageView *imageView);


@interface ZFCarRecommendView : UITableViewHeaderFooterView

@property (nonatomic, copy) ZFCarRecommendSelectGoodsBlock carRecommendSelectGoodsBlock;

@property (nonatomic, assign) BOOL isPaysuccessView;

- (void)setDataArray:(NSArray<ZFGoodsModel *> *)dataArray afParams:(AFparams *)afParams;

@end

NS_ASSUME_NONNULL_END
