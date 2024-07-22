//
//  ZFCommunityPostReplyViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/7/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFCommunityPostDetailReviewsListMode.h"

@interface ZFCommunityPostReplyViewController : ZFBaseViewController

- (instancetype)initWithReviewID:(NSString *)reviewID;

@property (nonatomic, copy) void (^replayCommentBlock)(ZFCommunityPostDetailReviewsListMode *model);


@property (nonatomic, strong) ZFCommunityPostDetailReviewsListMode         *firstReviewModel;
/** 是否是穿搭类型 */
@property (nonatomic, assign) BOOL                                          isOutfits;
/** 是否强制弹窗键盘*/
@property (nonatomic, assign) BOOL                                          isEditing;

@end
