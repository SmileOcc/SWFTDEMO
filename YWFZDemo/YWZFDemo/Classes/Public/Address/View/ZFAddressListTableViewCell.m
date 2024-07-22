
//
//  ZFAddressListTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressListTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFAddressInfoModel.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIImage+ZFExtended.h"
#import "UIView+ZFViewCategorySet.h"
#import "SystemConfigUtils.h"

@interface ZFAddressListTableViewCell () <ZFInitViewProtocol>

@property (nonatomic, strong) UIView                 *bgView;
@property (nonatomic, strong) UIView                 *informView;
@property (nonatomic, strong) UIView                 *eventView;

@property (nonatomic, strong) UILabel                *nameLabel;
@property (nonatomic, strong) UILabel                *telphoneLabel;
@property (nonatomic, strong) UILabel                *addressInfoLabel;

@property (nonatomic, strong) UIImageView            *selectImgView;
@property (nonatomic, strong) UIButton               *defaultButton;

@property (nonatomic, strong) UIButton               *deleteButton;
@property (nonatomic, strong) UIImageView            *deleteImgView;
@property (nonatomic, strong) UILabel                *deleteLabel;

@property (nonatomic, strong) UIImageView            *arrowImageView;

@end

@implementation ZFAddressListTableViewCell

#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isEdit = YES;
        
        [self zfInitView];
        [self zfAutoLayoutView];
        @weakify(self);
        [self.informView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            [self addressSelect];
        }];
    }
    return self;
}

- (void)updateInfoModel:(ZFAddressInfoModel *)model edit:(BOOL)isEdit isOrder:(BOOL)isOrder{
    self.isOrder = isOrder;
    self.isEdit = isEdit;
    self.model = model;
    
    if (self.model.is_default && !self.isOrder) {
        [self.telphoneLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
            make.leading.mas_equalTo(self.nameLabel.mas_trailing).offset(4);
            make.trailing.mas_equalTo(self.defaultButton.mas_leading).offset(-4);
        }];
    } else {
        [self.telphoneLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
            make.leading.mas_equalTo(self.nameLabel.mas_trailing).offset(4);
            make.trailing.mas_equalTo(self.informView.mas_trailing).offset(-12);
        }];
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
        
    self.backgroundColor = ZFCClearColor();

    [self.contentView addSubview:self.bgView];
    [self.contentView addSubview:self.informView];
    [self.contentView addSubview:self.eventView];
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.telphoneLabel];
    [self.contentView addSubview:self.addressInfoLabel];
    
    [self.contentView addSubview:self.defaultButton];
    [self.contentView addSubview:self.selectImgView];
    
    [self.contentView addSubview:self.deleteImgView];
    [self.contentView addSubview:self.deleteLabel];
    [self.contentView addSubview:self.deleteButton];
    [self.contentView addSubview:self.arrowImageView];
}

- (void)zfAutoLayoutView {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.informView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.bgView.mas_top).mas_offset(0);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.informView.mas_leading).offset(12);
        make.top.mas_equalTo(self.informView.mas_top).offset(12);
    }];
    
    [self.telphoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
        make.leading.mas_equalTo(self.nameLabel.mas_trailing).offset(4);
        make.trailing.mas_equalTo(self.defaultButton.mas_leading).offset(-4);
    }];
    
    [self.defaultButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
    }];
    
    [self.addressInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.nameLabel.mas_leading);
        make.trailing.mas_equalTo(self.informView.mas_trailing).offset(-50);
        make.top.mas_equalTo(self.telphoneLabel.mas_bottom).offset(8);
        make.bottom.mas_equalTo(self.informView.mas_bottom);
    }];
    
    [self.selectImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.informView.mas_trailing).mas_offset(-12);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    
    [self.eventView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.informView.mas_bottom);
        make.bottom.mas_equalTo(self.bgView.mas_bottom);
        make.height.mas_equalTo(44);
    }];

    
    [self.deleteImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.eventView.mas_leading).mas_offset(12);
        make.centerY.mas_equalTo(self.eventView.mas_centerY);
    }];
    
    [self.deleteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.deleteImgView.mas_trailing).mas_offset(4);
        make.centerY.mas_equalTo(self.deleteImgView.mas_centerY);
    }];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.deleteImgView.mas_leading);
        make.trailing.mas_equalTo(self.deleteLabel.mas_trailing);
        make.top.bottom.mas_equalTo(self.eventView);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.informView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
    
    [self.nameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.nameLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];

    [self.telphoneLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.telphoneLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.defaultButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.defaultButton setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self.bgView zfAddCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)];
}

#pragma mark - 响应方法

- (void)addressSelect {

    if (self.addressEditSelectCompletionHandler) {
        self.addressEditSelectCompletionHandler(self.model, ZFAddressListCellEventSelect);
    }
}
- (void)defaultAction:(UIButton *)sender {
    if (self.addressEditSelectCompletionHandler) {
        self.addressEditSelectCompletionHandler(self.model, ZFAddressListCellEventDefault);
    }
}

- (void)editAction:(UIButton *)sender {
    if (self.addressEditSelectCompletionHandler) {
        self.addressEditSelectCompletionHandler(self.model, ZFAddressListCellEventEdit);
    }
}

- (void)deleteAction:(UIButton *)sender {
    if (self.addressEditSelectCompletionHandler) {
        if (self.isOrder) {
            self.addressEditSelectCompletionHandler(self.model, ZFAddressListCellEventEdit);
        } else {
            self.addressEditSelectCompletionHandler(self.model, ZFAddressListCellEventDelete);
        }
    }
}

#pragma mark - setter
- (void)setModel:(ZFAddressInfoModel *)model {
    _model = model;
    
    // 如果改过一次，会复用，需要每次重置
    [self.defaultButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
    }];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",model.firstname,model.lastname];
    
    if([NSStringUtils isEmptyString:model.code] && [NSStringUtils isEmptyString:model.supplier_number]) {
        self.telphoneLabel.text = [NSString stringWithFormat:@"%@",model.tel];
    } else {
        self.telphoneLabel.text = [NSString stringWithFormat:@"+%@ %@%@",[NSStringUtils isEmptyString:model.code withReplaceString:@""],[NSStringUtils isEmptyString:model.supplier_number withReplaceString:@""],model.tel];
    }
    self.addressInfoLabel.text = [NSString stringWithFormat:@"%@ %@,\n%@ %@/%@ %@",model.addressline1,model.addressline2,model.province,model.country_str,model.city,model.zipcode];
    
    if (model.is_default) {
        self.defaultButton.hidden = self.isOrder ? YES : NO;
        self.selectImgView.image = [[UIImage imageNamed:@"address_choose"] imageWithColor:ZFC0xFE5269()];

    } else {
        self.defaultButton.hidden = YES;
        self.selectImgView.image = [UIImage imageNamed:@"address_unchoose"];
    }
    
    if (self.defaultButton.isHidden) {
        [_defaultButton setTitle:@"" forState:UIControlStateNormal];
    } else {
        [_defaultButton setTitle:ZFLocalizedString(@"Address_List_Cell_Default", nil) forState:UIControlStateNormal];
    }
    
    if (self.isOrder) {
        self.deleteLabel.text = ZFLocalizedString(@"Address_List_Cell_Edit", nil);
        self.deleteImgView.image = [UIImage imageNamed:@"address_edit"];
    } else {
        self.deleteLabel.text = ZFLocalizedString(@"Address_List_Cell_Delete", nil);
        self.deleteImgView.image = [UIImage imageNamed:@"address_delete"];
    }

    self.nameLabel.textColor = ZFC0x2D2D2D();
    self.telphoneLabel.textColor = ZFC0x999999();
    self.addressInfoLabel.textColor = ZFC0x999999();
   
    self.selectImgView.hidden = !self.isOrder;
    self.arrowImageView.hidden = self.isOrder;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat maxX = CGRectGetMaxX(self.defaultButton.frame);
        if (maxX > KScreenWidth - 48) {
            [self.defaultButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.telphoneLabel.mas_trailing).offset(8);
                make.trailing.mas_equalTo(self.informView.mas_trailing).offset(-12);
                make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
            }];
        } else {
            [self.defaultButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.telphoneLabel.mas_trailing).offset(8);
                make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
            }];
        }
        [self layoutIfNeeded];
    });
}

#pragma mark - getter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = ZFC0xFFFFFF();
    }
    return _bgView;
}
- (UIView *)informView {
    if (!_informView) {
        _informView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _informView;
}

- (UIView *)eventView {
    if (!_eventView) {
        _eventView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _eventView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _nameLabel.textColor = ZFC0x2D2D2D();
    }
    return _nameLabel;
}

- (UILabel *)telphoneLabel {
    if (!_telphoneLabel) {
        _telphoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _telphoneLabel.textColor = ZFC0x999999();
        _telphoneLabel.font = [UIFont systemFontOfSize:14.0];
        if ([SystemConfigUtils isRightToLeftShow]) {
            _telphoneLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _telphoneLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _telphoneLabel;
}

- (UILabel *)addressInfoLabel {
    if (!_addressInfoLabel) {
        _addressInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addressInfoLabel.numberOfLines = 0;
        _addressInfoLabel.textColor = ZFC0x999999();
        _addressInfoLabel.font =  [UIFont systemFontOfSize:14.0];
    }
    return _addressInfoLabel;
}

- (UIImageView *)selectImgView {
    if (!_selectImgView) {
        _selectImgView = [[UIImageView alloc] init];
        _selectImgView.image = [UIImage imageNamed:@"address_unchoose"];
        _selectImgView.hidden = YES;
    }
    return _selectImgView;
}


- (UIButton *)defaultButton {
    if (!_defaultButton) {
        _defaultButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_defaultButton setTitleColor:ZFC0xFE5269() forState:UIControlStateNormal];
        _defaultButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _defaultButton.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
        [_defaultButton setTitle:ZFLocalizedString(@"Address_List_Cell_Default", nil) forState:UIControlStateNormal];
        _defaultButton.layer.cornerRadius = 1.0;
        _defaultButton.layer.borderColor = ZFC0xFE5269().CGColor;
        _defaultButton.layer.borderWidth = 1.0;
        _defaultButton.userInteractionEnabled = NO;
        _defaultButton.hidden = YES;
    }
    return _defaultButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.contentEdgeInsets = UIEdgeInsetsMake(10, 12, 10, 12);
        [_deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UIImageView *)deleteImgView {
    if (!_deleteImgView) {
        _deleteImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"address_delete"]];
    }
    return _deleteImgView;
}

- (UILabel *)deleteLabel {
    if (!_deleteLabel) {
        _deleteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _deleteLabel.textColor = ZFC0x999999();
        _deleteLabel.font = [UIFont systemFontOfSize:14.0];
        _deleteLabel.text = ZFLocalizedString(@"Address_List_Cell_Delete", nil);
    }
    return _deleteLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account_arrow_right"]];
    }
    return _arrowImageView;
}

@end
