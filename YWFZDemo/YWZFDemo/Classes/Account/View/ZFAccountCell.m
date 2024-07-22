//
//  ZFAccountCell.m
//  ZZZZZ
//
//  Created by YW on 2018/3/16.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAccountCell.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFAccountCell ()
@property (nonatomic, strong)  UIImageView      *iconImgView;
@property (nonatomic, strong)  UILabel          *iconDotLabel;
@property (nonatomic, strong)  UILabel          *titleLabel;
@property (nonatomic, strong)  UILabel          *titleBageLabel;
@property (nonatomic, strong)  UILabel          *subTitleLabel;
@end

@implementation ZFAccountCell

#pragma mark - Init Method
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self configureSubViews];
        [self autoLayoutSubViews];
    }
    return self;
}

#pragma mark - Initialize
- (void)configureSubViews {
    [self.contentView addSubview:self.iconImgView];
    [self.contentView addSubview:self.iconDotLabel];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.titleBageLabel];
    [self.contentView addSubview:self.subTitleLabel];
}

- (void)autoLayoutSubViews {
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(15);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    [self.iconDotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconImgView.mas_trailing).offset(-3);
        make.centerY.mas_equalTo(self.iconImgView.mas_top).offset(3);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.iconImgView.mas_trailing).offset(15);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    
    [self.titleBageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(8);
        make.centerY.mas_equalTo(self.titleLabel);
        make.width.mas_greaterThanOrEqualTo(23);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-5);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
}

/**
 * 设置数据源
 */
- (void)setCellDataDic:(NSDictionary *)cellDataDic
{
    _cellDataDic = cellDataDic;
    self.iconImgView.image = ZFImageWithName(cellDataDic[kCellImageKey]);
    self.titleLabel.text = cellDataDic[kCellTextKey];
    self.subTitleLabel.text = ZFToString(cellDataDic[kCellSubTextKey]);
    
    //处理订单数量
    NSInteger titleBageNum = [cellDataDic[kCellShowTitleBageKey] integerValue];
    if (titleBageNum>0) {
        self.titleBageLabel.hidden = NO;
        NSString *showBageStr = @"99+   ";
        if (titleBageNum <= 99) {
            showBageStr = [NSString stringWithFormat:@"%zd   ",titleBageNum];
        }
        self.titleBageLabel.text = ZFToString(showBageStr);
    } else {
        self.titleBageLabel.hidden = YES;
    }
    
    //处理优惠券红点
    self.iconDotLabel.hidden = ![cellDataDic[kCellShowIconDotKey] boolValue];
}


-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    self.titleBageLabel.backgroundColor = ZFCOLOR(247, 173, 75, 1.0);
    self.iconDotLabel.backgroundColor = ZFCOLOR(247, 173, 75, 1.0);
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    self.titleBageLabel.backgroundColor = ZFCOLOR(247, 173, 75, 1.0);
    self.iconDotLabel.backgroundColor = ZFCOLOR(247, 173, 75, 1.0);
}

#pragma mark - Getter

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
    }
    return _iconImgView;
}

- (UILabel *)iconDotLabel {
    if (!_iconDotLabel) {
        _iconDotLabel = [UILabel new];
        _iconDotLabel.backgroundColor = ZFCOLOR(247, 173, 75, 1.0);
        _iconDotLabel.layer.cornerRadius = 4;
        _iconDotLabel.layer.masksToBounds = YES;
    }
    return _iconDotLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = ZFFontSystemSize(15);
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1);
    }
    return _titleLabel;
}

- (UILabel *)titleBageLabel {
    if (!_titleBageLabel) {
        _titleBageLabel = [UILabel new];
        _titleBageLabel.font = ZFFontSystemSize(14);
        _titleBageLabel.backgroundColor = ZFCOLOR(247, 173, 75, 1.0);
        _titleBageLabel.textColor = [UIColor whiteColor];
        _titleBageLabel.layer.cornerRadius = 8;
        _titleBageLabel.layer.masksToBounds = YES;
        _titleBageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleBageLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel new];
        _subTitleLabel.font = ZFFontSystemSize(18);
        _subTitleLabel.textColor = ZFCOLOR(153, 153, 153, 1);
    }
    return _subTitleLabel;
}

@end
