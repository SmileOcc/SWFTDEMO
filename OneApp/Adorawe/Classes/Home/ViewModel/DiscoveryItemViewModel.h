//
//  DiscoveryItemViewModel.h
//  Yoshop
//
//  Created by Qiu on 16/6/21.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "BaseViewModel.h"
#import "DiscoveryHeaderView.h"


@interface DiscoveryItemViewModel : BaseViewModel <UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) UIViewController *controller;

@end
