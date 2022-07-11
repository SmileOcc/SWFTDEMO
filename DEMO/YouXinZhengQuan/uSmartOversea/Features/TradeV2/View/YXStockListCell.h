//
//  YXStockListCell.h
//  YouXinZhengQuan
//
//  Created by ellison on 2018/12/17.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXBaseStockListCell.h"
#import "YXSecuMobileBrief1Protocol.h"

NS_ASSUME_NONNULL_BEGIN

@class YXWarrantsFundFlowRankItem, YXMobileBrief1Label;

@interface YXStockListCell : YXBaseStockListCell

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YXModel<YXSecuProtocol, YXSecuMobileBrief1Protocol> *model;
@property (nonatomic, strong) NSArray *sortTypes;
@property (nonatomic, strong) NSArray<YXMobileBrief1Label *> *labels;

- (void)resetScrollViewLeftOffset:(CGFloat)offset;
@end

NS_ASSUME_NONNULL_END
