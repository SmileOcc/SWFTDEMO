//
//  YXImportantNewsViewModel.h
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
@class YXListNewsModel;
@class YXNewsRecommendListModel;

@class YXNewsOrLiveCommentListModel, YXCommentSectionTitleModel,YXCommentDetailNoDataModel,YXCommentSectionFooterTitleModel;

typedef NS_ENUM(NSInteger, YXImportantNewsType) {
    YXImportantNewsTypeUser = 0,
    YXImportantNewsTypeTitle,
    YXImportantNewsTypePublishTime,
    YXImportantNewsTypeTag,
    YXImportantNewsTypeStock,
    YXImportantNewsTypeTopBanner,
    YXImportantNewsTypeContent,
    YXImportantNewsTypeBottomBanner,
};


NS_ASSUME_NONNULL_BEGIN

@interface YXImportantNewsDetailViewModel : YXViewModel

@property (nonatomic, strong) RACCommand *loadDetailCommand;

@property (nonatomic, strong) NSString *newsId;

@property (nonatomic, strong) YXListNewsModel *newsModel;

@property (nonatomic, strong) NSMutableArray *topContentArr;


@property (nonatomic, strong) YXNewsRecommendListModel *recommendModel;


@property (nonatomic, assign) NSInteger commentListOffset;
@property (nonatomic, strong) NSMutableArray *commentTotalDatas;
@property (nonatomic, strong) NSMutableArray *commentListArr;
@property (nonatomic, strong) RACCommand *getCommentList;

@property (nonatomic, strong) YXNewsOrLiveCommentListModel * commentListModel;
@property (nonatomic, strong) YXCommentSectionTitleModel * commentTitleModel;
@property (nonatomic, strong) YXCommentSectionFooterTitleModel * footerTitleModel;
@property (nonatomic, strong) YXCommentDetailNoDataModel * commentNodataModel;


@property (nonatomic, strong) RACCommand *loadBannerAndRecommendCommand;
@end

NS_ASSUME_NONNULL_END
