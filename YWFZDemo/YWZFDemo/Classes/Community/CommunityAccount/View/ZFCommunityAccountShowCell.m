
//
//  ZFCommunityAccountShowCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/2.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountShowCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityPictureModel.h"
#import "UICollectionViewCell+ZFExtension.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "NSString+Extended.h"
#import "UIView+ZFViewCategorySet.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIImage+ZFExtended.h"

@interface ZFCommunityAccountShowCell () <ZFInitViewProtocol>
//以下为瀑布流子视图
@property (nonatomic, strong) UIView                    *waterFlowContentView;
@property (nonatomic, strong) UIImageView               *waterFlowPicImageView;
@property (nonatomic, strong) UIView                    *waterFlowMaskView;
@property (nonatomic, strong) UILabel                   *waterFlowContentLab;
/// 暂时处理用户头像可能被压缩
@property (nonatomic, strong) UIView                    *tempUserView;
@property (nonatomic, strong) UIImageView               *waterFlowUserImageView;
@property (nonatomic, strong) UIImageView               *waterFlowRankImageView;

@property (nonatomic, strong) UILabel                   *waterFlowUserLab;
@property (nonatomic, strong) UIButton                  *waterFlowLikeButton;
@end

@implementation ZFCommunityAccountShowCell

#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        //设置cell投影圆角效果
        [self setShadowAndCornerCell];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    [self.contentView addSubview:self.waterFlowContentView];
    [self.waterFlowContentView addSubview:self.waterFlowPicImageView];
    [self.waterFlowContentView addSubview:self.waterFlowMaskView];
    
    [self.waterFlowMaskView addSubview:self.waterFlowContentLab];
    [self.waterFlowMaskView addSubview:self.tempUserView];
    [self.waterFlowMaskView addSubview:self.waterFlowUserImageView];
    [self.waterFlowMaskView addSubview:self.waterFlowUserLab];
    [self.waterFlowMaskView addSubview:self.waterFlowLikeButton];
    [self.waterFlowMaskView addSubview:self.waterFlowRankImageView];
}

/**
 * 设置瀑布流布局
 */
- (void)zfAutoLayoutView {
    [self.waterFlowContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    //图片高度
    CGFloat imageShowHeight = self.showsModel.twoColumnImageHeight;
    if (imageShowHeight == 0.0) {
        imageShowHeight = (KScreenWidth - 10*3) / 2;
    }
    [self.waterFlowPicImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.waterFlowContentView);
        make.height.mas_equalTo(@(imageShowHeight));
    }];
    
    //图片底下所有子控件的高度
    [self.waterFlowMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waterFlowPicImageView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.waterFlowContentView);
        make.bottom.mas_equalTo(self.waterFlowContentView);
    }];
    
    [self.waterFlowContentLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waterFlowMaskView.mas_top).offset(6);
        make.leading.mas_equalTo(self.waterFlowMaskView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.waterFlowMaskView.mas_trailing).offset(-12);
    }];
    
    [self.tempUserView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waterFlowContentLab.mas_bottom).offset(5);
        make.leading.mas_equalTo(self.waterFlowMaskView.mas_leading).offset(12);
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.bottom.mas_equalTo(self.waterFlowMaskView.mas_bottom).offset(-9);
    }];
    
    [self.waterFlowUserImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.waterFlowMaskView.mas_leading).offset(12);
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.centerY.mas_equalTo(self.tempUserView.mas_centerY);
    }];
    
    [self.waterFlowRankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.waterFlowUserImageView.mas_trailing);
        make.bottom.mas_equalTo(self.waterFlowUserImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    
    [self.waterFlowLikeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.waterFlowMaskView.mas_trailing).offset(-11);
        make.centerY.mas_equalTo(self.waterFlowUserImageView.mas_centerY).offset(1);
        make.height.mas_equalTo(kFavesCellMaskHeight);
    }];
    
    [self.waterFlowUserLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.waterFlowUserImageView.mas_trailing).offset(7);
        make.centerY.mas_equalTo(self.waterFlowUserImageView.mas_centerY);
        make.trailing.mas_equalTo(self.waterFlowLikeButton.mas_leading).offset(-8);
    }];
    
    [self.waterFlowUserLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.waterFlowLikeButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.waterFlowLikeButton setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark -===========设置数据源刷新===========

/**
 根据数据源更新Cell布局
 
 @param favesItemModel 数据源Model
 @param typeInteger 布局类型
 */
- (void)setShowsModel:(ZFCommunityAccountShowsModel *)showsModel
{
    _showsModel = showsModel;
    
    //更新约束
    [self zfAutoLayoutView];
    
    //设置瀑布流布局数据源
    [self setupWaterFlowLayoutCellData];
}

/**
 * 设置瀑布流布局数据源
 */
- (void)setupWaterFlowLayoutCellData
{
    //设置帖子的第一张图片
    NSString *imagePath = @"";
    if (_showsModel.reviewPic.count>0) {
        ZFCommunityPictureModel *reviewPicModel = _showsModel.reviewPic[0];
        imagePath = ZFToString(reviewPicModel.bigPic);
    }
    
    if (!_showsModel.randomColor) {
        _showsModel.randomColor = [UIColor colorWithHexString:[ZFThemeManager randomColorString:nil]] ;
    }
    self.waterFlowPicImageView.backgroundColor = _showsModel.randomColor;
    
    [self.waterFlowPicImageView yy_setImageWithURL:[NSURL URLWithString:imagePath]
                                      placeholder:nil];
    //帖子内容, 去掉回车与换行符
    NSString *conteentText = _showsModel.contentAttributedText.string;
    self.waterFlowContentLab.text = [conteentText replaceBrAndEnterChar];
    
    //头像
    self.waterFlowUserLab.text = ZFToString(_showsModel.nickName);
    [self.waterFlowUserImageView yy_setImageWithURL:[NSURL URLWithString:_showsModel.avatar]
                                       placeholder:[UIImage imageNamed:@"public_user"]
                                            options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                           progress:nil
                                          transform:nil
                                         completion:nil];
    //用户是否点赞
    NSInteger likeNum = [_showsModel.likeCount integerValue];
    if (likeNum>0) {
        self.waterFlowLikeButton.selected = _showsModel.isLiked;
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
    
    
    self.waterFlowRankImageView.hidden = YES;
    if ([_showsModel.identify_type integerValue] > 0) {
        [self.waterFlowRankImageView yy_setImageWithURL:[NSURL URLWithString:_showsModel.identify_icon] options:kNilOptions];
        self.waterFlowRankImageView.hidden = NO;
    }
    
}

/**
 * 点赞操作
 */
- (void)likeButtonAction:(UIButton *)sender {
    if (self.communityAccountShowsLikeCompletionHandler) {
        [sender.imageView.layer addAnimation:[sender.imageView zfAnimationFavouriteScale] forKey:@"like"];
        self.communityAccountShowsLikeCompletionHandler(self.showsModel);
    }
}

#pragma mark -===========懒加载瀑布流内容视图===========

/**
 * 初始化瀑布流内容视图
 */
- (UIView *)waterFlowContentView
{
    if(!_waterFlowContentView){
        _waterFlowContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _waterFlowContentView.backgroundColor = [UIColor whiteColor];
        _waterFlowContentView.clipsToBounds = YES;
    }
    return _waterFlowContentView;
}

- (UIImageView *)waterFlowPicImageView {
    if (!_waterFlowPicImageView) {
        _waterFlowPicImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _waterFlowPicImageView.backgroundColor = [UIColor whiteColor];
        _waterFlowPicImageView.contentMode = UIViewContentModeScaleAspectFill;
        _waterFlowPicImageView.clipsToBounds = YES;
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
        CGFloat width = (KScreenWidth - 10*3) / 2 - 12 * 2;
        _waterFlowContentLab.preferredMaxLayoutWidth = width;
    }
    return _waterFlowContentLab;
}

- (UIView *)tempUserView {
    if (!_tempUserView) {
        _tempUserView = [[UIView alloc] initWithFrame:CGRectZero];
        _tempUserView.hidden = YES;
    }
    return _tempUserView;
}
- (UIImageView *)waterFlowUserImageView {
    if (!_waterFlowUserImageView) {
        _waterFlowUserImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _waterFlowUserImageView.backgroundColor = [UIColor whiteColor];
        _waterFlowUserImageView.contentMode = UIViewContentModeScaleAspectFill;
        _waterFlowUserImageView.userInteractionEnabled = YES;
        _waterFlowUserImageView.image = ZFImageWithName(@"public_user");
        _waterFlowUserImageView.layer.cornerRadius = 12.5;
        _waterFlowUserImageView.layer.masksToBounds = YES;
        
//        UIImageView *maskView = [[UIImageView alloc] init];
//        maskView.contentMode = UIViewContentModeScaleAspectFill;
//        maskView.frame = CGRectMake(0, 0, 25, 25);
//        maskView.image = ZFImageWithName(@"public_user");
//        _waterFlowUserImageView.maskView = maskView;
    }
    return _waterFlowUserImageView;
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
        [_waterFlowLikeButton setTitleColor:ZFCOLOR(102, 102, 102, 1.0) forState:UIControlStateNormal];
        [_waterFlowLikeButton setTitleColor:ZFC0xFE5269() forState:UIControlStateSelected];
        [_waterFlowLikeButton setImage:[UIImage imageNamed:@"Community_like_gray"] forState:UIControlStateNormal];
        [_waterFlowLikeButton setImage:[[UIImage imageNamed:@"Community_like_red"] imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
        _waterFlowLikeButton.imageView.backgroundColor = [UIColor whiteColor];
        [_waterFlowLikeButton addTarget:self action:@selector(likeButtonAction:)
                       forControlEvents:UIControlEventTouchUpInside];
    
        [_waterFlowLikeButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:3];
        [_waterFlowLikeButton convertUIWithARLanguage];
    }
    return _waterFlowLikeButton;
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

@end

