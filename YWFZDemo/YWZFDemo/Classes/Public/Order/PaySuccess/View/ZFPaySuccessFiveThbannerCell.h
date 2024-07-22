//
//  ZFPaySuccessFiveThbannerCell.h
//  ZZZZZ
//
//  Created by YW on 2019/5/6.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFBannerModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^PayBannerHandler)(ZFBannerModel *model);

@interface ZFPaySuccessFiveThbannerCell : UITableViewCell

+ (instancetype)bannerCellWith:(UITableView *)tableView;

@property (nonatomic, strong) ZFBannerModel *bannerModel;
@property (nonatomic, copy) PayBannerHandler payBannerHandler;

@end


NS_ASSUME_NONNULL_END
