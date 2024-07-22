//
//  ZFCommunityPostDetailRecommendGoodsCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/3/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityTopicDetailSimilarSection.h"
#import "ZFCommunityGoodsInfosModel.h"

@interface ZFCommunityPostDetailRecommendGoodsCCell : UICollectionViewCell

+ (NSString *)queryReuseIdentifier;

@property (nonatomic, strong) ZFCommunityTopicDetailSimilarSection *similarSection;
@property (nonatomic, copy) void (^recommendGoodsClick)(ZFCommunityGoodsInfosModel *infosModel);

@end



@interface ZFCommunityPostDetailRecommendGoodsItemCell : UICollectionViewCell

@property (nonatomic, copy) void (^recommendClick)(ZFCommunityGoodsInfosModel *infosModel);

- (void)updateGoodArray:(NSArray<ZFCommunityGoodsInfosModel*> *)goodsArray;
@end



@interface ZFCommunityPostDetailRecommendGoodsItemView : UIControl

- (instancetype)initWithFrame:(CGRect)frame goodsModel:(ZFCommunityGoodsInfosModel *)model;

@property (nonatomic, strong) ZFCommunityGoodsInfosModel *goodModel;

@end
