//
//  YXCycleViewCell.m
//  uSmartOversea
//
//  Created by JC_Mac on 2018/11/14.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXCycleViewCell.h"
#import "UIView+SDExtension.h"
//#import "uSmartOversea-Swift.h"
#import <QMUIKit.h>
#import <Masonry/Masonry.h>

@implementation YXCycleViewCell
{
    __weak QMUILabel *_titleLabel;
    __weak UILabel *_labelLab;
    __weak UIView *_backView;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupImageView];
        [self setupTitleLabel];
    }
    
    return self;
}

- (void)setTitleLabelBackgroundColor:(UIColor *)titleLabelBackgroundColor
{
    _titleLabelBackgroundColor = titleLabelBackgroundColor;
    _titleLabel.backgroundColor = titleLabelBackgroundColor;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor
{
    _titleLabelTextColor = titleLabelTextColor;
    _titleLabel.textColor = titleLabelTextColor;
}

- (void)setTitleLabelTextFont:(UIFont *)titleLabelTextFont
{
    _titleLabelTextFont = titleLabelTextFont;
    _titleLabel.font = titleLabelTextFont;
}

- (void)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)setupTitleLabel
{
    
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    
    backView.backgroundColor = [UIColorMakeWithHex(@"#282834") colorWithAlphaComponent:0.8];
    _backView.hidden = YES;
    [self.contentView addSubview:_backView];

    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(37);
    }];
    
    
    UILabel *lableLab = [[UILabel alloc] init];
    _labelLab = lableLab;
    _labelLab.font = [UIFont systemFontOfSize:10];
    
    _labelLab.textColor = UIColorMakeWithHex(@"#F86262");
    _labelLab.layer.cornerRadius = 1;
    _labelLab.layer.borderColor = UIColorMakeWithHex(@"#F86262").CGColor;
    _labelLab.layer.borderWidth = 1 / UIScreen.mainScreen.scale;
    _labelLab.clipsToBounds = YES;
    
    _labelLab.hidden = YES;
    [self.contentView addSubview:_labelLab];
    
    [_labelLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-12);
        make.height.mas_equalTo(15);
    }];
 
    QMUILabel *titleLabel = [[QMUILabel alloc] init];
    _titleLabel = titleLabel;
    _titleLabel.hidden = YES;
    _titleLabel.minimumScaleFactor = 0.8;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:titleLabel];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
  
    _titleLabel.attributedText = [self attributedStringWithText:[NSString stringWithFormat:@"%@", title] font:_titleLabel.font textColor:_titleLabel.textColor lineSpacing:self.lineSpacing];

    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    if (_titleLabel.hidden) {
        _titleLabel.hidden = NO;

    }
}

- (void)setAttributeTitle:(NSAttributedString *)attributeTitle {
    _attributeTitle = attributeTitle;
    _titleLabel.attributedText = attributeTitle;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    if (_titleLabel.hidden) {
        _titleLabel.hidden = NO;
    }
}

    
- (NSMutableAttributedString *)attributedStringWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor lineSpacing:(CGFloat)lineSpacing{
    
    if (text.length == 0) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:lineSpacing];
    return [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor, NSParagraphStyleAttributeName : paragraphStyle1}];
}

- (void)setLable:(NSString *)lable {
    
    _lable = [lable copy];
    if (lable.length > 0) {
        if (lable.length>8) {
            lable = [NSString stringWithFormat:@" %@... ", [lable substringToIndex:8]];
        }
        _labelLab.text = [NSString stringWithFormat:@" %@ ",lable];
    }else{
        _labelLab.text = @"";
    }
    
    if (_labelLab.hidden) {
        _labelLab.hidden = NO;
    }
    [_labelLab sizeToFit];
    [self layoutSubviews];
}

- (void)setOnlyDisplayText:(BOOL)onlyDisplayText{
    _onlyDisplayText = onlyDisplayText;
    if (self.onlyDisplayText) {
        _titleLabel.numberOfLines = 2;
    }
}

- (void)setShowBackView:(BOOL)showBackView {
    
    _showBackView = showBackView;
    if (_showBackView == YES) {
        _backView.hidden = NO;
    }
}

-(void)setTitleLabelTextAlignment:(NSTextAlignment)titleLabelTextAlignment
{
    _titleLabelTextAlignment = titleLabelTextAlignment;
    _titleLabel.textAlignment = titleLabelTextAlignment;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.onlyDisplayText) {
     
        _titleLabel.frame = self.bounds;
        
        if (self.onlyDisplayTextWithImage) {
            _titleLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 35, 0, 0);
            CGFloat height = 20;
            if (height > self.bounds.size.height) {
                height = self.bounds.size.height;
            }
            _imageView.frame = CGRectMake(0, 0, 20, height);
            _imageView.center = CGPointMake(17, self.bounds.size.height / 2);
        }
      
    } else {
        _imageView.frame = self.bounds;
    
        CGFloat titleLabelX = 10;
        if (self.lable.length > 0) {

            titleLabelX = 10+_labelLab.frame.size.width + 3;
        }
        CGFloat titleLabelW = self.sd_width - titleLabelX - 10;
        CGFloat titleLabelH = 22;
        CGFloat titleLabelY = self.sd_height - titleLabelH - 8;
        _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    }

}

@end
