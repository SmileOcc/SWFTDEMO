//
//  ZFGeshopCollectionView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGeshopThematicProtocol.h"
#import "ZFGeshopSiftPopListView.h"

@class ZFGeshopSectionModel;

@interface ZFGeshopCollectionView : UIView

@property (nonatomic, strong, readonly) NSMutableArray<ZFGeshopSectionModel *> *sectionModelArr;

- (instancetype)initWithGeshopProtocol:(id<ZFGeshopThematicProtocol>)actionProtocol;

- (void)dealWithListData:(NSArray<ZFGeshopSectionModel *> *)modelArray
                pageDict:(NSDictionary *)pageDict;

- (void)dealWithMorePageData:(NSArray<ZFGeshopSectionListModel *> *)goodsModelArray
                    pageDict:(NSDictionary *)pageDict
                  isFromSift:(BOOL)fromSift;

- (void)dealWithAsyncReloadData:(NSArray<ZFGeshopSectionModel *> *)modelArray
                       pageDict:(NSDictionary *)pageDict
                     isFromSift:(BOOL)fromSift;

/// 刷新表格中的筛选栏Cell筛选标题
- (void)dealwithSiftCategoryModel:(ZFGeshopSiftItemModel *)siftModel
                 categoryDataType:(ZFCategoryColumnDataType)categoryDataType
                  siftModelHandle:(void(^)(ZFGeshopComponentDataModel *))siftModelHandle
                loadNewDataHandle:(void(^)(void))loadNewDataHandle;

- (NSArray *)configAllClickCellBlockArray;

- (void)convertSectionBgColorView:(BOOL)show;

- (void)setListViewCanScrollsToTop:(BOOL)canToTop;

- (NSInteger)fetchItemsCountInSection:(NSInteger)section;

- (UICollectionViewCell *)fetchCellWithIndexPath:(NSIndexPath *)indexPath;

@end

