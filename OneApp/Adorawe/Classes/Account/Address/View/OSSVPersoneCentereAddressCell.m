//
//  PersonCenterAddressCellTableViewCell.m
// XStarlinkProject
//
//  Created by fan wang on 2021/7/31.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVPersoneCentereAddressCell.h"

@interface OSSVPersoneCentereAddressCell ()
@property (weak,nonatomic) UIButton *setDefaultButton;


@end

@implementation OSSVPersoneCentereAddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    [self.editButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(-5);
        make.trailing.equalTo(-5);
        make.width.height.equalTo(36);
    }];
    
    [self.deleteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.editButton.mas_leading).offset(-11);
        make.centerY.equalTo(self.editButton.mas_centerY);
        make.width.height.equalTo(36);
    }];
    
    UIView *line = [[UIView alloc] init];
    [self.addressBgView addSubview:line];
    line.backgroundColor = OSSVThemesColors.col_EEEEEE;
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(14);
        make.trailing.equalTo(-14);
        make.height.equalTo(0.5);
        make.bottom.equalTo(self.editButton.mas_top);
    }];
    
    [self.addressLabel mas_remakeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.phoneLabel.mas_bottom).offset(4);
        make.leading.equalTo(self.addressIconBgView.mas_leading);
        make.trailing.mas_equalTo(self.addressBgView.mas_trailing).offset(-14);
        make.bottom.mas_equalTo(line.mas_top).offset(-8);
    }];
    
    [self.editButton.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(18);
        make.centerY.equalTo(self.editButton.mas_centerY);
        make.centerX.equalTo(self.editButton.mas_centerX);
    }];
    
    
    [self.deleteButton.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(18);
        make.centerY.equalTo(self.deleteButton.mas_centerY);
        make.centerX.equalTo(self.deleteButton.mas_centerX);
    }];
    
    UIButton *setdefault = [[UIButton alloc] init];
    [setdefault setImage:[UIImage imageNamed:@"address_checkbox"] forState:UIControlStateNormal];
    [setdefault setImage:[UIImage imageNamed:@"address_check"] forState:UIControlStateSelected];
    [setdefault setTitle:STLLocalizedString_(@"Default_Address", nil) forState:UIControlStateNormal];
    [setdefault setTitleColor:OSSVThemesColors.col_6C6C6C forState:UIControlStateNormal];
    setdefault.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4);
    if (OSSVSystemsConfigsUtils.isRightToLeftShow) {
        setdefault.titleEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 4);
    }
    setdefault.titleLabel.font = [UIFont systemFontOfSize:12];
    [setdefault addTarget:self action:@selector(defaultAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.addressBgView addSubview:setdefault];
    self.setDefaultButton = setdefault;
    
    [setdefault mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.addressIconBgView.mas_leading);
        make.centerY.equalTo(self.editButton.mas_centerY);
    }];
    
    
    return self;
}

-(void)setAddressBookModel:(OSSVAddresseBookeModel *)addresseBookeModel{
    [super setAddressBookModel:addresseBookeModel];
    
    self.isDefaultLbl.hidden = true;
    self.setDefaultButton.selected =addresseBookeModel.isDefault;
}


@end
