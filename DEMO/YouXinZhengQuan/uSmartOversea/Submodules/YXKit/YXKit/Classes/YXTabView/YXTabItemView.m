//
//  YXTabItemView.m
//  ScrollViewDemo
//
//  Created by ellison on 2018/9/30.
//  Copyright © 2018 ellison. All rights reserved.
//

#import "YXTabItemView.h"

@interface YXTabItemView()

@property (nonatomic, strong) UIView *redDotView;

@end

@implementation YXTabItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeViews];
    }
    return self;
}

- (void)initializeViews
{
    self.contentView.clipsToBounds = YES;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_titleLabel];
    
    [self.contentView addSubview:self.redDotView];
    [self.contentView addSubview:self.arrowImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.center = self.contentView.center;
    self.redDotView.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame), CGRectGetMinY(_titleLabel.frame) - 2.5, 8, 8);
    UIImage *image = self.arrowImageView.image;
    CGSize imagesize = image.size;
    
    self.arrowImageView.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame)+2, CGRectGetMinY(_titleLabel.frame), image.size.width, image.size.height);
}

- (void)reloadItem:(YXTabItem*)item {
    _item = item;
    
    if (item.selected) {
        _titleLabel.font = item.titleSelectedFont;
        _titleLabel.textColor = item.titleSelectedColor;
        self.backgroundColor = item.selectedColor;
        self.layer.borderColor = item.layerSelectedColor.CGColor;
    } else {
        _titleLabel.font = item.titleFont;
        _titleLabel.textColor = item.titleColor;
        self.backgroundColor = item.color;
        self.layer.borderColor = item.layerColor.CGColor;
    }
    self.layer.borderWidth = item.layerWidth;
    self.layer.cornerRadius = item.cornerRadius;
    self.contentView.clipsToBounds = item.clipsToBounds;
    _titleLabel.text = item.title;
    [_titleLabel sizeToFit];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setHideRedDot:(BOOL)hideRedDot {
    _hideRedDot = hideRedDot;
    
    self.redDotView.hidden = hideRedDot;
}


- (UIView *)redDotView {
    if (!_redDotView){
        _redDotView = [UIView new];
        _redDotView.backgroundColor = UIColor.redColor;
        _redDotView.hidden = true;
        _redDotView.layer.cornerRadius = 4;
        _redDotView.layer.masksToBounds = true;
    }
    return _redDotView;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
    }
    
    return _arrowImageView;
}

@end
