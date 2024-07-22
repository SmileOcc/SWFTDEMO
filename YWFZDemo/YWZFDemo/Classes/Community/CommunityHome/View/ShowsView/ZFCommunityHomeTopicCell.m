//
//  ZFCommunityHomeTopicCell.m
//  ZZZZZ
//
//  Created by YW on 2018/11/6.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeTopicCell.h"
#import "ZFInitViewProtocol.h"
#import "NSString+Extended.h"
#import "UICollectionViewCell+ZFExtension.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCommunityHomeTopicCell() <ZFInitViewProtocol>

@end

@implementation ZFCommunityHomeTopicCell
@synthesize favesItemModel = _favesItemModel;

+ (NSString *)queryReuseIdentifier{
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
    
    [self.contentView addSubview:self.topicContentView];
    [self.topicContentView addSubview:self.topicPicImageView];
    [self.topicContentView addSubview:self.topicMaskView];
    [self.topicMaskView addSubview:self.topicContentLab];
    [self.topicMaskView addSubview:self.topicNumLab];
    [self.topicMaskView addSubview:self.topicViewsLab];
    [self.contentView addSubview:self.topicTopButton];
    
    //设置cell投影圆角效果
    [self setShadowAndCornerCell];
}

- (void)zfAutoLayoutView {
    
    [self.topicContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    //图片高度
    CGFloat imageShowHeight = self.favesItemModel.twoColumnImageHeight;
    if (imageShowHeight == 0.0) {
        imageShowHeight = kCommunityHomeWaterfallWidth;
    }
    [self.topicPicImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.topicContentView);
        make.height.mas_equalTo(@(imageShowHeight));
    }];
    
    [self.topicTopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(4);
        make.trailing.offset(0);
        make.height.mas_equalTo(16);
    }];
    
    //图片底下所有子控件的高度
    [self.topicMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topicPicImageView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.topicContentView);
        make.bottom.mas_equalTo(self.topicContentView);
    }];
    
    [self.topicContentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topicMaskView.mas_top).offset(6);
        make.leading.mas_equalTo(self.topicMaskView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.topicMaskView.mas_trailing).offset(-12);
//        make.height.mas_greaterThanOrEqualTo(18);
    }];
    
    //浏览数Views
    [self.topicNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topicContentLab.mas_bottom).offset(7);
        make.leading.mas_equalTo(self.topicMaskView.mas_leading).offset(12);
        make.bottom.mas_equalTo(self.topicMaskView.mas_bottom).offset(-12);
    }];
    
    [self.topicViewsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topicContentLab.mas_bottom).offset(7);
        make.leading.mas_equalTo(self.topicNumLab.mas_trailing).offset(2);
        make.bottom.mas_equalTo(self.topicMaskView.mas_bottom).offset(-12);
        make.trailing.mas_equalTo(self.topicContentView.mas_trailing).offset(-2);
    }];
    

    [self.topicViewsLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.topicNumLab setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.topicNumLab setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - setter/getter
- (ZFCommunityFavesItemModel *)favesItemModel {
    return _favesItemModel;
}
- (void)setFavesItemModel:(ZFCommunityFavesItemModel *)favesItemModel {
    _favesItemModel = favesItemModel;
    
    //图片高度
    CGFloat imageShowHeight = self.favesItemModel.twoColumnImageHeight;
    if (imageShowHeight == 0.0) {
        imageShowHeight = kCommunityHomeWaterfallWidth;
    }
    [self.topicPicImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(imageShowHeight));
    }];
    
    if (!_favesItemModel.randomColor) {
        _favesItemModel.randomColor = [UIColor colorWithHexString:[ZFThemeManager randomColorString:nil]] ;
    }
    
    self.topicPicImageView.backgroundColor = _favesItemModel.randomColor;

    //图片
    [self.topicPicImageView yy_setImageWithURL:[NSURL URLWithString:_favesItemModel.ios_listpic]
                                       placeholder:nil];
    
    //话题标题
    NSString *contentText = self.favesItemModel.title;
    self.topicContentLab.text = [contentText replaceBrAndEnterChar];
    
    //话题浏览数views
    self.topicNumLab.text = ZFToString(self.favesItemModel.formatJoin_number);
}

- (UIView *)topicContentView {
    if(!_topicContentView){
        _topicContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _topicContentView.backgroundColor = [UIColor whiteColor];
    }
    return _topicContentView;
}

- (UIImageView *)topicPicImageView {
    if (!_topicPicImageView) {
        _topicPicImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _topicPicImageView.backgroundColor = [UIColor whiteColor];
        _topicPicImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topicPicImageView.userInteractionEnabled = YES;
    }
    return _topicPicImageView;
}

- (UIView *)topicMaskView {
    if(!_topicMaskView){
        _topicMaskView = [[UIView alloc] initWithFrame:CGRectZero];
        _topicMaskView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
    }
    return _topicMaskView;
}

- (UILabel *)topicContentLab {
    if (!_topicContentLab) {
        _topicContentLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _topicContentLab.backgroundColor = [UIColor whiteColor];
        _topicContentLab.numberOfLines = 2;
        _topicContentLab.font = ZFFontSystemSize(12);
        _topicContentLab.textColor = ZFC0x2D2D2D();
        CGFloat width = kCommunityHomeWaterfallWidth - 12 * 2;
        _topicContentLab.preferredMaxLayoutWidth = width;
    }
    return _topicContentLab;
}

- (UIButton *)topicTopButton {
    if (!_topicTopButton) {
        _topicTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topicTopButton setTitle:ZFLocalizedString(@"Community_shows_top", nil) forState:UIControlStateNormal];
        _topicTopButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_topicTopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _topicTopButton.backgroundColor = ZFC0xFE5269();
        _topicTopButton.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
        _topicTopButton.layer.cornerRadius = 2;
        _topicTopButton.layer.masksToBounds = YES;
        _topicTopButton.hidden = YES;
    }
    return _topicTopButton;
}

- (UILabel *)topicNumLab {
    if (!_topicNumLab) {
        _topicNumLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _topicNumLab.font = ZFFontSystemSize(12);
        _topicNumLab.textColor = ZFC0xFE5269();
    }
    return _topicNumLab;
}

- (UILabel *)topicViewsLab {
    if (!_topicViewsLab) {
        _topicViewsLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _topicViewsLab.backgroundColor = [UIColor whiteColor];
        _topicViewsLab.font = ZFFontSystemSize(12);
        _topicViewsLab.textColor = ZFCOLOR(51, 51, 51, 1.0);
        _topicViewsLab.text = ZFLocalizedString(@"Community_Big_Views",nil);
    }
    return _topicViewsLab;
}
@end
