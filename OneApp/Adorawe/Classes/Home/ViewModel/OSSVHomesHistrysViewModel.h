//
//  HomeHistoryViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "CHTCollectionViewWaterfallLayout.h"

typedef void (^UpdateHeaderHeightBlock)(CGFloat height);

@interface OSSVHomesHistrysViewModel : BaseViewModel<CHTCollectionViewDelegateWaterfallLayout,UICollectionViewDelegate,UICollectionViewDataSource,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) UIViewController        *controller;
@property (nonatomic, copy) NSString                *channelName;
@property (nonatomic, copy) UpdateHeaderHeightBlock updateHeaderHeightBlock;
@property (nonatomic, strong) NSArray               *dataArray;

@end
