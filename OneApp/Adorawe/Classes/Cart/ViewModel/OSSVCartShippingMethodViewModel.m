//
//  OSSVCartShippingMethodViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartShippingMethodViewModel.h"

#import "OSSVCartShippingMethodCell.h"

#import "OSSVCartShippingModel.h"

@interface OSSVCartShippingMethodViewModel ()

@end

@implementation OSSVCartShippingMethodViewModel

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.shippingList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVCartShippingMethodCell *cell = [OSSVCartShippingMethodCell cartCellWithTableView:tableView andIndexPath:indexPath];
    /*数据源*/
    OSSVCartShippingModel *model = self.shippingList[indexPath.row];
    [cell setShippingModel:model curRate:self.curRate];
    
    if ([cell.shippingModel.sid isEqualToString:self.shippingModel.sid]) {
        cell.accessoryView = [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"hook_default"]];
    } else if ([cell.shippingModel.sid isEqualToString:@"5"]) {
        if (self.isOptional) {
            cell.userInteractionEnabled = YES;
        } else {
            cell.shippingMethodTitle.textColor = OSSVThemesColors.col_999999;
            cell.shippingMethodPrice.textColor = OSSVThemesColors.col_999999;
            cell.userInteractionEnabled = NO;
        }
    } else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    @weakify(self)
    if (self.selectedBlock) {
        @strongify(self)
        self.selectedBlock(indexPath.row);
    }
    
}

@end
