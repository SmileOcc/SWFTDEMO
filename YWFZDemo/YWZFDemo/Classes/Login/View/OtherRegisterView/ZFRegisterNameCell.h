//
//  ZFRegisterNameCell.h
//  ZZZZZ
//
//  Created by YW on 29/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFRegisterModel;

typedef void(^CompleteHandler)(ZFRegisterModel *model);

@interface ZFRegisterNameCell : UITableViewCell

+ (ZFRegisterNameCell *)cellWith:(UITableView *)tableView index:(NSIndexPath *)index;

@property (nonatomic, strong) ZFRegisterModel   *model;

@property (nonatomic, copy) CompleteHandler               completeHandler;

@end

