//
//  WishViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "MGSwipeTableCell.h"
typedef NSIndexPath *(^MGSwipeCallback)(MGSwipeTableCell *cell);
typedef void (^CompleteExecuteBlock)();
@interface OSSVWishLitsViewModel : BaseViewModel<MGSwipeTableCellDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray *dataArray;


@property (nonatomic,weak) UIViewController *controller;
@property (nonatomic,copy) MGSwipeCallback swipeCallback;
@property (nonatomic,copy) CompleteExecuteBlock completeExecuteBlock;
@end
