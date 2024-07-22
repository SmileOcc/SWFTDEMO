//
//  ZFAccountListTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/4/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFAccountTypeModel.h"

@interface ZFAccountListTableViewCell : UITableViewCell

@property (nonatomic, assign) ZFAccountTypeModelType        cellType;       //cell 类型

@property (nonatomic, copy)   NSString                      *tipsInfo;

@end
