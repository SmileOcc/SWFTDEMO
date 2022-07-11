//
//  STLAttributeSelectImageListView.h
// XStarlinkProject
//
//  Created by odd on 2020/12/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVDetailsBaseInfoModel.h"

static CGFloat kListViewMargin = 16;
static CGFloat kListViewSpace = 12;

#define kImageListViewWidth (SCREEN_WIDTH - kListViewMargin - (kListViewSpace * 2)) * 0.4
#define kImageListViewHeight ceilf(kImageListViewWidth * 1.34)

NS_ASSUME_NONNULL_BEGIN


@interface STLAttributeSelectImageListView : UIView

@property (nonatomic, strong) UIImage *showGoodsImage;

@property (nonatomic, strong) OSSVDetailsBaseInfoModel *goodsDetailModel;
@end

NS_ASSUME_NONNULL_END
