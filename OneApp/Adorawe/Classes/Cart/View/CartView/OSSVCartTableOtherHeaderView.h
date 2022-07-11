//
//  OSSVCartTableOtherHeaderView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVCartTableOtherHeaderView : UITableViewHeaderFooterView

+ (OSSVCartTableOtherHeaderView *)cartHeaderViewWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UIView                *lineView;


@end
