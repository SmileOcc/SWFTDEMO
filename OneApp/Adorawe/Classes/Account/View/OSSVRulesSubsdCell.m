//
//  OSSVRulesSubsdCell.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVRulesSubsdCell.h"

@interface OSSVRulesSubsdCell()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *valueLab;

@end

@implementation OSSVRulesSubsdCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}


- (void)setUpView{
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.valueLab];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(-0.5);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(15);
    }];
    
    [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        make.centerX.mas_equalTo(self.contentView.mas_leading);
    }];
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#A8ACBC"];
    }
    return _lineView;
}

- (UILabel *)valueLab{
    if (!_valueLab) {
        _valueLab = [UILabel new];
        _valueLab.font = FontWithSize(12);
        _valueLab.textColor = OSSVThemesColors.col_B62B21;
    }
    return _valueLab;
}

- (void)hideLab{
    self.valueLab.hidden = YES;
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(-0.5);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(18);
    }];

}

- (void)showLabWithSure:(BOOL)isShow{
    if (isShow) {
        self.valueLab.hidden = NO;
    }else{
        self.valueLab.hidden = YES;
    }
    
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(-0.75);
        make.width.mas_equalTo(2);
        make.height.mas_equalTo(30);
    }];
}

- (void)valueLabText:(NSString *)title{
    self.valueLab.text = title;
}

@end
