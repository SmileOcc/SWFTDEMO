//
//  YXStockListViewController.h
//  YouXinZhengQuan
//
//  Created by ellison on 2018/11/13.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXTableViewController.h"
#import "YXStockListHeaderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStockListViewController : YXTableViewController

@property (nonatomic, strong, readonly) YXStockListHeaderView *stockListHeaderView;

@property (nonatomic, copy) NSArray *sortTypes;

@property (nonatomic, strong) UIButton *rotateButton;

@end

NS_ASSUME_NONNULL_END
