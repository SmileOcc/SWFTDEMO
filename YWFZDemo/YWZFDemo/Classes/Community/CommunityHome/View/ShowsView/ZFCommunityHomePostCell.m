//
//  ZFCommunityHomePostCell.m
//  ZZZZZ
//
//  Created by YW on 2018/11/6.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomePostCell.h"
#import "ZFInitViewProtocol.h"
#import "NSString+Extended.h"
#import "UICollectionViewCell+ZFExtension.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIImage+ZFExtended.h"

@interface ZFCommunityHomePostCell () <ZFInitViewProtocol>

@end

@implementation ZFCommunityHomePostCell
@synthesize favesItemModel = _favesItemModel;


+ (NSString *)queryReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    
    [self.contentView addSubview:self.waterFlowContentView];
    [self.waterFlowContentView addSubview:self.waterFlowPicImageView];
    [self.waterFlowContentView addSubview:self.waterFlowMaskView];
    
    [self.waterFlowMaskView addSubview:self.waterFlowContentLab];
    [self.waterFlowMaskView addSubview:self.waterFlowUserImageView];
    [self.waterFlowMaskView addSubview:self.waterFlowRankImageView];
    [self.waterFlowMaskView addSubview:self.waterFlowUserLab];
    [self.waterFlowMaskView addSubview:self.waterFlowLikeButton];
    [self.contentView addSubview:self.waterFlowTopButton];

    [self setShadowAndCornerCell];
}

- (void)zfAutoLayoutView {
    
    [self.waterFlowContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    //图片高度
    CGFloat imageShowHeight = self.favesItemModel.twoColumnImageHeight;
    if (imageShowHeight == 0.0) {
        imageShowHeight = kCommunityHomeWaterfallWidth;
    }
    [self.waterFlowPicImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.waterFlowContentView);
        make.height.mas_equalTo(@(imageShowHeight));
    }];
    
    [self.waterFlowTopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(4);
        make.trailing.offset(0);
        make.height.mas_equalTo(16);
    }];
    
    //图片底下所有子控件的高度
    [self.waterFlowMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waterFlowPicImageView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.waterFlowContentView);
        make.bottom.mas_equalTo(self.waterFlowContentView);
    }];
    
    [self.waterFlowContentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waterFlowMaskView.mas_top).offset(6);
        make.leading.mas_equalTo(self.waterFlowMaskView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.waterFlowMaskView.mas_trailing).offset(-12);
        //make.height.mas_greaterThanOrEqualTo(18);
    }];
    
    [self.waterFlowUserImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waterFlowContentLab.mas_bottom).offset(7);
        make.leading.mas_equalTo(self.waterFlowMaskView.mas_leading).offset(12);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.bottom.mas_equalTo(self.waterFlowMaskView.mas_bottom).offset(-12);
    }];
    
    [self.waterFlowRankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.waterFlowUserImageView.mas_trailing);
        make.bottom.mas_equalTo(self.waterFlowUserImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];
    
    [self.waterFlowLikeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.waterFlowMaskView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.waterFlowUserImageView.mas_centerY).offset(1);
        make.height.mas_equalTo(kFavesCellMaskHeight);
    }];
    
    [self.waterFlowUserLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.waterFlowUserImageView.mas_trailing).offset(4);
        make.centerY.mas_equalTo(self.waterFlowUserImageView.mas_centerY);
        make.trailing.mas_equalTo(self.waterFlowLikeButton.mas_leading).offset(-4);
    }];
    
    
    [self.waterFlowLikeButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.waterFlowLikeButton setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    [self.waterFlowUserLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

}
#pragma mark - action

- (void)likeButtonAction:(UIButton *)sender {
    if (self.postLikeBlock) {
        [sender.imageView.layer addAnimation:[sender.imageView zfAnimationFavouriteScale] forKey:@"likeAnimation"];
        self.postLikeBlock(self.favesItemModel);
    }
}

#pragma mark - setter/getter
- (ZFCommunityFavesItemModel *)favesItemModel {
    return _favesItemModel;
}

- (void)setFavesItemModel:(ZFCommunityFavesItemModel *)favesItemModel {
    _favesItemModel = favesItemModel;
    
    //设置帖子的第一张图片
    NSString *waterPicUrl = @"";
    NSArray *urlArray = [_favesItemModel.reviewPic valueForKeyPath:@"smallPic"];
    if (urlArray.count>0) {
        waterPicUrl = urlArray[0];
    }
    
    //图片高度
    CGFloat imageShowHeight = self.favesItemModel.twoColumnImageHeight;
    if (imageShowHeight == 0.0) {
        imageShowHeight = kCommunityHomeWaterfallWidth;
    }
    [self.waterFlowPicImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(imageShowHeight));
    }];
    
    //图片
    if (!self.favesItemModel.randomColor) {
        self.favesItemModel.randomColor = [UIColor colorWithHexString:[ZFThemeManager randomColorString:nil]] ;
    }
    self.waterFlowPicImageView.backgroundColor = self.favesItemModel.randomColor;

    [self.waterFlowPicImageView yy_setImageWithURL:[NSURL URLWithString:waterPicUrl]
    placeholder:nil];
    
    //帖子内容
    NSString *contentText = _favesItemModel.contentAttributedText.string;
    self.waterFlowContentLab.text = [contentText replaceBrAndEnterChar];
    
    //头像
    self.waterFlowUserLab.text = ZFToString(_favesItemModel.nickname);
    [self.waterFlowUserImageView yy_setImageWithURL:[NSURL URLWithString:_favesItemModel.avatar]
                                        placeholder:[UIImage imageNamed:@"public_user"]
                                            options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                           progress:nil
                                          transform:nil
                                         completion:nil];

    self.waterFlowRankImageView.hidden = YES;
    if ([_favesItemModel.identify_type integerValue] > 0) {
        [self.waterFlowRankImageView yy_setImageWithURL:[NSURL URLWithString:_favesItemModel.identify_icon] options:kNilOptions];
        self.waterFlowRankImageView.hidden = NO;
    }
    
    //用户是否点赞
    NSInteger likeNum = (long)[self.favesItemModel.likeCount integerValue];
    if (likeNum>0) {
        self.waterFlowLikeButton.selected = self.favesItemModel.isLiked;
        UIControlState state = self.waterFlowLikeButton.selected ? UIControlStateSelected : UIControlStateNormal;
        
        NSString *likeStr = [NSString stringWithFormat:@"%zd",likeNum];
        if (likeNum >= 10000) {
            likeStr = @"9.9k+";
        }
        [self.waterFlowLikeButton setTitle:likeStr forState:state];
        self.waterFlowLikeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
    } else {
        self.waterFlowLikeButton.selected = NO;
        [self.waterFlowLikeButton setTitle:@"" forState:UIControlStateNormal];
        self.waterFlowLikeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    
    /** 设置置顶图片 */
    if (_favesItemModel.is_top) {
        self.waterFlowTopButton.hidden = NO;
    }else{
        self.waterFlowTopButton.hidden = YES;
    }
}


- (UIView *)waterFlowContentView
{
    if(!_waterFlowContentView){
        _waterFlowContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _waterFlowContentView.backgroundColor = [UIColor whiteColor];
    }
    return _waterFlowContentView;
}

- (UIImageView *)waterFlowPicImageView {
    if (!_waterFlowPicImageView) {
        _waterFlowPicImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _waterFlowPicImageView.backgroundColor = [UIColor whiteColor];
        _waterFlowPicImageView.contentMode = UIViewContentModeScaleAspectFill;
        _waterFlowPicImageView.userInteractionEnabled = YES;
    }
    return _waterFlowPicImageView;
}

- (UIView *)waterFlowMaskView
{
    if(!_waterFlowMaskView){
        _waterFlowMaskView = [[UIView alloc] initWithFrame:CGRectZero];
        _waterFlowMaskView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
    }
    return _waterFlowMaskView;
}

- (UILabel *)waterFlowContentLab {
    if (!_waterFlowContentLab) {
        _waterFlowContentLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _waterFlowContentLab.backgroundColor = [UIColor whiteColor];
        _waterFlowContentLab.numberOfLines = 2;
        _waterFlowContentLab.font = ZFFontSystemSize(12);
        _waterFlowContentLab.textColor = ZFCOLOR(102, 102, 102, 1.0);
        CGFloat width = kCommunityHomeWaterfallWidth - 12 * 2;
        _waterFlowContentLab.preferredMaxLayoutWidth = width;
    }
    return _waterFlowContentLab;
}

- (UIImageView *)waterFlowUserImageView {
    if (!_waterFlowUserImageView) {
        _waterFlowUserImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _waterFlowUserImageView.backgroundColor = [UIColor whiteColor];
        //_waterFlowUserImageView.contentMode = UIViewContentModeScaleAspectFill;
        _waterFlowUserImageView.userInteractionEnabled = YES;
        _waterFlowUserImageView.layer.cornerRadius = 10;
        _waterFlowUserImageView.clipsToBounds = YES;
        //UIImageView *maskView = [[UIImageView alloc] init];
        //maskView.contentMode = UIViewContentModeScaleAspectFill;
        //maskView.frame = CGRectMake(0, 0, 20, 20);
        //maskView.image = ZFImageWithName(@"public_user");
        //_waterFlowUserImageView.maskView = maskView;
    }
    return _waterFlowUserImageView;
}

- (UIImageView *)waterFlowRankImageView {
    if (!_waterFlowRankImageView) {
        _waterFlowRankImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _waterFlowRankImageView.backgroundColor = [UIColor clearColor];
        _waterFlowRankImageView.userInteractionEnabled = YES;
        _waterFlowRankImageView.hidden = YES;
    }
    return _waterFlowRankImageView;
}


- (UILabel *)waterFlowUserLab {
    if (!_waterFlowUserLab) {
        _waterFlowUserLab = [[UILabel alloc] init];
        _waterFlowUserLab.backgroundColor = [UIColor whiteColor];
        _waterFlowUserLab.font = ZFFontSystemSize(12.0);
        _waterFlowUserLab.textColor = ZFCOLOR(153, 153, 153, 1.0);
    }
    return _waterFlowUserLab;
}

- (UIButton *)waterFlowLikeButton {
    if (!_waterFlowLikeButton) {
        _waterFlowLikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _waterFlowLikeButton.backgroundColor = [UIColor clearColor];
        _waterFlowLikeButton.tag = 2018;
        _waterFlowLikeButton.titleLabel.backgroundColor = [UIColor whiteColor];
        _waterFlowLikeButton.titleLabel.font = ZFFontSystemSize(12.0);
        [_waterFlowLikeButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        [_waterFlowLikeButton setTitleColor:ZFC0xFE5269() forState:UIControlStateSelected];
        [_waterFlowLikeButton setImage:[UIImage imageNamed:@"Community_like_gray"] forState:UIControlStateNormal];
        [_waterFlowLikeButton setImage:[[UIImage imageNamed:@"Community_like_red"] imageWithColor:ZFC0xFE5269()]  forState:UIControlStateSelected];
        _waterFlowLikeButton.imageView.backgroundColor = [UIColor whiteColor];
        [_waterFlowLikeButton addTarget:self action:@selector(likeButtonAction:)
                       forControlEvents:UIControlEventTouchUpInside];
        
        [_waterFlowLikeButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:3];
        [_waterFlowLikeButton convertUIWithARLanguage];
    }
    return _waterFlowLikeButton;
}

- (UIButton *)waterFlowTopButton{
    if (!_waterFlowTopButton) {
        _waterFlowTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_waterFlowTopButton setTitle:ZFLocalizedString(@"Community_shows_top", nil) forState:UIControlStateNormal];
        _waterFlowTopButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_waterFlowTopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _waterFlowTopButton.backgroundColor = ZFC0xFE5269();
        _waterFlowTopButton.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
        _waterFlowTopButton.layer.cornerRadius = 2;
        _waterFlowTopButton.layer.masksToBounds = YES;
        _waterFlowTopButton.hidden = YES;
    }
    return _waterFlowTopButton;
}


@end
