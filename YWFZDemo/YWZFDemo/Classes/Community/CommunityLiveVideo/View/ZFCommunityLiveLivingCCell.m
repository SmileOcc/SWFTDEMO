//
//  ZFCommunityLiveVideoLiveCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveLivingCCell.h"

#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "UICollectionViewCell+ZFExtension.h"
#import "UIView+ZFViewCategorySet.h"
#import "SystemConfigUtils.h"
#import "ZFLocalizationString.h"

#import "ZFCommunityVideoLiveMarkView.h"


@interface ZFCommunityLiveLivingCCell()

@property (nonatomic, strong) ZFCommunityVideoLiveMarkView      *markTipView;
@property (nonatomic, strong) UILabel                           *descLabel;
@property (nonatomic, strong) YYAnimatedImageView               *playImageView;

@property (nonatomic, strong) UIView                            *bottomView;
@property (nonatomic, strong) UILabel                           *brosweLabel;


@end

@implementation ZFCommunityLiveLivingCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    
    self.backgroundColor = ZFCOLOR_WHITE;
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    
    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:self.playImageView];
    [self.contentView addSubview:self.markTipView];
    
    [self.contentView addSubview:self.descLabel];
    
    [self.contentView addSubview:self.bottomView];
    [self.contentView addSubview:self.brosweLabel];
    
    //设置cell投影圆角效果
    [self setShadowAndCornerCell];
}

- (void)zfAutoLayoutView {
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(100);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(8);
        make.trailing.mas_equalTo(self.contentView).offset(-8);
        make.top.mas_equalTo(self.coverImageView.mas_bottom).offset(4);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(40);
    }];
    
    [self.brosweLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bottomView.mas_leading).offset(8);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
    }];
    
    
    [self.markTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.top.mas_equalTo(self.contentView.mas_top).offset(8);
    }];
    
    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.coverImageView.mas_centerX);
        make.centerY.mas_equalTo(self.coverImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

- (void)setLiveItemModel:(ZFCommunityLiveListModel *)liveItemModel {
    _liveItemModel = liveItemModel;
    
    [self.coverImageView yy_setImageWithURL:[NSURL URLWithString:liveItemModel.ios_pic_url]
                                   placeholder:[UIImage imageNamed:@"community_loading_product"]
                                       options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                      progress:nil
                                     transform:nil
                                    completion:nil];
    
    [self.coverImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(liveItemModel.oneColumnImageHeight);
    }];
    
    self.descLabel.attributedText = liveItemModel.contentAttributedText;
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(liveItemModel.commentHeight);
    }];

    self.brosweLabel.text = [NSString stringWithFormat:@"%@ %@",ZFToString(liveItemModel.format_view_num),ZFLocalizedString(@"Community_Lives_Live_Views", nil)];
    
    if ([liveItemModel.type integerValue] == ZFCommunityLiveStateReady) {//待直播
        
        self.markTipView.hidden = NO;
        [self.markTipView updateMarkImage:ZFImageWithName(@"community_wait_hourglass") text:liveItemModel.liveStateAttributedText];
        
    } else if ([liveItemModel.type integerValue] == ZFCommunityLiveStateLiving) {//直播中
        
        self.markTipView.hidden = NO;
        [self.markTipView updateMarkImage:nil text:liveItemModel.liveStateAttributedText];
        
    } else {
        self.markTipView.hidden = YES;
    }

}


#pragma mark - Property Method

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _bottomView;
}


- (ZFCommunityVideoLiveMarkView *)markTipView {
    if (!_markTipView) {
        
        UIRectCorner corners = (UIRectCornerTopRight | UIRectCornerBottomRight);
        if ([SystemConfigUtils isRightToLeftShow]) {
            corners = (UIRectCornerTopLeft | UIRectCornerBottomLeft);
        }
        _markTipView = [[ZFCommunityVideoLiveMarkView alloc] initWithFrame:CGRectZero markImage:nil dotColor:ZFC0xFE5269() textColor:ZFC0xFFFFFF() addCorners:corners];
        _markTipView.backgroundColor = ZFC0x000000_06();
        _markTipView.hidden = YES;
    }
    return _markTipView;
}

- (YYAnimatedImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
    }
    return _coverImageView;
}

- (YYAnimatedImageView *)playImageView {
    if (!_playImageView) {
        _playImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _playImageView.image = ZFImageWithName(@"community_home_play_big");
    }
    return _playImageView;
}


- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.numberOfLines = 2;
        _descLabel.textColor = ZFC0x2D2D2D();
        _descLabel.font = ZFFontSystemSize(14);
    }
    return _descLabel;
}

- (UILabel *)brosweLabel {
    if (!_brosweLabel) {
        _brosweLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _brosweLabel.textColor = ZFC0x999999();
        _brosweLabel.font = ZFFontSystemSize(12);
    }
    return _brosweLabel;
}
@end
