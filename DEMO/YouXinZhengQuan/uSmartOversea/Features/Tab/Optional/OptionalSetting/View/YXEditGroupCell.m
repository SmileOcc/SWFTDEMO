//
//  YXManageGroupCell.m
//  uSmartOversea
//
//  Created by ellison on 2018/11/21.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXEditGroupCell.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@interface YXEditGroupCell ()

@property (nonatomic, strong) UIView *lineView;

@end

@implementation YXEditGroupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialUI];
    }
    return self;
}

- (void)initialUI {
    
    self.backgroundColor = QMUITheme.popupLayerColor;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.nameTextField];
    [self.contentView addSubview:self.deleteButton];
//    [self.contentView addSubview:self.editButton];
//    [self.contentView addSubview:self.lineView];
    
//    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(42);
//        make.centerY.equalTo(self);
//    }];
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(42);
        make.centerY.equalTo(self);
    }];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.centerY.equalTo(self);
    }];
    
//    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self).offset(-112);
//        make.centerY.height.equalTo(self);
//    }];
    
//    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.contentView);
//        make.left.equalTo(self).offset(8);
//        make.right.equalTo(self).offset(-8);
//        make.height.mas_equalTo(1);
//    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    
    for (UIControl *control in self.subviews) {
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]) {
            [control removeFromSuperview];
        }
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated: YES];
    
    if (editing) {
        for (UIView * view in self.subviews) {
            if ([NSStringFromClass([view class]) rangeOfString:@"Reorder"].location != NSNotFound) {
                for (UIView * subview in view.subviews) {
                    if ([subview isKindOfClass: [UIImageView class]]) {
                        ((UIImageView *)subview).image = [UIImage imageNamed: @"edit_rank"];
                        ((UIImageView *)subview).contentMode = UIViewContentModeCenter;
                    }
                }
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self).offset(-16);
                    make.centerY.equalTo(self);
                    make.top.height.equalTo(self);
                    make.width.mas_equalTo(40);
                }];
            }
        }
    }
}

- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [QMUITheme popSeparatorLineColor];
    }
    return _lineView;
}

- (void)deleteButtonAction {
    if (self.onClickDelete) {
        self.onClickDelete();
    }
}

- (void)editButtonAction {
    if (self.onClickEdit) {
        self.onClickEdit();
    }
}

#pragma mark - getter
- (UIButton *)deleteButton {
    if (_deleteButton == nil) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"edit_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UIButton *)editButton {
    if (_editButton == nil) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setImage:[UIImage imageNamed:@"edit_group"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

//- (UILabel *)nameLabel {
//    if (_nameLabel == nil) {
//        _nameLabel = [[UILabel alloc] init];
//        _nameLabel.textColor = [QMUITheme textColorLevel1];
//        _nameLabel.font = [UIFont systemFontOfSize:16];
//    }
//    return _nameLabel;
//}

- (YXSecuGroupNameTextField *)nameTextField {
    if (!_nameTextField) {
        _nameTextField = [[YXSecuGroupNameTextField alloc] init];
        _nameTextField.textColor = [QMUITheme textColorLevel1];
        _nameTextField.returnKeyType = UIReturnKeyDone;
        _nameTextField.font = [UIFont systemFontOfSize:16];
        _nameTextField.shouldReturn = YES;
    }
    return _nameTextField;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
