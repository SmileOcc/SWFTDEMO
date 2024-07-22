//
//  ZFCommunityPostReplyCommentCell.h
//  ZZZZZ
//
//  Created by YW on 2018/7/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityPostDetailReviewsListMode.h"

@interface ZFCommunityPostReplyCommentCell : UITableViewCell

//@property (nonatomic, copy) void(^replyCommentHandle)(void);
+ (instancetype)commentCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, assign) BOOL                             isHideLine;
@property (nonatomic, strong) ZFCommunityPostDetailReviewsListMode   *model;
@property (nonatomic, copy) void (^userBlock)(ZFCommunityPostDetailReviewsListMode *model);



@end
