//
//  OSSVAddresseCountryeHeaderView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVAddresseCountryeHeaderView : UITableViewHeaderFooterView

+ (OSSVAddresseCountryeHeaderView *)addressCountryHeaderViewWithTableView:(UITableView *)tableView section:(NSInteger)section;

@property (nonatomic, copy) NSString *titleText;

@end
