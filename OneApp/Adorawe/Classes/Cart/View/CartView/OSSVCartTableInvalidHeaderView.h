//
//  OSSVCartTableInvalidHeaderView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CartInvalidHeaderOperateBlock)();
@interface OSSVCartTableInvalidHeaderView : UITableViewHeaderFooterView

+ (OSSVCartTableInvalidHeaderView *)cartHeaderViewWithTableView:(UITableView *)tableView;

@property (nonatomic,copy) CartInvalidHeaderOperateBlock     operateBlock;
@end
