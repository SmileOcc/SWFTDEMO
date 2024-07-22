//
//  CategorySubCell.m
//  ListPageViewController
//
//  Created by YW on 6/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategorySubCell.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "UIImage+ZFExtended.h"

@interface CategorySubCell ()
@property (nonatomic, strong)  YYLabel          *titleLabel;
@property (nonatomic, strong)  UIImageView      *arrowImgView;
@property (nonatomic, strong)  CALayer          *line;
@end

@implementation CategorySubCell
#pragma mark - Init Method
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureSubViews];
        [self autoLayoutSubViews];
    }
    return self;
}

#pragma mark - Initialize
- (void)configureSubViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.arrowImgView];
    [self.layer addSublayer:self.line];
}

- (void)autoLayoutSubViews {
    [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-20);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(40);
        make.centerY.equalTo(self.contentView);
    }];
    
    self.line.frame = CGRectMake(0, 44 - MIN_PIXEL, KScreenWidth, MIN_PIXEL);
}

#pragma mark - Public Methods
+ (NSString *)setIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - Setter
- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    self.arrowImgView.image = isSelect ? [[UIImage imageNamed:@"refine_select"] imageWithColor:ZFC0xFE5269()] : nil;
    
    [self setNeedsDisplay];
}


#pragma mark - Getter
- (YYLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [YYLabel new];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _titleLabel.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    }
    return _titleLabel;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
    }
    return _arrowImgView;
}

- (CALayer *)line {
    if (!_line) {
        _line = [CALayer layer];
        _line.backgroundColor = ZFCOLOR(221, 221, 221, 1).CGColor;
        _line.hidden = YES;
    }
    return _line;
}



@end
