


//
//  ZFCommuntyMoreHotTopicListCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommuntyMoreHotTopicListCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityMoreHotTopicModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCommuntyMoreHotTopicListCell () <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView           *topicImageView;
@property (nonatomic, strong) UIView                *topicTipsView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *joinsLabel;
@property (nonatomic, strong) UIView                *lineView;
@end

@implementation ZFCommuntyMoreHotTopicListCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.topicImageView];
    [self.contentView addSubview:self.topicTipsView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.joinsLabel];
    [self.contentView addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.topicImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(210 *ScreenWidth_SCALE);
    }];
    
    [self.topicTipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topicImageView.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(3, 16));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topicTipsView.mas_trailing).offset(10);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-100);
        make.top.mas_equalTo(self.topicImageView.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
    
    [self.joinsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(- 10);
        make.top.mas_equalTo(self.topicImageView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_bottom).offset(-1);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(@1);
    }];
}

#pragma mark - setter
- (void)setModel:(ZFCommunityMoreHotTopicModel *)model {
    _model = model;
    [self.topicImageView yy_setImageWithURL:[NSURL URLWithString:_model.iosListpic]
                                placeholder:[UIImage imageNamed:@"community_index_banner_loading"]
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                   }
                                  transform:^UIImage *(UIImage *image, NSURL *url) {
                                      //                                image = [image yy_imageByResizeToSize:CGSizeMake(80, 80) contentMode:UIViewContentModeScaleAspectFit];
                                      //                            return [image yy_imageByRoundCornerRadius:10];
                                      return image;
                                  }
                                 completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                     if (from == YYWebImageFromDiskCache) {
                                         YWLog(@"load from disk cache");
                                     }
                                 }];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@",_model.title];
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",_model.joinNumber,ZFLocalizedString(@"Community_Big_Views",nil)]];
    
    if(_model.joinNumber.length > 0) {
        [content addAttribute:NSForegroundColorAttributeName value:ZFC0xFE5269() range:NSMakeRange(0,_model.joinNumber.length)];
    }
    self.joinsLabel.attributedText = content;
}

#pragma mark - getter
- (UIImageView *)topicImageView {
    if (!_topicImageView) {
        _topicImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _topicImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topicImageView.clipsToBounds = YES;
    }
    return _topicImageView;
}

- (UIView *)topicTipsView {
    if (!_topicTipsView) {
        _topicTipsView = [[UIView alloc] initWithFrame:CGRectZero];
        _topicTipsView.backgroundColor = ZFCOLOR(51, 51, 51, 1.0);
    }
    return _topicTipsView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1.0);
    }
    return _titleLabel;
}

- (UILabel *)joinsLabel {
    if (!_joinsLabel) {
        _joinsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _joinsLabel.font = [UIFont systemFontOfSize:12];
        _joinsLabel.textColor = ZFCOLOR(51, 51, 51, 1.0);
    }
    return _joinsLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.0);
    }
    return _lineView;
}


@end
