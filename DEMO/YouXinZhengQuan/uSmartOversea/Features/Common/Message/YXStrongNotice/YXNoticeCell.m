//
//  YXNoticeCell.m
//  YouXinZhengQuan
//
//  Created by Evan on 2021/10/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXNoticeCell.h"
#import <Masonry/Masonry.h>

@implementation YXNoticeCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (YXMarqueeLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[YXMarqueeLabel alloc] init];
        _titleLabel.pauseDurationWhenMoveToEdge = 0;
        _titleLabel.fadeWidthPercent = 0;
        _titleLabel.adjustsFontSizeToFitWidth = NO;
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}

@end
