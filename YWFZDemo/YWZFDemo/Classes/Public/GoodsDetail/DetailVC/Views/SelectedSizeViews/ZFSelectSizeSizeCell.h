//
//  ZFSelectSizeSizeCell.h
//  ZZZZZ
//
//  Created by YW on 2017/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFSizeSelectItemsModel.h"

static CGFloat kSelectSizeItemHeight = 24;

@interface ZFSelectSizeSizeCell : UICollectionViewCell

@property (nonatomic, strong) ZFSizeSelectItemsModel            *model;

/// 视频属性小弹窗用
- (void)updateColorSize:(CGSize)size itmesModel:(ZFSizeSelectItemsModel *)model;
@end
