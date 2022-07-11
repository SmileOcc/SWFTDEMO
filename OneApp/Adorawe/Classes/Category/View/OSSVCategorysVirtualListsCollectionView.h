//
//  OSSVCategorysVirtualListsCollectionView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCategoriyDetailsGoodListsModel.h"
#import "CHTCollectionViewWaterfallLayout.h"

typedef void (^EmptyOperationBlock)();

@protocol STLCategoryVirtualListCollectionViewDelegate<NSObject>

@optional

- (void)didDeselectVirtualGoodListModel:(OSSVCategoriyDetailsGoodListsModel *)model;

@end



@interface OSSVCategorysVirtualListsCollectionView : UICollectionView

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) EmptyOperationBlock emptyOperationBlock;
@property (nonatomic, weak) id <STLCategoryVirtualListCollectionViewDelegate> myDelegate;

- (void)refreshStart;
- (void)updateData;

@end
