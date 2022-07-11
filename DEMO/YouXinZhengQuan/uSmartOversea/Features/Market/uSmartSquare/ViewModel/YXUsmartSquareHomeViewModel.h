//
//  YXUsmartSquareHomeViewModel.h
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
//#import "uSmartOversea-Swift.h"
#import "YXSecuID.h"


@class YXHotTopicModel;
@class YXGuessUpAndDownResModel;
@class YXTodayHotStockResModel;
@class YXIPOTodayCountResModel;
@class YXSquareSection;

NS_ASSUME_NONNULL_BEGIN

@interface YXUsmartSquareHomeViewModel : YXViewModel

//@property (nonatomic, strong) RACCommand *entranceConfigCommand; // 入口

//@property (nonatomic, strong) YXIPOTodayCountResModel *ipoTodayModel;
//@property (nonatomic, strong) NSArray *ipoAdList;
//@property (nonatomic, strong) NSArray *ipoList;

- (void)reloadStockCommentWithCallBack:(void(^ _Nullable)(void))callBack;

/// 精选评论
@property (nonatomic, strong) NSMutableArray *hotCommentList;
@property (nonatomic, strong) NSMutableArray *squareDefaultList;


@property (nonatomic, strong) YXSquareSection *commentSectionHeaderModel;

@property (nonatomic, strong) RACCommand *hotDiscussionCommand; // 热门讨论


@end

NS_ASSUME_NONNULL_END
