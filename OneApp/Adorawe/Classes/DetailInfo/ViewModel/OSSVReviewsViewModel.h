//
//  OSSVReviewsViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
//模型数据
#import "OSSVReviewsModel.h"

@interface OSSVReviewsViewModel : BaseViewModel <UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) UIViewController *controller;

//列表数据
@property (nonatomic,strong) NSMutableArray *dataArray;

//模型数据
@property (nonatomic,strong) OSSVReviewsModel *reviewsModel;


- (void)requestOnlyDetailReviewsNetwork:(id)parmaters completion:(void (^)(OSSVReviewsModel *reviewsModel))completion failure:(void (^)(id))failure;
@end
