//
//  ZFCommunityHomeVideoCell.h
//  ZZZZZ
//
//  Created by YW on 2018/11/21.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityBaseCCell.h"
#import "ZFCommunityExploreModel.h"
#import "ZFCommunityFavesItemModel.h"


@interface ZFCommunityHomeVideoCell : ZFCommunityBaseCCell

@property (nonatomic, strong) UIView                       *videoContentView;
@property (nonatomic, strong) UIImageView                  *videoPicImageView;
@property (nonatomic, strong) UIView                       *videoMaskView;
@property (nonatomic, strong) UILabel                      *videoContentLab;
@property (nonatomic, strong) UILabel                      *videoNumLab;
@property (nonatomic, strong) UILabel                      *videoViewsLab;
/** 置顶图标,根据is_top == 1 显示*/
@property (nonatomic, strong) UIButton                     *videoTopButton;
@property (nonatomic, strong) UIButton                     *videoTimeButton;
@property (nonatomic, strong) UIImageView                  *videoPlayImageView;

+ (NSString *)queryReuseIdentifier;

@end

