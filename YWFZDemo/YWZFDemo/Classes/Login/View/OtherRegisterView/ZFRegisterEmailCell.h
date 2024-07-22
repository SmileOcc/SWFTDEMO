//
//  ZFRegisterEmailCell.h
//  ZZZZZ
//
//  Created by YW on 29/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFRegisterModel;

typedef void(^EmailTextFieldEditingDidEndHandler)(ZFRegisterModel *model);

@interface ZFRegisterEmailCell : UITableViewCell

+ (ZFRegisterEmailCell *)cellWith:(UITableView *)tableView index:(NSIndexPath *)index;

@property (nonatomic, copy) EmailTextFieldEditingDidEndHandler      emailTextFieldEditingDidEndHandler;

@property (nonatomic, strong) ZFRegisterModel   *model;

@end

