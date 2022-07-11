//
//  OSSVAccounteMyeOrderseViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVAccounteMyeOrdersListeModel.h"

typedef void (^ReloadDataBlock)();
typedef void (^CodCancelOrderAndBuyBlock)();

@interface OSSVAccounteMyeOrderseViewModel : BaseViewModel<UITableViewDataSource, UITableViewDelegate>

- (void)requestOrderAddress:(NSDictionary *)parmaters completion:(void (^)(NSDictionary *reuslt))completion failure:(void (^)(id))failure;
- (void)requestCodOrderConfirm:(NSDictionary *)parmaters completion:(void (^)(BOOL flag))completion failure:(void (^)(id))failure;
- (void)requestCodOrderChangeStatusConfirm:(NSDictionary *)parmaters completion:(void (^)(BOOL flag))completion failure:(void (^)(id))failure;

@property (nonatomic,weak) UIViewController *controller;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic,copy) ReloadDataBlock reloadDataBlock;

-(void)stopCellTimer;

- (void)showCancelCodAlterView:(OSSVAccounteMyeOrdersListeModel *)orderModel;

@property (weak,nonatomic) UIView *ipChangedView;

@end
