//
//  YXStockPickerResultViewController.h
//  uSmartOversea
//
//  Created by youxin on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXPickerResultHeaderView.h"
#import "YXTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStockPickerResultViewController : YXTableViewController

@property (nonatomic, strong, readonly) YXPickerResultHeaderView *stockListHeaderView;

@property (nonatomic, copy) NSArray *sortTypes;

@end

NS_ASSUME_NONNULL_END
