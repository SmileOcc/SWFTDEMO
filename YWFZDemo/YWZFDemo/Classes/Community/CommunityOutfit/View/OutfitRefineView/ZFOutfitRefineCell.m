//
//  ZFOutfitRefineCell.m
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFOutfitRefineCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "UIImage+ZFExtended.h"

@interface ZFOutfitRefineCell ()<ZFInitViewProtocol>

@property (nonatomic,strong)  UILabel           *titleLabel;
@property (nonatomic,strong)  UIImageView       *arrowImgView;
@property (nonatomic,strong)  CALayer           *line;

@end

@implementation ZFOutfitRefineCell

#pragma mark - Init Method
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.arrowImgView];
    [self.layer addSublayer:self.line];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(24);
    }];
    
    [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
    }];
    
    self.line.frame = CGRectMake(0, 44 - MIN_PIXEL, KScreenWidth - 75, MIN_PIXEL);
}

#pragma mark - Setter
- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    self.arrowImgView.image = isSelect ? [[UIImage imageNamed:@"refine_select"] imageWithColor:ZFC0xFE5269()] : nil;
    
    [self setNeedsDisplay];
}


#pragma mark - Public Methods
+ (NSString *)setIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - Rewrite Methods
-(void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = @"";
    self.arrowImgView.image = nil;
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = ZFCOLOR(153, 153, 153, 1);
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
    }
    return _line;
}


@end
