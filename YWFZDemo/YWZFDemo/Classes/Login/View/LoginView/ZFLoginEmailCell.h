//
//  YWLoginEmailCell.h
//  ZZZZZ
//
//  Created by YW on 2018/8/20.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWLoginEmailCell : UITableViewCell

+ (YWLoginEmailCell *)loginEmailCellWith:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) NSString   *email;

@end
