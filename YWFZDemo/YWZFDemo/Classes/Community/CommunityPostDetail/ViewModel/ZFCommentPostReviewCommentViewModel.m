//
//  ZFCommentPostReviewCommentViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/7/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommentPostReviewCommentViewModel.h"
#import "ZFCommunityPostDetailReviewsModel.h"
#import "ZFCommunityPostDetailReviewsListMode.h"
#import "YWLocalHostManager.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFCommentPostReviewCommentViewModel ()

@property (nonatomic, assign) NSInteger curPage;
@property (nonatomic, assign) BOOL isSuccess;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) ZFCommunityPostDetailReviewsModel *reviewsModel;

@end

@implementation ZFCommentPostReviewCommentViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.curPage = 1;
        self.isSuccess = NO;
    }
    return self;
}

#pragma mark - 请求
- (void)reviewCommentListRequesWithReviewID:(NSString *)reviewID withPageSize:(NSInteger)pageSize complateHandle:(void (^)(BOOL success))complateHandle {
    
    self.curPage++;
    NSInteger size = pageSize > 0 ? pageSize : 10;
    NSDictionary *params = @{
                             @"type"        : @"9",
                             @"directory"   : @"38",
                             @"site"        : @"ZZZZZcommunity",
                             @"loginUserId" : USERID,
                             @"pageSize"    : @(size),
                             @"curPage"     : @(_curPage),
                             @"reviewId"    : reviewID,
                             @"app_type"    : @"2"
                             };
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.isCommunityRequest = YES;
    requestModel.url       = CommunityAPI;
    requestModel.parmaters = params;
    self.isSuccess  = NO;
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        YWLog(@"###### %@", responseObject);
        if (self.curPage <= 1) {
            self.curPage = 1;
            self.replyModelArray = [NSMutableArray new];
        }
        
        NSDictionary *dataDict = [responseObject ds_dictionaryForKey:@"data"];
        NSInteger code    = [responseObject ds_integerForKey:@"code"];
        if (code == 0) {
            self.reviewsModel = [ZFCommunityPostDetailReviewsModel yy_modelWithJSON:dataDict];
            [self.replyModelArray addObjectsFromArray:self.reviewsModel.list];
            self.curPage = self.reviewsModel.curPage;
            self.isSuccess = YES;
        }
        
        if (complateHandle) {
            complateHandle(YES);
        }
    } failure:^(NSError *error) {
        self.curPage--;
        if (complateHandle) {
            complateHandle(NO);
        }
    }];
}

- (void)deleteCommentWithReviewID:(NSString *)reviewID
                          replyID:(NSString *)replyID
                   complateHandle:(void (^)(void))complateHandle {
    NSDictionary *params = @{
                             @"type"        : @"9",
                             @"directory"   : @"68",
                             @"site"        : @"ZZZZZcommunity",
                             @"loginUserId" : USERID,
                             @"reviewId"    : reviewID,
                             @"replyId"     : replyID,
                             @"app_type"    : @"2"
                             };
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.isCommunityRequest = YES;
    requestModel.url       = CommunityAPI;
    requestModel.parmaters = params;
    self.isSuccess  = NO;
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        YWLog(@"###### %@", responseObject);
        NSInteger code = [responseObject ds_integerForKey:@"code"];
        self.message   = [responseObject ds_stringForKey:@"msg"];
        if (code == 0) {
            self.isSuccess  = YES;
        }
        
        if (complateHandle) {
            complateHandle();
        }
    } failure:^(NSError *error) {
        if (complateHandle) {
            complateHandle();
        }
    }];
}

#pragma mark - 加载数据
- (void)refresh {
    self.curPage = 0;
}

- (NSInteger)currentPage {
    return self.reviewsModel.curPage;
}

- (NSInteger)totalPage {
    return self.reviewsModel.pageCount;
}


- (NSInteger)replyCount {
    return self.reviewsModel.replyCount;
}
- (NSInteger)rowCount {
    return self.replyModelArray.count;
}

- (CGFloat)rowHeightWithIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityPostDetailReviewsListMode *model = [self.replyModelArray objectAtIndex:indexPath.row];
    NSString *tmpContentString = [model.content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [tmpContentString boundingRectWithSize:CGSizeMake(KScreenWidth - (16.0 * 2 + 40.0f + 8.0), MAXFLOAT) options:options attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]} context:nil].size;
    if (model.userId != USERID) {
        CGFloat height = MAX(64.0,  34.0 + size.height + 12.0);
        height += 6.0 + 16.0;
        return height;
    }
    return MAX(64.0,  34.0 + size.height + 12.0);
}

- (NSString *)userImageURLWithIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityPostDetailReviewsListMode *model = [self.replyModelArray objectAtIndex:indexPath.row];
    return model.avatar;
}

- (NSString *)userNickWithIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityPostDetailReviewsListMode *model = [self.replyModelArray objectAtIndex:indexPath.row];
    return model.nickname;
}

- (NSString *)userCommentWithIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityPostDetailReviewsListMode *model = [self.replyModelArray objectAtIndex:indexPath.row];
    NSString *tmpContentString = [model.content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([model.isSecondFloorReply boolValue]) {
        return [NSString stringWithFormat:@"Re %@:%@", model.replyNickName, tmpContentString];
    }
    return tmpContentString;
}

- (BOOL)isCanReplyWithIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityPostDetailReviewsListMode *model = [self.replyModelArray objectAtIndex:indexPath.row];
    return ![model.userId isEqualToString:USERID];
}

- (NSString *)replyIDWithIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityPostDetailReviewsListMode *model = [self.replyModelArray objectAtIndex:indexPath.row];
    return model.replyId;
}

- (NSString *)reviewIDWithIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityPostDetailReviewsListMode *model = [self.replyModelArray objectAtIndex:indexPath.row];
    return model.reviewId;
}

- (NSString *)userIDWithIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityPostDetailReviewsListMode *model = [self.replyModelArray objectAtIndex:indexPath.row];
    return model.userId;
}

- (void)deleteCommentWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.replyModelArray.count) {
        [self.replyModelArray removeObjectAtIndex:indexPath.item];
    }
    
}

- (BOOL)isRequestSuccess {
    return self.isSuccess;
}

- (NSString *)tipMessage {
    return self.message;
}

@end
