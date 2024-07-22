//
//  ZFPaySuccessPointCell.h
//  ZZZZZ
//
//  Created by YW on 7/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFPaySuccessModel;

@interface ZFPaySuccessPointCell : UITableViewCell

+ (instancetype)pointCellWith:(UITableView *)tableView;

@property (nonatomic, strong) ZFPaySuccessModel   *model;

@end
