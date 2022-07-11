//
//  YXNewsRecommendCell.h
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/6/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YXListNewsModel;
@class YXListNewsJumpTagModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXNewsRecommendCell : UICollectionViewCell

@property (nonatomic, copy) void (^stockClickCallBack)(void);

@property (nonatomic, strong) YXListNewsModel *model;

@property (nonatomic, copy) void (^tagClickCallBack)(YXListNewsJumpTagModel *tagModel);

@end

NS_ASSUME_NONNULL_END
