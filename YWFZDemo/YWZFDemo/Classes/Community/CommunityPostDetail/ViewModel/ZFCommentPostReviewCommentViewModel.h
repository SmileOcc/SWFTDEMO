//
//  ZFCommentPostReviewCommentViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/7/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 帖子评论
 */
@interface ZFCommentPostReviewCommentViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *replyModelArray;

/// 只用与社区帖子请求
@property (nonatomic, assign) BOOL isFirstCommentRequestSuccess;


- (void)reviewCommentListRequesWithReviewID:(NSString *)reviewID withPageSize:(NSInteger)pageSize complateHandle:(void(^)(BOOL success))complateHandle;
- (void)deleteCommentWithReviewID:(NSString *)reviewID replyID:(NSString *)replyID complateHandle:(void(^)(void))complateHandle;

- (NSInteger)rowCount;
- (CGFloat)rowHeightWithIndexPath:(NSIndexPath *)indexPath;
- (void)refresh;
- (NSInteger)currentPage;
- (NSInteger)totalPage;
- (NSInteger)replyCount;
- (BOOL)isRequestSuccess;
- (NSString *)tipMessage;

- (NSString *)userImageURLWithIndexPath:(NSIndexPath *)indexPath;
- (NSString *)userNickWithIndexPath:(NSIndexPath *)indexPath;
- (NSString *)userCommentWithIndexPath:(NSIndexPath *)indexPath;
- (NSString *)replyIDWithIndexPath:(NSIndexPath *)indexPath;
- (NSString *)reviewIDWithIndexPath:(NSIndexPath *)indexPath;
- (NSString *)userIDWithIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isCanReplyWithIndexPath:(NSIndexPath *)indexPath;

- (void)deleteCommentWithIndexPath:(NSIndexPath *)indexPath;

@end
