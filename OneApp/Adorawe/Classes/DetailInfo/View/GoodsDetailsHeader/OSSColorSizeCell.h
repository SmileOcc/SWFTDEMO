//
//  OSSColorSizeCell.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVDetailsBaseInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ColorSizeStateUnselected,// 未选中
    ColorSizeStateSelected,// 选中
    ColorSizeStateUnAble,// 不可用
    ColorSizeStateAndNoNumber// 选中但是无库存
} ColorSizeState;

@interface OSSColorSizeCell : UICollectionViewCell

@property (nonatomic, strong)NSString                       *goos_id;
@property (nonatomic, assign)NSInteger                      goos_numeber;
@property (nonatomic, assign)BOOL                           isJiaoJi;// group_id是否有交集

@property (nonatomic, assign)BOOL                           isSelected;// 是否选中

@property (nonatomic, strong)OSSVSpecsModel             *goodsSpecModel;
@property (nonatomic, strong)OSSVAttributeItemModel     *itemModel;

@property (nonatomic, strong) UIImageView   *colorImgV;
// 标签
@property (nonatomic, strong) UILabel       *flagLab;

@end

NS_ASSUME_NONNULL_END
