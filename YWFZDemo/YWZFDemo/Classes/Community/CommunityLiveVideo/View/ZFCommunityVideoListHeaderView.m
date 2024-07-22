//
//  ZFCommunityVideoListHeaderView.m
//  ZZZZZ
//
//  Created by YW on 16/11/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityVideoListHeaderView.h"
#import "ZFCommunityVideoDetailInfoModel.h"
#import "YYText.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFCommunityVideoListHeaderView ()
@property (nonatomic, strong) YYLabel *descLabel;
@property (nonatomic, strong) UIButton *likeBtn;
@property (nonatomic, strong) UILabel *likeNum;
@property (nonatomic, strong) UILabel *watchNum;
@end

@implementation ZFCommunityVideoListHeaderView

- (void)setInfoModel:(ZFCommunityVideoDetailInfoModel *)infoModel {
    _infoModel = infoModel;
    
    if (!ZFIsEmptyString(infoModel.videoDescription)) {
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:infoModel.videoDescription];
        content.yy_font = [UIFont systemFontOfSize:14];
        content.yy_color = ZFCOLOR(153, 153, 153, 1.0);
        _descLabel.attributedText = content;
    }

    NSString *str = [NSString stringWithFormat:@"%ld",infoModel.viewNum];
    _watchNum.text = [NSString stringWithFormat:ZFLocalizedString(@"Community_Little_Views",nil),str];
    
    //点赞
    _likeNum.text = infoModel.likeNum;
    if (infoModel.isLike) {
        _likeBtn.selected = YES;
        _likeNum.textColor = ZFC0xFE5269();
    }else {
        self.likeBtn.selected = NO;
        if ([infoModel.likeNum isEqualToString:@"0"]) {
            _likeNum.text = nil;
        }else {
            _likeNum.textColor = ZFCOLOR(102, 102, 102, 1.0);
        }
    }
    
    if (self.refreshHeadViewBlock) {
        [self layoutIfNeeded];
        CGFloat height = 210 * ScreenWidth_SCALE + 5 + self.descLabel.height + 24 + 10;
        self.refreshHeadViewBlock(height);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *backView = [UIView new];
        backView.backgroundColor = [UIColor whiteColor];
        [self addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];

        YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
        modifier.fixedLineHeight = 17;//行高

        _descLabel = [YYLabel new];
        _descLabel.numberOfLines = 0;
        _descLabel.linePositionModifier = modifier;
        _descLabel.preferredMaxLayoutWidth = KScreenWidth - 20;//自动设置高度
        _descLabel.textContainerInset = UIEdgeInsetsMake(0, 10, 0, 10);
        _descLabel.font = [UIFont systemFontOfSize:14];
        _descLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        _descLabel.backgroundColor = ZFCOLOR_WHITE;
        [backView addSubview:_descLabel];
        
        [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(backView);
            make.top.mas_equalTo(backView.mas_top);
        }];
        
        UIView *buttonView = [UIView new];
        buttonView.backgroundColor = ZFCOLOR_WHITE;
        [backView addSubview:buttonView];
        
        [buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(backView);
            make.top.mas_equalTo(self.descLabel.mas_bottom);
            make.height.mas_equalTo(40);
        }];
        
        YYAnimatedImageView *eyeImg = [YYAnimatedImageView new];
        eyeImg.image = [UIImage imageNamed:@"views"];
        [buttonView addSubview:eyeImg];
        
        [eyeImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(buttonView.mas_centerY);
            make.leading.mas_equalTo(buttonView.mas_leading).mas_offset(10);
        }];
        
        _watchNum = [UILabel new];
        _watchNum.font = [UIFont systemFontOfSize:12];
        _watchNum.textColor = ZFCOLOR(102, 102, 102, 1.0);
        [buttonView addSubview:_watchNum];
        
        [_watchNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(buttonView.mas_centerY);
            make.leading.mas_equalTo(eyeImg.mas_trailing).mas_offset(3);
        }];
        
        _likeNum = [UILabel new];
        _likeNum.font = [UIFont systemFontOfSize:12];
        _likeNum.textColor = ZFCOLOR(102, 102, 102, 1.0);
        [buttonView addSubview:_likeNum];
        
        [_likeNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(buttonView.mas_centerY).mas_offset(3);
            make.trailing.mas_equalTo(buttonView.mas_trailing).mas_offset(-12);
        }];
        
        _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_likeBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_likeBtn setImage:ZFImageWithName(@"Community_like_gray_24") forState:UIControlStateNormal];
        [_likeBtn setImage:ZFImageWithName(@"Community_like_red_24") forState:UIControlStateSelected];
        [_likeBtn.imageView convertUIWithARLanguage];
        [buttonView addSubview:_likeBtn];
        
        [_likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(buttonView.mas_centerY);
            make.trailing.mas_equalTo(self.likeNum.mas_leading).mas_offset(-5);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        UIView *line2 = [UIView new];
        line2.backgroundColor = ZFCOLOR(246, 246, 246, 1.0);
        [self addSubview:line2];
        
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(10);
            make.leading.trailing.mas_equalTo(self);
            make.top.mas_equalTo(buttonView.mas_bottom);
            make.bottom.mas_equalTo(backView.mas_bottom).offset(1);//盖住下面的细线
        }];
    }
    return self;
}

- (void)clickEvent:(UIButton*)sender {
    [_likeBtn.imageView.layer addAnimation:[_likeBtn.imageView zfAnimationFavouriteScale] forKey:@"Liked"];
    if (self.likeBlock) {
        self.likeBlock();
    }
}


@end
