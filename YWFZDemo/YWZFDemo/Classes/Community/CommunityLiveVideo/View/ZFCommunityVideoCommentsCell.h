//
//  ZFCommunityVideoCommentsCell.h
//  ZZZZZ
//
//  Created by YW on 16/11/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFCommunityPostDetailReviewsListMode;

@interface ZFCommunityVideoCommentsCell : UITableViewCell

+ (ZFCommunityVideoCommentsCell *)commentsCellWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFCommunityPostDetailReviewsListMode *reviesModel;

@property (nonatomic, copy) void (^replyBlock)(void);//回复Block

@property (nonatomic, copy) void (^jumpBlock)(NSString *userId);//跳转VC Block

- (void)hideBottomLine:(BOOL)show;

@end
