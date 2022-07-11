//
//  YXMineNoticeCell.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/9/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXMineNoticeCell.h"
#import "YXNoticeSettingModel.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@interface YXMineNoticeCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *describeLab;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UILabel * minTitleLab;
@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) UIButton * rightButton;


@end

@implementation YXMineNoticeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    [self initialUI];
}


- (void)initialUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = QMUITheme.foregroundColor;
    self.backgroundColor = QMUITheme.foregroundColor;
    [self.contentView addSubview:self.arrowImageView];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.describeLab];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.switchView];
    [self.contentView addSubview:self.rightButton];
    [self.contentView addSubview:self.minTitleLab];
    [self.contentView addSubview:self.selectImageView];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.describeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-14);
        make.left.greaterThanOrEqualTo(self.titleLab.mas_right).offset(5);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-12);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-32);
        make.top.bottom.mas_equalTo(0);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-16);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.minTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.titleLab.mas_right);
    }];
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.mas_equalTo(-16);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
}

- (void)setModel:(YXNoticeSettingModel *)model {
    _model = model;
    
    self.titleLab.text = model.title;
    UILabel *describeLab = self.describeLab;
    describeLab.text = model.subTitle;
    if (model.isSwitch) {
        self.switchView.hidden = NO;
        describeLab.hidden = YES;
        self.arrowImageView.hidden = YES;
        [self.switchView setOn:model.isOn];
    } else {
        self.switchView.hidden = YES;
        if (model.isArrow) {
            [describeLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.contentView).offset(-37);
            }];
            self.arrowImageView.hidden = NO;
        } else {
            [describeLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.contentView).offset(-14);
            }];
            self.arrowImageView.hidden = YES;
        }
        describeLab.hidden = NO;
    }
    if (model.minTitle.length > 0) {
        self.minTitleLab.hidden = NO;
        self.minTitleLab.text = model.minTitle;
    }else{
        self.minTitleLab.hidden = YES;
    }
    if (model.isShowSelect) {
        self.selectImageView.hidden = NO;
        self.arrowImageView.hidden = YES;
        describeLab.hidden = YES;
        self.switchView.hidden = YES;
        
    }else{
        self.selectImageView.hidden = YES;
    }
    
    if (model.rightButonTitle.length>0) {
        self.rightButton.hidden = NO;
        [self.rightButton setTitle:model.rightButonTitle forState:UIControlStateNormal];
        if (!model.isOn) {
            self.arrowImageView.hidden = NO;
           
            [self.rightButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-32);
            }];
        }else{
            self.arrowImageView.hidden = YES;
            [self.rightButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-12);
            }];
            
        }
    }else{
        self.rightButton.hidden = YES;
    }
    self.lineView.hidden = !model.isShowLine;
    if (model.showBold) {
        self.titleLab.font = [UIFont mediumFont16];
    }else {
        self.titleLab.font = [UIFont normalFont14];
    }
}


#pragma mark- lazy load
- (UILabel *)titleLab {
  
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [QMUITheme textColorLevel1];
        _titleLab.font = [UIFont normalFont14];
    }
    
    return _titleLab;
}

- (UILabel *)describeLab {
   
    if (!_describeLab) {
        _describeLab = [[UILabel alloc] init];
        _describeLab.textColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.5];
        _describeLab.font = [UIFont normalFont14];
        _describeLab.textAlignment = NSTextAlignmentRight;
    }
    return _describeLab;
}

- (UILabel *)minTitleLab {
    if (!_minTitleLab) {
        _minTitleLab = [[UILabel alloc] init];
        _minTitleLab.textColor = [QMUITheme textColorLevel1];
        _minTitleLab.font = [UIFont normalFont12];
        _minTitleLab.hidden = YES;
    }
    return _minTitleLab;
}

- (UIImageView *)arrowImageView {
   
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_arrow"]];
    }
    return _arrowImageView;
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
//        _switchView.transform = CGAffineTransformMakeScale(0.75, 0.75);
        _switchView.onTintColor = QMUITheme.themeTextColor;
    }
    return _switchView;
}

- (UIView *)lineView {
    
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = QMUITheme.separatorLineColor;
    }
    return _lineView;
}

- (UIImageView *)selectImageView {
   
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_item"]];
        _selectImageView.hidden = YES;
    }
    return _selectImageView;
}

-(UIButton *)rightButton
{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton setTitleColor:QMUITheme.themeTextColor forState:UIControlStateNormal];
        [_rightButton setTitleColor:QMUITheme.themeTextColor forState:UIControlStateHighlighted]; 
        _rightButton.hidden = YES;
        _rightButton.userInteractionEnabled = NO;
        _rightButton.titleLabel.font = [UIFont normalFont14];
    }
    return _rightButton;
}

@end
