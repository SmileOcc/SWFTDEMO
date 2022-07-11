//
//  STLBindCountryCell.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLBindCountryCell.h"

@interface STLBindCountryCell()
@property (weak,nonatomic) YYAnimatedImageView *flagImg;
@property (weak,nonatomic) UILabel *countryName;
@property (weak,nonatomic) UILabel *countryCode;
@end

@implementation STLBindCountryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupViews];
        self.separatorInset = UIEdgeInsetsMake(0, 42, 0, 10);
    }
    return self;
}



-(void)setupViews{
    YYAnimatedImageView *img = [[YYAnimatedImageView alloc] init];
    [self.contentView addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(16);
        make.leading.mas_equalTo(self.contentView).offset(12);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    _flagImg = img;
    
    UILabel *countryName = [UILabel new];
    [self.contentView addSubview:countryName];
    [countryName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(img.mas_trailing).offset(6);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    countryName.font = [UIFont systemFontOfSize:13];
    countryName.textColor = OSSVThemesColors.col_0D0D0D;
    _countryName = countryName;
    
    UILabel *countryCode = [UILabel new];
    [self.contentView addSubview:countryCode];
    [countryCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView).offset(-36);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    countryCode.font = [UIFont systemFontOfSize:13];
    countryCode.textColor = OSSVThemesColors.col_999999;
    _countryCode = countryCode;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(STLBindCountryModel *)model{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.countryName.text = model.country_name;
    self.countryCode.text = model.code;
    [self.flagImg yy_setImageWithURL:[NSURL URLWithString:model.picture] placeholder:[UIImage imageNamed:@"region_place_polder"]];
}

@end
