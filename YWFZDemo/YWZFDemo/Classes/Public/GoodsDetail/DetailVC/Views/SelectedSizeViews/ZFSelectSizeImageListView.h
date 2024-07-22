//
//  ZFSelectSizeImageListView.h
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFFrameDefiner.h"

@class GoodsDetailModel;

static CGFloat kListViewMargin = 16;
static CGFloat kListViewSpace = 12;

#define kImageListViewWidth (KScreenWidth - kListViewMargin - (kListViewSpace * 2)) * 0.4
#define kImageListViewHeight ceilf(kImageListViewWidth * 1.34)

NS_ASSUME_NONNULL_BEGIN

@interface ZFSelectSizeImageListView : UIView

@property (nonatomic, strong) UIImage *showGoodsImage;

@property (nonatomic, strong) GoodsDetailModel *goodsDetailModel;

@end

NS_ASSUME_NONNULL_END
