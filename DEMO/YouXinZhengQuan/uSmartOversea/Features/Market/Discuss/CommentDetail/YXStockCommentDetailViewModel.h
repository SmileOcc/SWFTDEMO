//
//  YXStockCommentDetailViewModel.h
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/24.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class YXCommentSectionFooterTitleModel, YXCommentSectionTitleModel, YXCommentDetailHeaderModel, YXCommentDetailNoDataModel;

@interface YXStockCommentDetailViewModel : YXViewModel

@property (nonatomic, strong) NSString * cid;

@property (nonatomic, strong) YXCommentDetailNoDataModel * noDataModel;

@property (nonatomic, strong) YXCommentDetailHeaderModel * headerModel;

@property (nonatomic, strong) YXCommentSectionTitleModel * commentTitleModel;
@property (nonatomic, strong) NSMutableArray * commentLists;
@property (nonatomic, strong) YXCommentSectionFooterTitleModel * footerTitleModel;



@end

NS_ASSUME_NONNULL_END
