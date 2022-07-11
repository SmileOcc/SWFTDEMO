//
//  OSSVCategorysTableCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCategorysModel.h"

@interface OSSVCategorysTableCell : UITableViewCell

@property (nonatomic, strong) OSSVCategorysModel *categoryModel;
@property (nonatomic, strong) UILabel *titleLabel;

@end
