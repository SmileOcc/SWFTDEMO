//
//  ZFGoodsDetailCollectionView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFGoodsDetailCellTypeModel;

@interface ZFGoodsDetailCollectionView : UIView

/** 表格Cell数据源类型 */
@property (nonatomic, strong) NSArray<ZFGoodsDetailCellTypeModel *> *sectionTypeModelArr;

- (void)reloadCollectionView:(BOOL)reloadAll sectionIndex:(NSInteger)sectionIndex;

- (void)showFooterRefresh:(BOOL)showFooterRefresh refreshBlock:(void(^)(void))refreshBlock;

- (void)confiugEmptyView:(NSError *)error refreshBlock:(void(^)(void))refreshBlock;

- (void)convertProductDescCellHeight;

- (void)collectionViewScrollsToTop;

- (void)scrollToRecommendGoodsSection;

@end

