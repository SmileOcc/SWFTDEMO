//
//  OSSVCatagoryListsCollectionView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCategoriyDetailsGoodListsModel.h"
#import "CHTCollectionViewWaterfallLayout.h"

@protocol STLCatagoryListCollectionViewDelegate<NSObject>

@optional

- (void)didDeselectGoodListModel:(OSSVCategoriyDetailsGoodListsModel *)model;

@end

@interface OSSVCatagoryListsCollectionView : UICollectionView

@property (nonatomic, strong) NSMutableArray        *dataArray;
@property (nonatomic, strong) NSMutableDictionary          *analyticDic;
@property (nonatomic, strong) NSString                     *currentTitle;

@property (nonatomic, weak) id <STLCatagoryListCollectionViewDelegate> myDelegate;

- (void)refreshDataView:(BOOL)isRefresh;

- (void)viewDidShow;

@end
