//
//  YXLiveAuthorCell.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXLiveDetailModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface YXLiveAuthorCell : UITableViewCell

@property (nonatomic, strong) YXLiveAnchorModel *anchorModel;

@property (nonatomic, assign) BOOL isFollow;

@property (nonatomic, copy) void (^clickFollowCallBack)(BOOL isFollow);

@end

NS_ASSUME_NONNULL_END
