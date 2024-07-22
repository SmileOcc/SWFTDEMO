//
//  ZFPaySuccessBannerCell.h
//  ZZZZZ
//
//  Created by YW on 7/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFBannerModel.h"

typedef void(^PaySuccessBannerHandler)(ZFBannerModel *model, NSInteger idx);

@interface ZFPaySuccessBannerCell : UITableViewCell

+ (instancetype)bannerCellWith:(UITableView *)tableView;

@property (nonatomic, strong) NSArray<ZFBannerModel *>   *banners;
@property (nonatomic, copy) PaySuccessBannerHandler   paySuccessBannerHandler;

@end
