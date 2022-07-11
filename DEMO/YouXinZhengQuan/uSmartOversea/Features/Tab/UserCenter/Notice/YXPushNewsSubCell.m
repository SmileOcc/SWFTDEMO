//
//  YXPushNewsSubCell.m
//  YouXinZhengQuan
//
//  Created by suntao on 2021/4/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXPushNewsSubCell.h"
#import "YXNoticeSettingModel.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"
#import "YXNoticeAppViewModel.h"

@interface YXPushNewsSubCell ()

@property (nonatomic, strong) QMUIButton * allButton;
@property (nonatomic, strong) QMUIButton * selectedButton;
@property (nonatomic, strong) QMUIButton * importButton;

@end

@implementation YXPushNewsSubCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(instancetype)cellWithTableView:(UITableView *)tableview
{
    YXPushNewsSubCell *cell = [tableview dequeueReusableCellWithIdentifier:NSStringFromClass([YXPushNewsSubCell class])];
    if (cell==nil) {
        cell = [[YXPushNewsSubCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([YXPushNewsSubCell class])];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialUI];
    }
    return self;
}

-(void)setModel:(YXNoticeSettingModel *)model
{
    if (model) {
        _model = model;
        self.allButton.selected = NO;
        self.selectedButton.selected = NO;
        self.importButton.selected = NO;
        if (model.newsType == YXNewsNoticeTypeAll) {
            self.allButton.selected = YES;
        }else if(model.newsType == YXNewsNoticeTypeSelected){
            self.selectedButton.selected = YES;
        }else{
            self.importButton.selected = YES;
        }
    }
}

#pragma mark - 设置UI

- (void)initialUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = QMUITheme.foregroundColor;
    self.backgroundColor = QMUITheme.foregroundColor;
    [self.contentView addSubview:self.allButton];
    [self.contentView addSubview:self.selectedButton];
    [self.contentView addSubview:self.importButton];
    [self.allButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.bottom.mas_equalTo(0);
    }];
    [self.selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.bottom.mas_equalTo(0);
    }];
    [self.importButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12);
        make.top.bottom.mas_equalTo(0);
    }];
}

-(void)allClick:(UIButton *)sender
{
    if (self.model.newsType != YXNewsNoticeTypeAll && self.model) {
        self.model.newsType = YXNewsNoticeTypeAll;
        if (self.selectedBlock) {
            self.selectedBlock(self.model);
        }
    }
}
-(void)seletedClick:(UIButton *)sender
{
    if (self.model.newsType != YXNewsNoticeTypeSelected && self.model) {
        self.model.newsType = YXNewsNoticeTypeSelected;
        if (self.selectedBlock) {
            self.selectedBlock(self.model);
        }
    }
}
-(void)importantClick:(UIButton *)sender
{
    if (self.model.newsType != YXNewsNoticeTypeImportant && self.model) {
        self.model.newsType = YXNewsNoticeTypeImportant;
        if (self.selectedBlock) {
            self.selectedBlock(self.model);
        }
    }
}
-(QMUIButton *)allButton
{
    if (!_allButton) {
        _allButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_allButton setTitleColor:[QMUITheme textColorLevel2] forState:UIControlStateNormal];
        [_allButton setTitle:[YXLanguageUtility kLangWithKey:@"push_news_all"] forState:UIControlStateNormal];
        [_allButton setImage:[UIImage imageNamed:@"settings_choose"] forState:UIControlStateSelected];
        [_allButton setImage:[UIImage imageNamed:@"settings_nochoose"] forState:UIControlStateNormal];
        _allButton.titleLabel.font = [UIFont normalFont14];
        _allButton.imagePosition = QMUIButtonImagePositionLeft;
        _allButton.spacingBetweenImageAndTitle = 5;
        [_allButton addTarget:self action:@selector(allClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allButton;
}

-(QMUIButton *)selectedButton
{
    if (!_selectedButton) {
        _selectedButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_selectedButton setTitleColor:[QMUITheme textColorLevel2] forState:UIControlStateNormal];
        [_selectedButton setTitle:[YXLanguageUtility kLangWithKey:@"push_news_seleted"] forState:UIControlStateNormal];
        [_selectedButton setImage:[UIImage imageNamed:@"settings_choose"] forState:UIControlStateSelected];
        [_selectedButton setImage:[UIImage imageNamed:@"settings_nochoose"] forState:UIControlStateNormal];
        _selectedButton.titleLabel.font = [UIFont normalFont14];
        _selectedButton.imagePosition = QMUIButtonImagePositionLeft;
        _selectedButton.spacingBetweenImageAndTitle = 5;
        [_selectedButton addTarget:self action:@selector(seletedClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedButton;
}

-(QMUIButton *)importButton
{
    if (!_importButton) {
        _importButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_importButton setTitleColor:[QMUITheme textColorLevel2] forState:UIControlStateNormal];
        [_importButton setTitle:[YXLanguageUtility kLangWithKey:@"push_news_import"] forState:UIControlStateNormal];
        [_importButton setImage:[UIImage imageNamed:@"settings_choose"] forState:UIControlStateSelected];
        _importButton.titleLabel.font = [UIFont normalFont14];
        [_importButton setImage:[UIImage imageNamed:@"settings_nochoose"] forState:UIControlStateNormal];
        _importButton.imagePosition = QMUIButtonImagePositionLeft;
        _importButton.spacingBetweenImageAndTitle = 5;
        [_importButton addTarget:self action:@selector(importantClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _importButton;
}
@end
