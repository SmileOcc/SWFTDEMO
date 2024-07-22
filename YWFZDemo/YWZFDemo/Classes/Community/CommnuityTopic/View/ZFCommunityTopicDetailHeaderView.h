//
//  ZFCommunityTopicDetailHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2018/9/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityTopicDetailHeadLabelModel.h"

@interface ZFCommunityTopicDetailHeaderView : UIView

@property (nonatomic, strong) UIView                    *topView;
@property (nonatomic, strong) UIButton                  *viewAllBtn;
@property (nonatomic, strong) ZFCommunityTopicDetailHeadLabelModel *topicDetailHeadModel;

@property (nonatomic, copy) NSString           *deeplinkUrlString;


@property (nonatomic, copy) void (^joinInMyStyleBlock)(NSString *topicLabel);//My Style Block
@property (nonatomic, copy) void (^refreshHeadViewBlock)(BOOL isShowAll);//My Style Block
@property (nonatomic, copy) void (^selectTypeEvent)(NSInteger btnTag);

@property (nonatomic, copy) void (^topicDetailBlock)(NSString *labName);
@property (nonatomic, copy) void (^tapOutfiRuleBlock)(NSString *rule);

@property (nonatomic, copy) void (^deeplinkHandle)(NSString *deeplinkUrl);


/**
 结束活动倒计时
 */
- (void)stopTimer;

@end
