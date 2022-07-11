//
//  STLFlashSaleContainer.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/3.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OSSVFlashSaleGoodsModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVFlashSaleVC : STLBaseCtrl
@property (nonatomic, copy) NSString            *cellTitle;
@property (nonatomic, copy) NSString            *activeId;
@property (nonatomic, copy) NSString            *labelStr;
@property (nonatomic, copy)  NSString           *timeCount;
@property (nonatomic, copy) void(^showCartBlock)(OSSVFlashSaleGoodsModel *saleModel, NSInteger index);

@property (nonatomic, assign) CGFloat           contentHeight;
@property (nonatomic, assign) BOOL              isFirstAddRefresh;
///是否需要Cell翻转
@property (nonatomic, assign) BOOL              isArCellTransform;

@property (nonatomic, copy) void(^activiteRefreshBlock)(BOOL refresh);

- (UICollectionView *)querySubScrollView;

@end

NS_ASSUME_NONNULL_END
