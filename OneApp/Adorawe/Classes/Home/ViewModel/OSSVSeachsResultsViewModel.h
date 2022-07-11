//
//  SeachResultViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "OSSVSearchingModel.h"

@interface OSSVSeachsResultsViewModel : BaseViewModel<CHTCollectionViewDelegateWaterfallLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, weak) STLBaseCtrl *controller;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSString *keyWordType;

@property (nonatomic, copy) NSString *deeplinkUrl;
@property (nonatomic, copy) NSString *deeplinkId;

@property (nonatomic, strong) OSSVSearchingModel                   *searchModel;

- (NSInteger)currentPageGoodsCount;
@end
