//
//  YXHotTopicViewCell.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YXHotTopicStockModel;

typedef void(^voteRequestCallBack)(BOOL isSuccess);

@interface YXHotTopicViewCell1 : UITableViewCell

@property (nonatomic, strong) NSArray *topicArr;

@property (nonatomic, copy) void (^voteCallBack)(NSString *topicId, NSString *voteId, voteRequestCallBack callBack);

@property (nonatomic, copy) void (^moreClickCallBack)(void);

@property (nonatomic, copy) void (^topicClickCallBack)(NSString *topicId);

@property (nonatomic, copy) void (^stockClickCallBack)(YXHotTopicStockModel *model);

@end

NS_ASSUME_NONNULL_END
