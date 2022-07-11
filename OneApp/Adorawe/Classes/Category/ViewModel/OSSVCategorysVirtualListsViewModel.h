//
//  OSSVCategorysVirtualListsViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVCategoryListsModel.h"
#import "CHTCollectionViewWaterfallLayout.h"

@interface OSSVCategorysVirtualListsViewModel : BaseViewModel

@property (nonatomic, strong) NSString              *childDetailTitle;
@property (nonatomic, strong) NSMutableArray        *dataArray;
@property (nonatomic, strong) OSSVCategoryListsModel  *detailListModel;

@end
