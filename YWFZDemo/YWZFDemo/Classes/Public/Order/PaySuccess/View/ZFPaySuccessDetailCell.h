//
//  ZFPaySuccessDetailCell.h
//  ZZZZZ
//
//  Created by YW on 7/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPaySuccessModel.h"

typedef void(^ButtonHandler)(UIButton *sender);

@interface ZFPaySuccessDetailCell : UITableViewCell

@property (nonatomic, strong) ZFPaySuccessModel   *model;

@property (nonatomic, copy) ButtonHandler   buttonHandler;

@property (nonatomic, copy) void(^checkTokenButtonHandler)(void);

+ (instancetype)detailCellWith:(UITableView *)tableView;

@end
