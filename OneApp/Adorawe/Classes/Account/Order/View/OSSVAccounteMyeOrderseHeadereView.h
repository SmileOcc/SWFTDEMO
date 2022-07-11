//
//  OSSVAccounteMyeOrderseHeadereView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^JumpRosegalOrder)();

@interface OSSVAccounteMyeOrderseHeadereView : UITableViewHeaderFooterView

+ (OSSVAccounteMyeOrderseHeadereView *)accountMyOrdersHeaderViewWithTableView:(UITableView *)tableView;

@end
