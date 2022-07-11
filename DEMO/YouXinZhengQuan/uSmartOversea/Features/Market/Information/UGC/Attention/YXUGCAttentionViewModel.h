//
//  YXUGCAttentionViewModel.h
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class YXUGCRecommandUserListModel, YXUGCNoAttensionUserModel;

@interface YXUGCAttentionViewModel : YXViewModel

@property (nonatomic, strong) RACCommand * jumpToCommand;

@property (nonatomic, strong) YXUGCNoAttensionUserModel * noAttensionModel;

@end

@class YXUGCFeedAttentionPostListModel,YXBannerActivityModel;

@interface YXNewHotMainViewModel : YXUGCAttentionViewModel

@property (nonatomic, strong) RACCommand *zipDataCommand;

@property (nonatomic, strong) RACCommand *loadMoreHotFeedCommand;


@property (nonatomic, strong) YXUGCFeedAttentionPostListModel * attentionModel; //正文的model

@property (nonatomic, strong) YXUGCRecommandUserListModel* recommendUserListResModel;

@property (nonatomic, strong) YXBannerActivityModel* recommendBannerResModel;

@property (nonatomic, copy) NSString *query_token;
@end

NS_ASSUME_NONNULL_END
