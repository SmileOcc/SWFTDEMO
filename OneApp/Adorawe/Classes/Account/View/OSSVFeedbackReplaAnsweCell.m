//
//  OSSVFeedbackReplaAnsweCell.m
// XStarlinkProject
//
//  Created by odd on 2021/4/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVFeedbackReplaAnsweCell.h"
#import "CYAnyCornerRadiusUtil.h"

@implementation OSSVFeedbackReplaAnsweCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.backgroundColor = [OSSVThemesColors stlClearColor];
        
        [self.contentView addSubview:self.bgColorView];
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.iconImg];
        [self.contentView addSubview:self.replyLabel];
        
        [self.bgColorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.top.mas_equalTo(self.contentView.mas_top);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-10);
        }];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.top.mas_equalTo(self.contentView.mas_top);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
        
        [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bgView.mas_leading).offset(12);
            make.top.mas_equalTo(self.bgView.mas_top).offset(12);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        [self.replyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconImg.mas_top);
            make.leading.mas_equalTo(self.iconImg.mas_trailing).offset(8);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-12);
            make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-12);
            make.height.mas_greaterThanOrEqualTo(24);
        }];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    
    self.bgView.layer.mask = nil;
     //切圆角
     CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CornerRadii cornerRadii = CornerRadiiMake(15, 0, 0, 0);
    
    if (self.isFirst && self.isLast) {
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            cornerRadii = CornerRadiiMake(0, 15, 4, 4);
        }
        CGPathRef path = CYPathCreateWithRoundedRect(self.bgView.bounds,cornerRadii);
        shapeLayer.path = path;
        CGPathRelease(path);
        self.bgView.layer.mask = shapeLayer;
        
    } else if (self.isFirst) {
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            cornerRadii = CornerRadiiMake(0, 15, 0, 0);
        }
        CGPathRef path = CYPathCreateWithRoundedRect(self.bgView.bounds,cornerRadii);
        shapeLayer.path = path;
        CGPathRelease(path);
        self.bgView.layer.mask = shapeLayer;
        
    } else if(self.isLast) {
        cornerRadii = CornerRadiiMake(0, 0, 4, 4);
        CGPathRef path = CYPathCreateWithRoundedRect(self.bgView.bounds,cornerRadii);
        shapeLayer.path = path;
        CGPathRelease(path);
        self.bgView.layer.mask = shapeLayer;
    }
}

- (void)updateModel:(STLFeedbackReplayMessageModel *)model first:(BOOL)isFirst last:(BOOL)last {
    self.isFirst = isFirst;
    self.isLast = last;
    self.model = model;
}
- (void)setModel:(STLFeedbackReplayMessageModel *)model {
    _model = model;
    
    self.replyLabel.text = STLToString(model.content);
    
    if(self.isLast) {
        [self.replyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-12);
        }];
    } else {
        [self.replyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(0);

        }];
    }
    
    [self setNeedsDisplay];
}

- (UIView *)bgColorView {
    if (!_bgColorView) {
        _bgColorView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgColorView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _bgColorView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _bgView;
}

- (YYAnimatedImageView *)iconImg {
    if (!_iconImg) {
        _iconImg = [[YYAnimatedImageView alloc] init];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _iconImg.image = [UIImage imageNamed:@"replay_aw_ar"];
        } else {
            _iconImg.image = [UIImage imageNamed:@"replay_aw"];
        }
    }
    return _iconImg;
}


- (UILabel *)replyLabel {
    if (!_replyLabel) {
        _replyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _replyLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _replyLabel.numberOfLines = 0;
        _replyLabel.font = [UIFont systemFontOfSize:13];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _replyLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _replyLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _replyLabel;
}

@end
