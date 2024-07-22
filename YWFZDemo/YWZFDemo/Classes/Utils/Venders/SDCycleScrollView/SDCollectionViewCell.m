//
//  SDCollectionViewCell.m
//  SDCycleScrollView
//
//  Created by aier on 15-3-22.
//  Copyright (c) 2015年 GSD. All rights reserved.
//


/*
 
 *********************************************************************************
 *
 * 🌟🌟🌟 新建SDCycleScrollView交流QQ群：185534916 🌟🌟🌟
 *
 * 在您使用此自动轮播库的过程中如果出现bug请及时以以下任意一种方式联系我们，我们会及时修复bug并
 * 帮您解决问题。
 * 新浪微博:GSD_iOS
 * Email : gsdios@126.com
 * GitHub: https://github.com/gsdios
 *
 * 另（我的自动布局库SDAutoLayout）：
 *  一行代码搞定自动布局！支持Cell和Tableview高度自适应，Label和ScrollView内容自适应，致力于
 *  做最简单易用的AutoLayout库。
 * 视频教程：http://www.letv.com/ptv/vplay/24038772.html
 * 用法示例：https://github.com/gsdios/SDAutoLayout/blob/master/README.md
 * GitHub：https://github.com/gsdios/SDAutoLayout
 *********************************************************************************
 
 */


#import "SDCollectionViewCell.h"
#import "UIView+SDExtension.h"
#import <YYWebImage/YYWebImage.h>
#import "SystemConfigUtils.h"

@implementation SDCollectionViewCell
{
    __weak UILabel *_titleLabel;
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
    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
    imageView.layer.shouldRasterize = YES;
    imageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    imageView.layer.allowsEdgeAntialiasing = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds  = YES;
    _imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)setupTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    _titleLabel.hidden = YES;
    [self.contentView addSubview:titleLabel];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
//    _titleLabel.text = [NSString stringWithFormat:@"   %@", title];
#pragma mark ////occ修改
    _titleLabel.text = [NSString stringWithFormat:@"%@", title];

    if (_titleLabel.hidden) {
        _titleLabel.hidden = NO;
    }
}

-(void)setTitleLabelTextAlignment:(NSTextAlignment)titleLabelTextAlignment
{
    _titleLabelTextAlignment = titleLabelTextAlignment;
    _titleLabel.textAlignment = titleLabelTextAlignment;
}

- (void)setAttributedString:(NSAttributedString *)attributedString {
    if ([SystemConfigUtils isRightToLeftShow]) {
        attributedString = [self fetchARLanguageAttr:[attributedString copy]];
    }
    _attributedString = [attributedString copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_titleLabel.attributedText = attributedString;
    });
    if (_titleLabel.hidden) {
        _titleLabel.hidden = NO;
    }
}

- (NSAttributedString *)fetchARLanguageAttr:(NSAttributedString *)showString {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentRight;//文本对齐方式 左右对齐（两边对齐）
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:showString];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, showString.string.length)];//设置段落样式
    return attributedString;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.onlyDisplayText) {
        _titleLabel.frame = self.bounds;
    } else {
        _imageView.frame = self.bounds;
        CGFloat titleLabelW = self.sd_width;
        CGFloat titleLabelH = _titleLabelHeight;
        CGFloat titleLabelX = 0;
        CGFloat titleLabelY = self.sd_height - titleLabelH;
        _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    }
}


#pragma mark ////occ添加
- (void)setTitleLabelumberOfLines:(NSInteger)row {
    _titleLabel.numberOfLines = 2;
}

#pragma mark ////occ添加
- (void)setTitleAttribute:(NSAttributedString *)attributeString {
    if ([attributeString isKindOfClass:[NSAttributedString class]]) {
        _titleLabel.attributedText = attributeString;
        _titleLabel.font = _titleLabelTextFont;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.hidden = NO;
    }
}



@end
