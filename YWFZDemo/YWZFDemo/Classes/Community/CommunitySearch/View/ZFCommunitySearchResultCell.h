//
//  ZFCommunitySearchResultCell.h
//  ZZZZZ
//
//  Created by YW on 2017/7/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFCommunitySearchResultModel;

typedef void(^SearchResultFollowUserCompletionHandler)(ZFCommunitySearchResultModel *model);

@interface ZFCommunitySearchResultCell : UITableViewCell
@property (nonatomic, strong) ZFCommunitySearchResultModel              *model;

@property (nonatomic, copy) SearchResultFollowUserCompletionHandler     searchResultFollowUserCompletionHandler;
@end

