//
//  ZFCommunityTopicDetailListCell.m
//  ZZZZZ
//
//  Created by YW on 2018/9/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityTopicDetailListCell.h"
#import "ZFCommunityPictureModel.h"
#import "YYText.h"
#import "ZFInitViewProtocol.h"
#import "UICollectionViewCell+ZFExtension.h"
#import "CommunityEnumComm.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYWebImage/UIImage+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIImage+ZFExtended.h"

#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCommunityTopicDetailListCell () <ZFInitViewProtocol>

@property (nonatomic, strong) UIView                      *bgView;;
@property (nonatomic, strong) YYAnimatedImageView         *contentImgView;//评论图片容器
@property (nonatomic, strong) YYLabel                     *commentLabel;//评论内容
@property (nonatomic, strong) UIView                      *bottomView;
@property (nonatomic, strong) UIView                      *commentView;
@property (nonatomic, strong) YYAnimatedImageView         *iconImg;//头像
@property (nonatomic, strong) UILabel                     *nameLabel;//昵称
//@property (nonatomic, strong) UILabel                     *likeNumLabel;//点赞数
@property (nonatomic, strong) UIButton                    *likeBtn;//点赞按钮

@property (nonatomic, strong) UIButton                    *userBtn;
@property (nonatomic, strong) UIImageView                 *rankImageView;

@end

@implementation ZFCommunityTopicDetailListCell



- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        
        [self setShadowAndCornerCell];

    }
    return self;
}

#pragma mark - Button Click Event
- (void)clickEvent:(UIButton*)sender {
    switch (sender.tag) {
        case likeBtnTag:
        {
            [self.likeBtn.imageView.layer addAnimation:[self.likeBtn.imageView zfAnimationFavouriteScale] forKey:@"Liked"];

            if (self.clickEventBlock) {
                self.clickEventBlock(sender,self.model);
            }
        }
            break;
        case reviewBtnTag:
        {
            if (self.clickEventBlock) {
                self.clickEventBlock(sender,self.model);
            }
        }
            break;
        case shareBtnTag:
        {
            if (self.clickEventBlock) {
                self.clickEventBlock(sender,self.model);
            }
        }
            break;
        case followBtnTag:
        {
            if (self.clickEventBlock) {
                self.clickEventBlock(sender,self.model);
            }
        }
            break;
        case mystyleBtnTag: {
            if (self.communtiyMyStyleBlock) {
                self.communtiyMyStyleBlock();
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.contentImgView];
    [self.bgView addSubview:self.bottomView];
    [self.bottomView addSubview:self.commentView];
    [self.bottomView addSubview:self.commentLabel];
    [self.bottomView addSubview:self.iconImg];
    [self.bottomView addSubview:self.nameLabel];
    [self.bottomView addSubview:self.likeBtn];
    [self.bottomView addSubview:self.userBtn];
    [self.bottomView addSubview:self.rankImageView];

}

- (void)zfAutoLayoutView {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.bgView);
        make.height.mas_equalTo(kTopicDetailBottomHeight);
    }];
    //37
    
    [self.contentImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.bgView);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];
    
    
    //////
    [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bottomView.mas_leading).offset(12);
        make.bottom.mas_equalTo(self.bottomView.mas_bottom).offset(-12);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    [self.userBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bottomView.mas_leading);
        make.centerY.mas_equalTo(self.iconImg.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 26));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconImg.mas_trailing).offset(3);
        make.centerY.mas_equalTo(self.iconImg.mas_centerY);
        make.trailing.mas_equalTo(self.likeBtn.mas_leading).offset(-4);
    }];
    
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.iconImg.mas_centerY).offset(1);
        make.height.mas_equalTo(kTopicDetailBottomHeight);
    }];
    
    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.bottomView);
        make.bottom.mas_equalTo(self.iconImg.mas_top);
    }];
    
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.commentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.commentView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.commentView);
    }];
    
    [self.rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.iconImg.mas_trailing);
        make.bottom.mas_equalTo(self.iconImg.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];
    
    [self.likeBtn setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.likeBtn setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    [self.nameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setModel:(ZFCommunityTopicDetailListModel *)model {
    _model = model;
    
    @weakify(self)
    _model.touchTopicAttrTextBlcok = ^(NSString *topicName) {
        @strongify(self)
        if (self.topicDetailBlock) {
            self.topicDetailBlock(topicName);
        }
    };
    //清除子视图防止二次创建
    [self.contentImgView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
        }];
        [obj removeFromSuperview];
    }];
    //头像
    [self.iconImg yy_setImageWithURL:[NSURL URLWithString:model.avatar]
                         placeholder:[UIImage imageNamed:@"public_user_small"]
                             options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                           transform:^UIImage *(UIImage *image, NSURL *url) {
                               image = [image yy_imageByResizeToSize:CGSizeMake(39,39) contentMode:UIViewContentModeScaleToFill];
                               return [image yy_imageByRoundCornerRadius:19.5];
                           }
                          completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                          }];
    
    self.nameLabel.text = model.nickname;
    self.commentLabel.attributedText = _model.contentAttributedText;
    
    //图片秀
    NSString *imgPath = @"";
    CGFloat  imgScale = 0;
    if (model.reviewPic.count > 0) {
        ZFCommunityPictureModel *firtModel = model.reviewPic.firstObject;
        imgPath = firtModel.bigPic;
        if ([firtModel.bigPicWidth floatValue] > 0) {
            imgScale = [firtModel.bigPicHeight floatValue] / [firtModel.bigPicWidth floatValue];
        }
    }

    
    //图片
    if (!model.randomColor) {
        model.randomColor = [UIColor colorWithHexString:[ZFThemeManager randomColorString:nil]] ;
    }
    self.contentImgView.backgroundColor = model.randomColor;
    
    
    [self.contentImgView yy_setImageWithURL:[NSURL URLWithString:imgPath]
                       placeholder:nil
                           options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                          progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                         transform:^UIImage *(UIImage *image, NSURL *url) {
                             return image;
                         }
                        completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                        }];

    CGFloat tempH = _model.commentHeight + kTopicDetailBottomHeight;
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tempH);
    }];
    
    //用户是否点赞
    NSInteger likeNum = (long)[model.likeCount integerValue];

    if (likeNum>0) {
        self.likeBtn.selected = model.isLiked;
        UIControlState state = self.likeBtn.selected ? UIControlStateSelected : UIControlStateNormal;
        
        NSString *likeStr = [NSString stringWithFormat:@"%zd",likeNum];
        if (likeNum >= 10000) {
            likeStr = @"9.9k+";
        }
        [self.likeBtn setTitle:likeStr forState:state];
        self.likeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
    } else {
        self.likeBtn.selected = NO;
        [self.likeBtn setTitle:@"" forState:UIControlStateNormal];
        self.likeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    
    self.rankImageView.hidden = YES;
    if ([model.identify_type integerValue] > 0) {
        [self.rankImageView yy_setImageWithURL:[NSURL URLWithString:model.identify_icon] options:kNilOptions];
        self.rankImageView.hidden = NO;
    }
}
#pragma mark - setter/getter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _bgView;
}
- (YYAnimatedImageView *)iconImg {
    if (!_iconImg) {
        _iconImg = [YYAnimatedImageView new];
        _iconImg.contentMode = UIViewContentModeScaleAspectFill;
        _iconImg.layer.cornerRadius = 12.5;
        _iconImg.layer.masksToBounds = YES;
    }
    return _iconImg;
}

- (UIButton *)userBtn {
    if (!_userBtn) {
        _userBtn = [UIButton new];
        _userBtn.tag = mystyleBtnTag;
        [_userBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _userBtn;
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = ZFC0x999999();
        _nameLabel.font = ZFFontSystemSize(12);
    }
    return _nameLabel;
}

- (UIView *)commentView {
    if (!_commentView) {
        _commentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _commentView;
}

- (YYLabel *)commentLabel {
    if (!_commentLabel) {
        YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
        modifier.fixedLineHeight = 13;//行高
        _commentLabel = [YYLabel new];
        _commentLabel.numberOfLines = 2;
        _commentLabel.linePositionModifier = modifier;
        _commentLabel.preferredMaxLayoutWidth = (KScreenWidth - 36) / 2.0 - 24;
        _commentLabel.font = ZFFontSystemSize(12);
        _commentLabel.textColor = ZFC0x666666();
    }
    return _commentLabel;
}

- (YYAnimatedImageView *)contentImgView {
    if (!_contentImgView) {
        _contentImgView = [YYAnimatedImageView new];
    }
    return _contentImgView;
}

//- (UILabel *)likeNumLabel {
//    if (!_likeNumLabel) {
//        _likeNumLabel = [UILabel new];
//        _likeNumLabel.font = [UIFont systemFontOfSize:12];
//        _likeNumLabel.textColor = ColorHex_Alpha(0xF8A802, 1.0);
//        _likeNumLabel.textAlignment = NSTextAlignmentRight;
//    }
//    return _likeNumLabel;
//}


- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeBtn.backgroundColor = [UIColor clearColor];
        _likeBtn.tag = likeBtnTag;
        _likeBtn.titleLabel.backgroundColor = [UIColor whiteColor];
        _likeBtn.titleLabel.font = ZFFontSystemSize(12.0);
        [_likeBtn setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        [_likeBtn setTitleColor:ZFC0xFE5269() forState:UIControlStateSelected];
        [_likeBtn setImage:[UIImage imageNamed:@"Community_like_gray"] forState:UIControlStateNormal];
        [_likeBtn setImage:[[UIImage imageNamed:@"Community_like_red"] imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
        _likeBtn.imageView.backgroundColor = [UIColor whiteColor];
        [_likeBtn addTarget:self action:@selector(clickEvent:)
                       forControlEvents:UIControlEventTouchUpInside];
        
        [_likeBtn zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:3];
        [_likeBtn convertUIWithARLanguage];
    }
    return _likeBtn;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (UIImageView *)rankImageView {
    if (!_rankImageView) {
        _rankImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _rankImageView.backgroundColor = [UIColor clearColor];
        _rankImageView.userInteractionEnabled = YES;
        _rankImageView.hidden = YES;
    }
    return _rankImageView;
}

@end
