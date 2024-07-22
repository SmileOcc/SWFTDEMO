//
//  ZFAccountBannerTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/4/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFBannerModel;

typedef void(^ZFAccountBannerActionCompletionHandler)(ZFBannerModel *model);

@interface ZFAccountBannerTableViewCell : UITableViewCell

@property (nonatomic, strong) NSArray<ZFBannerModel *>      *banners;

@property (nonatomic, copy) ZFAccountBannerActionCompletionHandler          accountBannerActionCompletionHandler;
@end
