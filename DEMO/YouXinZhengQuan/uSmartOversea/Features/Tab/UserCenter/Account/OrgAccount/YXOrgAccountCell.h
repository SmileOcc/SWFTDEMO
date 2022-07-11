//
//  YXOrgAccountCell.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXOrgAccountModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface YXOrgAccountCell : UITableViewCell

@property (nonatomic, strong) YXOrgAccountModel *model;

@property (nonatomic, copy) void (^clickEmailOrPhoneCallBack)(YXOrgAccountModel *model);

@property (nonatomic, copy) void (^clickStatusCallBack)(YXOrgAccountModel *model);

@end

NS_ASSUME_NONNULL_END
