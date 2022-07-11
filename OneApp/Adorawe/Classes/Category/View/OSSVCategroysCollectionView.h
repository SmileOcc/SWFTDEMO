//
//  OSSVCategroysCollectionView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCatagorysChildModel.h"
#import "OSSVSecondsCategorysModel.h"

@class OSSVCategroysCollectionView;

@protocol STLCategroyCollectionViewDelegate <NSObject>

@required

- (void)categoryCollection:(OSSVCategroysCollectionView *)collectionView category:(OSSVCategorysModel*)categoryModel bannerGuide:(OSSVAdvsEventsModel *)advModel isBanner:(BOOL)isBanner;

- (void)categoryCollection:(OSSVCategroysCollectionView *)collectionView scecondCategory:(OSSVSecondsCategorysModel *)secondModel childModel:(OSSVCatagorysChildModel *)childModel;

- (void)categoryCollection:(OSSVCategroysCollectionView *)collectionView willShowCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)categoryCollection:(OSSVCategroysCollectionView *)collectionView scrollEnd:(BOOL)end;
- (void)categoryCollection:(OSSVCategroysCollectionView *)collectionView beginDragging:(BOOL)dragging;

@end

@interface OSSVCategroysCollectionView : UICollectionView

//@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *allCategoryArrays;
@property (nonatomic,weak) id <STLCategroyCollectionViewDelegate> myDelegate;

//- (void)updateDataAtSelectedIndex:(NSInteger)selectedIndex;

- (void)updateSelectCategoryModel:(OSSVCategorysModel *)catgeoryModel;



@end
