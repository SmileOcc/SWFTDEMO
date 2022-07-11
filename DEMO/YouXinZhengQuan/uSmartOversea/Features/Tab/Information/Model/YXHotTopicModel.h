//
//  YXHotTopicModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IGListDiffKit/IGListDiff.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXHotTopicStockModel : NSObject

@property (nonatomic, strong) NSString *market;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, assign) int pctchng;
@property (nonatomic, assign) int priceBase;
@property (nonatomic, assign) int64_t latestPrice;

@end

@interface YXHotTopicTagModel : NSObject

@property (nonatomic, strong) NSString *tag_addr;
@property (nonatomic, strong) NSString *name;

@end

@interface YXHotTopicCommentModel : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *head_image;

@end

@interface YXHotTopicVoteSubModel : NSObject

@property (nonatomic, assign) int count;
@property (nonatomic, assign) BOOL is_pick;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *id;

@end

@interface YXHotTopicVoteModel : NSObject

@property (nonatomic, strong) NSArray <YXHotTopicVoteSubModel *> *vote_item;

@property (nonatomic, assign) BOOL has_vote;

@end


@interface YXHotTopicModel : NSObject

@property (nonatomic, strong) NSArray <YXHotTopicCommentModel *> *comment;
@property (nonatomic, strong) NSArray <YXHotTopicStockModel *> *stock_list;
@property (nonatomic, strong) NSString *tag_addr;
@property (nonatomic, strong) NSString *topic_id;
@property (nonatomic, strong) NSString *topic_title;
@property (nonatomic, strong) YXHotTopicVoteModel *vote;

@property (nonatomic, strong) YXHotTopicTagModel *tag;

@property (nonatomic, assign) int comment_count;

@end


@interface YXHotTopicDiffModel : NSObject<IGListDiffable>

@property (nonatomic, strong) NSArray <YXHotTopicModel *>*list;

- (instancetype)initWithList:(NSArray <YXHotTopicModel *>*)list;

@end

NS_ASSUME_NONNULL_END
