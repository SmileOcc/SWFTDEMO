//
//  OSSVAccountsMyOrderVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVAccounteMyeOrdersListeModel.h"

@interface OSSVAccountsMyOrderVC : STLBaseCtrl

@property (nonatomic, strong) UITableView                *tableView;
@property (nonatomic, assign) NSString    *status;
@property (nonatomic, copy) NSString       *orderTitle;

@property (nonatomic, assign) BOOL         isConcelCodEnter;
@property (nonatomic, strong) OSSVAccounteMyeOrdersListeModel  *codOrderAddressModel;

@property (nonatomic, assign) BOOL     isNeedTransform;

@end
