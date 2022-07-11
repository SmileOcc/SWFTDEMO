//
//  SearchHistoryViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/19.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

//历史搜索，热门搜索
@interface OSSVSearchsHistoyViewsModel : BaseViewModel<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) STLBaseCtrl *controller;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *historyDataArr;
@property (nonatomic, copy) NSArray          *hotDataArr;

- (void)searchAnalyticsRequestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

+ (NSString *)hotSearchFootCellID;

- (void)updateSearchHistory:(NSMutableArray *)historyDataArr;

@end
