//
//  OSSVSearchKeyWordMatchTCell.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVSearchKeyWordMatchTCell.h"

@interface OSSVSearchKeyWordMatchTCell()

@property (nonatomic, strong) UILabel *mainLab;
@property (nonatomic, strong) UIButton *rightBtn;

@end

@implementation OSSVSearchKeyWordMatchTCell


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView]; 
    }
    return self;
}

- (void)setupView{
    [self.contentView addSubview:self.mainLab];
    [self.contentView addSubview:self.rightBtn];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.mainLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.rightBtn.mas_leading);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    
}
- (void)setKey:(NSString *)key{
    _key = key;
}

- (void)setKeyWord:(NSString *)keyWord{
    _keyWord = keyWord;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:_keyWord];
    NSRange keyRange = [_keyWord rangeOfString:_key];
    if (keyRange.length != 0) {
        //添加文字颜色
        [attStr addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_B2B2B2 range:keyRange];
    }
    _mainLab.attributedText = attStr;
}

- (UILabel *)mainLab{
    if (!_mainLab) {
        _mainLab = [UILabel new];
        _mainLab.font = FontWithSize(14);
        _mainLab.textColor = OSSVThemesColors.col_0D0D0D;
        _mainLab.numberOfLines = 1;
    }
    return _mainLab;
}

- (UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setImage:[UIImage imageNamed:@"arrow_beveled"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _rightBtn;
}

- (void)rightBtnAction:(UIButton *)sender{
    if (self.SearchMatchRightblock) {
        self.SearchMatchRightblock(self.keyWord);
    }
}

@end
