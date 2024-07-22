//
//  ZFCommunityHomePostCell.h
//  ZZZZZ
//
//  Created by YW on 2018/11/6.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityBaseCCell.h"
#import "ZFCommunityFavesItemModel.h"

@interface ZFCommunityHomePostCell : ZFCommunityBaseCCell

@property (nonatomic, strong) UIView                       *waterFlowContentView;
@property (nonatomic, strong) UIImageView                  *waterFlowPicImageView;
@property (nonatomic, strong) UIView                       *waterFlowMaskView;
@property (nonatomic, strong) UILabel                      *waterFlowContentLab;
@property (nonatomic, strong) UIImageView                  *waterFlowUserImageView;
@property (nonatomic, strong) UIImageView                  *waterFlowRankImageView;

@property (nonatomic, strong) UILabel                      *waterFlowUserLab;
@property (nonatomic, strong) UIButton                     *waterFlowLikeButton;
/** 置顶图标,根据is_top == 1 显示*/
@property (nonatomic, strong) UIButton                     *waterFlowTopButton;

@property (nonatomic, copy) void (^postLikeBlock)(ZFCommunityFavesItemModel *model);

+ (NSString *)queryReuseIdentifier;
@end
