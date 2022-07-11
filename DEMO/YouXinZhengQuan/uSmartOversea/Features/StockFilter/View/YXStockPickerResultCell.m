//
//  YXStockPickerResultCell.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/4.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockPickerResultCell.h"
#import "uSmartOversea-Swift.h"
#import "YXStockPickerResultLabel.h"
#import <Masonry/Masonry.h>

@interface YXStockPickerResultCell()

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) NSMutableArray<YXStockPickerResultLabel *> *labels;

@property (nonatomic, strong) UIButton *selectButton;
@end

@implementation YXStockPickerResultCell
@dynamic model;

- (void)initialUI {
    [super initialUI];
    self.backgroundColor = QMUITheme.foregroundColor;

    self.qmui_selectedBackgroundColor = QMUITheme.backgroundColor;

    [self.contentView addSubview:self.selectButton];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.symbolLabel];
    //[self.contentView addSubview:self.delayLabel];
    [self.contentView addSubview:self.lineView];

    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(38);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(self.contentView).offset(11);
        make.left.equalTo(self.contentView).offset(23);
        make.width.mas_equalTo(135);
        make.height.mas_equalTo(22);
    }];

    [self.symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel).offset(0);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(15);
        //make.width.equalTo(self.nameLabel);
    }];

//    [self.delayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.symbolLabel.mas_right).offset(4);
//        make.height.width.mas_equalTo(12);
//        make.centerY.equalTo(self.symbolLabel);
//    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(1);
    }];

    [self.contentView addSubview:self.scrollView];
    [self.contentView addGestureRecognizer:self.scrollView.panGestureRecognizer];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right);
        make.top.bottom.right.equalTo(self);
    }];
}

- (void)refreshUI {

    NSString *market = self.model.market.uppercaseString;
   
    self.nameLabel.text = self.model.name;
    if (self.model.code) {
        self.symbolLabel.text = [NSString stringWithFormat:@"%@.%@", self.model.code, market];
    }

    @weakify(self)
    [self.labels enumerateObjectsUsingBlock:^(YXStockPickerResultLabel* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        obj.model = self.model;
    }];

    self.selectButton.selected = self.model.isSelected;
}


#pragma mark - setter

- (void)setIsEditing:(BOOL)isEditing {
    _isEditing = isEditing;
    if (isEditing) {
        self.selectButton.hidden = NO;

        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(38);

        }];
    } else {
        self.selectButton.hidden = YES;

        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(23);
        }];
    }
}

#pragma mark - getter
- (UIImageView *)marketIconView {
    if (_marketIconView == nil) {
        _marketIconView = [[UIImageView alloc] init];
    }
    return _marketIconView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [QMUITheme textColorLevel1];
    }
    return _nameLabel;
}

- (UILabel *)symbolLabel {
    if (_symbolLabel == nil) {
        _symbolLabel = [[UILabel alloc] init];
        _symbolLabel.textColor = [QMUITheme textColorLevel3];
        _symbolLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    }
    return _symbolLabel;
}

- (UILabel *)delayLabel {
    if (_delayLabel == nil) {
        _delayLabel = [UILabel delayLabel];
        _delayLabel.hidden = YES;
    }
    return _delayLabel;
}


- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.05];
    }
    return _lineView;
}

- (UIButton *)selectButton {
    if (_selectButton == nil) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom image:[UIImage imageNamed:@"edit_uncheck_WhiteSkin"] target:self action:@selector(selectButtonAction)];
        [_selectButton setImage:[UIImage imageNamed:@"normal_selected_WhiteSkin"] forState:UIControlStateSelected];
        _selectButton.hidden = YES;
    }
    return _selectButton;
}

- (void)selectButtonAction {

    self.checked = !self.checked;
}


- (void)setChecked:(BOOL)checked {
    _checked = checked;
    self.selectButton.selected = checked;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.userInteractionEnabled = NO;
    }
    return _scrollView;
}

- (NSMutableArray<YXStockPickerResultLabel *> *)labels {
    if (_labels == nil) {
        _labels = [[NSMutableArray alloc] init];

        [self.sortTypes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YXStockPickerResultLabel *label = [YXStockPickerResultLabel labelWithFilterType:[obj intValue]];
            [_labels addObject:label];
        }];
    }
    return _labels;
}

- (void)setSortTypes:(NSArray *)sortTypes {
    _sortTypes = sortTypes;

    [self.labels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _labels = nil;


    __block CGFloat width = 0;
    CGFloat fixWidth = 80;
    if ([YXUserManager isENMode]) {
        fixWidth = 100;
    }
    [self.labels enumerateObjectsUsingBlock:^(YXStockPickerResultLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(width, 0, fixWidth, self.height);

        if ([YXUserManager isENMode]) {
            width += (fixWidth + 20);
        } else {
            if (obj.filterType == YXStockFilterItemTypeRangeChng5Day || obj.filterType == YXStockFilterItemTypeRangeChng5Day || obj.filterType == YXStockFilterItemTypeRangeChng10Day || obj.filterType == YXStockFilterItemTypeRangeChng30Day || obj.filterType == YXStockFilterItemTypeRangeChng60Day || obj.filterType == YXStockFilterItemTypeRangeChng120Day || obj.filterType == YXStockFilterItemTypeRangeChng250Day || obj.filterType == YXStockFilterItemTypeRangeChngThisYear || obj.filterType == YXStockFilterItemTypeVolume ||
                obj.filterType == YXStockFilterItemTypeIndex ||
                obj.filterType == YXStockFilterItemTypeIndustry) {
                obj.frame = CGRectMake(width, 0, 100, self.height);
                width += (100 + 20);
            }  else {
                width += (fixWidth + 20);
            }
        }

        [self.scrollView addSubview:obj];
    }];

    self.scrollView.contentSize = CGSizeMake(width + 5, self.height);
}


@end
