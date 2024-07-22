//
//  ZFCommunityHomeLookBookCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityBaseCCell.h"
#import "ZFCommunityFavesItemModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 点击跳转对应的deeplink链接(落地页包括内嵌H5与各个支持deeplink链接的原生页面)
@interface ZFCommunityHomeLookBookCCell : ZFCommunityBaseCCell

@property (nonatomic, strong) UIView                       *bgContentView;
@property (nonatomic, strong) UIImageView                  *picImageView;
@property (nonatomic, strong) UIView                       *maskView;
@property (nonatomic, strong) UILabel                      *contentLab;
@property (nonatomic, strong) UILabel                      *numLab;
@property (nonatomic, strong) UILabel                      *viewsLab;
@property (nonatomic, strong) UIButton                     *lookMarkButton;

+ (NSString *)queryReuseIdentifier;

@end

NS_ASSUME_NONNULL_END
