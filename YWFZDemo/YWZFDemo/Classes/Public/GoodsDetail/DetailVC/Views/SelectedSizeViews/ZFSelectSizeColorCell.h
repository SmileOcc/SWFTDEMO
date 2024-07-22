//
//  ZFSelectSizeColorCell.h
//  ZZZZZ
//
//  Created by YW on 2017/12/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFSizeSelectItemsModel.h"

@interface ZFSelectSizeColorCell : UICollectionViewCell

@property (nonatomic, strong) ZFSizeSelectItemsModel            *model;

/// 4.9.0 视频那小属性弹窗设置用
- (void)updateColorSize:(CGSize)size itmesModel:(ZFSizeSelectItemsModel *)model;
@end
