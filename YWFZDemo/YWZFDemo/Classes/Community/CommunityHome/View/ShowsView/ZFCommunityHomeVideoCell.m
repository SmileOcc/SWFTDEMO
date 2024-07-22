//
//  ZFCommunityHomeVideoCell.m
//  ZZZZZ
//
//  Created by YW on 2018/11/21.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeVideoCell.h"
#import "ZFInitViewProtocol.h"
#import "NSString+Extended.h"
#import "UICollectionViewCell+ZFExtension.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCommunityHomeVideoCell()<ZFInitViewProtocol>

@end

@implementation ZFCommunityHomeVideoCell
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

- (void)zfInitView{
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.videoContentView];
    [self.videoContentView addSubview:self.videoPicImageView];
    [self.videoContentView addSubview:self.videoMaskView];
    [self.videoMaskView addSubview:self.videoContentLab];
    [self.videoMaskView addSubview:self.videoNumLab];
    [self.videoMaskView addSubview:self.videoViewsLab];
    
    [self.contentView addSubview:self.videoTimeButton];
    [self.contentView addSubview:self.videoPlayImageView];
    [self.contentView addSubview:self.videoTopButton];
    
    //设置cell投影圆角效果
    [self setShadowAndCornerCell];
}

- (void)zfAutoLayoutView{
    
    [self.videoContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.videoPicImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.videoContentView);
        make.height.mas_equalTo(self.videoPicImageView.mas_width).multipliedBy(1.0);
    }];
    
    [self.videoTopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(4);
        make.trailing.offset(0);
        make.height.mas_equalTo(16);
    }];
    
    //图片底下所有子控件的高度
    [self.videoMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoPicImageView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.videoContentView);
        make.bottom.mas_equalTo(self.videoContentView);
    }];
    
    [self.videoContentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoMaskView.mas_top).offset(6);
        make.leading.mas_equalTo(self.videoMaskView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.videoMaskView.mas_trailing).offset(-12);
    }];
    
    //浏览数Views
    [self.videoNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoContentLab.mas_bottom).offset(7);
        make.leading.mas_equalTo(self.videoMaskView.mas_leading).offset(12);
        make.bottom.mas_equalTo(self.videoMaskView.mas_bottom).offset(-12);
    }];
    
    [self.videoViewsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoContentLab.mas_bottom).offset(7);
        make.leading.mas_equalTo(self.videoNumLab.mas_trailing).offset(2);
        make.bottom.mas_equalTo(self.videoMaskView.mas_bottom).offset(-12);
        make.trailing.mas_equalTo(self.videoContentView.mas_trailing).offset(-2);
    }];
    
    [self.videoTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.videoPicImageView.mas_trailing).offset(-6);
        make.bottom.mas_equalTo(self.videoPicImageView.mas_bottom).offset(-6);
    }];
    
    [self.videoPlayImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.videoPicImageView.mas_leading).offset(12);
        make.top.mas_equalTo(self.videoPicImageView.mas_top).offset(12);
        make.size.mas_equalTo(CGSizeMake(26, 26));
    }];
    
    [self.videoViewsLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.videoNumLab setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.videoNumLab setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}
- (ZFCommunityFavesItemModel *)favesItemModel {
    return _favesItemModel;
}
- (void)setFavesItemModel:(ZFCommunityFavesItemModel *)favesItemModel {
    _favesItemModel = favesItemModel;
    
    if (!_favesItemModel.randomColor) {
        _favesItemModel.randomColor = [UIColor colorWithHexString:[ZFThemeManager randomColorString:nil]] ;
    }
    self.videoPicImageView.backgroundColor = _favesItemModel.randomColor;

    //视频最大分辨率图片，如果没取到，就取高清图片
    @weakify(self)
    [self.videoPicImageView yy_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:ZFCommunityVideoMaxImageUrl,_favesItemModel.video_url]]
                                placeholder:nil
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                                  transform:^UIImage *(UIImage *image, NSURL *url) {
                                      
                                      return image;
                                  } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                      
                                      // 取高清图片
                                      if (from == YYWebImageFromNone || error || image == nil) {
                                          @strongify(self)
                                          [self.videoPicImageView yy_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:ZFCommunityVideoImageUrl,self.favesItemModel.video_url]]
                                                                         placeholder:nil];
                                      }
                                      
                                  }];
    
    if (_favesItemModel.is_top) {
        self.videoTopButton.hidden = NO;
    } else {
        self.videoTopButton.hidden = YES;
    }
    if (!ZFIsEmptyString(_favesItemModel.duration)) {
        [self.videoTimeButton setTitle:ZFToString(_favesItemModel.duration) forState:UIControlStateNormal];
        self.videoTimeButton.hidden = NO;
    } else {
        self.videoTimeButton.hidden = YES;
    }
    
    //话题标题
    NSString *contentText = ZFToString(self.favesItemModel.video_title);
    self.videoContentLab.text = [contentText replaceBrAndEnterChar];
    
    //话题浏览数views
    self.videoNumLab.text = ZFToString(self.favesItemModel.formatView_num);
}


#pragma mark - setter/getter

- (UIView *)videoContentView {
    if(!_videoContentView){
        _videoContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _videoContentView.backgroundColor = [UIColor whiteColor];
    }
    return _videoContentView;
}

- (UIImageView *)videoPicImageView {
    if (!_videoPicImageView) {
        _videoPicImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _videoPicImageView.backgroundColor = [UIColor whiteColor];
        _videoPicImageView.contentMode = UIViewContentModeScaleAspectFill;
        _videoPicImageView.userInteractionEnabled = YES;
    }
    return _videoPicImageView;
}

- (UIView *)videoMaskView {
    if(!_videoMaskView){
        _videoMaskView = [[UIView alloc] initWithFrame:CGRectZero];
        _videoMaskView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
    }
    return _videoMaskView;
}

- (UILabel *)videoContentLab {
    if (!_videoContentLab) {
        _videoContentLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _videoContentLab.backgroundColor = [UIColor whiteColor];
        _videoContentLab.numberOfLines = 2;
        _videoContentLab.font = ZFFontSystemSize(12);
        _videoContentLab.textColor = ZFCOLOR(102, 102, 102, 1.0);
        CGFloat width = kCommunityHomeWaterfallWidth - 12 * 2;
        _videoContentLab.preferredMaxLayoutWidth = width;
    }
    return _videoContentLab;
}

- (UIButton *)videoTopButton {
    if (!_videoTopButton) {
        _videoTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoTopButton setTitle:ZFLocalizedString(@"Community_shows_top", nil) forState:UIControlStateNormal];
        _videoTopButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_videoTopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _videoTopButton.backgroundColor = ZFC0xFE5269();
        _videoTopButton.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
        _videoTopButton.layer.cornerRadius = 2;
        _videoTopButton.layer.masksToBounds = YES;
        _videoTopButton.hidden = YES;
    }
    return _videoTopButton;
}

- (UILabel *)videoNumLab {
    if (!_videoNumLab) {
        _videoNumLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _videoNumLab.font = ZFFontSystemSize(12);
        _videoNumLab.textColor = ZFC0xFE5269();
    }
    return _videoNumLab;
}

- (UILabel *)videoViewsLab {
    if (!_videoViewsLab) {
        _videoViewsLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _videoViewsLab.font = ZFFontSystemSize(12);
        _videoViewsLab.textColor = ZFCOLOR(51, 51, 51, 1.0);
        _videoViewsLab.text = ZFLocalizedString(@"Community_Big_Views",nil);
    }
    return _videoViewsLab;
}

- (UIButton *)videoTimeButton {
    if (!_videoTimeButton) {
        _videoTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoTimeButton.backgroundColor = ColorHex_Alpha(0x000000, 0.5);
        [_videoTimeButton setTitleColor:ColorHex_Alpha(0xFFFFFF, 1.0) forState:UIControlStateNormal];
        _videoTimeButton.titleLabel.font = ZFFontSystemSize(10);
        _videoTimeButton.userInteractionEnabled = NO;
        _videoTimeButton.hidden = YES;
        [_videoTimeButton setContentEdgeInsets:UIEdgeInsetsMake(2, 6, 2, 6)];
    }
    return _videoTimeButton;
}

- (UIImageView *)videoPlayImageView {
    if (!_videoPlayImageView) {
        _videoPlayImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _videoPlayImageView.image = [UIImage imageNamed:@"community_home_play"];
    }
    return _videoPlayImageView;
}
@end
