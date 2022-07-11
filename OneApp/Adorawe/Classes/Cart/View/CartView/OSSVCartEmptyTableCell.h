//
//  OSSVCartEmptyTableCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CartEmptyDataBlock)();

@interface OSSVCartEmptyTableCell : UITableViewCell

+ (OSSVCartEmptyTableCell *)cellCartEmptyTableWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) YYAnimatedImageView      *imgView;
@property (nonatomic, strong) UILabel                  *titleLabel;
@property (nonatomic, strong) UIButton                 *button;

@property (nonatomic, copy) CartEmptyDataBlock            noDataBlock;

@end
