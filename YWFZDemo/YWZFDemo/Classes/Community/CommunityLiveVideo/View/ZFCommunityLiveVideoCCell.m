//
//  ZFCommunityLiveVideoVideoCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveVideoCCell.h"

#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"

@interface ZFCommunityLiveVideoCCell()<ZFInitViewProtocol>

@property (nonatomic, strong) UIView                     *headerView;
@property (nonatomic, strong) UILabel                    *timeLabel;
@property (nonatomic, strong) YYAnimatedImageView        *coverImageView;
@property (nonatomic, strong) UILabel                    *descLabel;
@property (nonatomic, strong) UILabel                    *brosweLabel;

@end

@implementation ZFCommunityLiveVideoCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    
    [self.contentView addSubview:self.headerView];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.brosweLabel];
    
}

- (void)zfAutoLayoutView {
    
}

#pragma mark - Property Method

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _headerView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _timeLabel;
}


- (YYAnimatedImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
    }
    return _coverImageView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _descLabel;
}

- (UILabel *)brosweLabel {
    if (!_brosweLabel) {
        _brosweLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _brosweLabel;
}

@end
