//
//  OSSVCartHeaderView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STLCatrActivityModel.h"

typedef void (^CartHeaderOperateBlock)(ActivityInfoModel *infoModel);

@interface OSSVCartHeaderView : UITableViewHeaderFooterView

@property (nonatomic,copy) CartHeaderOperateBlock     operateBlock;

@property (nonatomic, strong) ActivityInfoModel    *infoModel;

+ (OSSVCartHeaderView *)cartHeaderViewWithTableView:(UITableView *)tableView;

- (void)updateInfoModel:(ActivityInfoModel *)infoModel freeGift:(BOOL)isFreeGift;

@end
