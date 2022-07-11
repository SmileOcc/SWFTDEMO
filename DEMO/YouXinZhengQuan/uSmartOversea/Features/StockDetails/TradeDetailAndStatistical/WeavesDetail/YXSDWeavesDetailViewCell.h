//
//  YXSDWeavesDetailViewCell.h
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXTableViewCell.h"

@class YXTick;

NS_ASSUME_NONNULL_BEGIN

@interface YXSDWeavesDetailViewCell : YXTableViewCell

@property (nonatomic, strong) UIImageView *directImgView;

@property (nonatomic, strong) UILabel *numLabel;

@property (nonatomic, assign) BOOL isLastRow;

- (void)refreshWith:(YXTick *)tickDetailModel pClose:(double)pClose priceBase:(NSInteger)priceBase;


@end

@interface YXSDWeavesUsNationDetailViewCell : YXSDWeavesDetailViewCell


@end

NS_ASSUME_NONNULL_END
