//
//  OSSVProductListHeaderView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVProductListHeaderView.h"

@interface OSSVProductListHeaderView ()

@property (nonatomic, strong) UILabel *titleHeaderLabel;
@property (nonatomic, strong) UILabel *allCountLabel;
@property (nonatomic, strong) UILabel *noShippedLabel;
@property (nonatomic, strong) UILabel *titleCenterLabel;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation OSSVProductListHeaderView

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.titleHeaderLabel];
        [self addSubview:self.allCountLabel];
        [self addSubview:self.noShippedLabel];
        [self addSubview:self.titleCenterLabel];
        [self addSubview:self.bottomLine];
        
        [self.titleHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
        }];
        
        [self.allCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
        }];
        
        [self.noShippedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
        }];
        
        [self.titleCenterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_offset(0.5);
        }];
    }
    return self;
}

#pragma mark - setter and getter

-(void)setWareHouseModel:(OSSVCartWareHouseModel *)wareHouseModel
{
    _wareHouseModel = wareHouseModel;
    
    if ([wareHouseModel.goodsList count]) {
        
        __block NSInteger noShippCount = 0;
        [wareHouseModel.goodsList enumerateObjectsUsingBlock:^(OSSVCartGoodsModel  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.shield_status integerValue] == 1) {
                noShippCount ++;
            }
        }];
        OSSVCartGoodsModel *goodsModel = wareHouseModel.goodsList[0];
        self.titleHeaderLabel.text = goodsModel.warehouseName;
        
        NSString *itemsString =  @"";
        NSString *noShipItemsString =  @"";

        __block NSInteger noShipCount = 0;
        __block NSInteger hadShipCount = 0;
        [wareHouseModel.goodsList enumerateObjectsUsingBlock:^(OSSVCartGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.shield_status integerValue] == 1) {
                noShipCount += obj.goodsNumber;
            } else {
                hadShipCount += obj.goodsNumber;
            }
        }];
        
        if (hadShipCount > 1) {
            itemsString = [NSString stringWithFormat:@"%ld %@", (long)hadShipCount, STLLocalizedString_(@"checkOutItems", nil)];
        } else {
            itemsString = [NSString stringWithFormat:@"%ld %@", (long)hadShipCount, STLLocalizedString_(@"checkOutItem", nil)];
        }
        
        noShipItemsString = [NSString stringWithFormat:STLLocalizedString_(@"XXX_items_no_shipped", nil),[NSString stringWithFormat:@"%ld",(long)noShipCount]];
        self.allCountLabel.attributedText = [[NSAttributedString alloc] initWithString:itemsString attributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_666666}];
        self.titleCenterLabel.attributedText = [[NSAttributedString alloc] initWithString:itemsString attributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_666666}];
        
        if (noShipCount > 0) {
            self.noShippedLabel.attributedText = [[NSAttributedString alloc] initWithString:noShipItemsString attributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_B62B21}];
            self.titleCenterLabel.hidden = YES;
            self.noShippedLabel.hidden = NO;
            self.allCountLabel.hidden = NO;
        } else {
            self.noShippedLabel.attributedText = nil;
            self.titleCenterLabel.hidden = NO;
            self.allCountLabel.hidden = YES;
            self.noShippedLabel.hidden = YES;

        }
    }
}

-(UILabel *)titleHeaderLabel
{
    if (!_titleHeaderLabel) {
        _titleHeaderLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:15];
            label;
        });
    }
    return _titleHeaderLabel;
}

-(UILabel *)allCountLabel
{
    if (!_allCountLabel) {
        _allCountLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [OSSVThemesColors col_666666];
            label.font = [UIFont systemFontOfSize:13];
            label.hidden = YES;
            label;
        });
    }
    return _allCountLabel;
}

-(UILabel *)noShippedLabel
{
    if (!_noShippedLabel) {
        _noShippedLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = OSSVThemesColors.col_B62B21;
            label.font = [UIFont systemFontOfSize:11];
            label.hidden = YES;
            label.textAlignment = NSTextAlignmentRight;
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                label.textAlignment = NSTextAlignmentLeft;
            }
            label;
        });
    }
    return _noShippedLabel;
}


-(UILabel *)titleCenterLabel
{
    if (!_titleCenterLabel) {
        _titleCenterLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [OSSVThemesColors col_0D0D0D];
            label.font = [UIFont systemFontOfSize:13];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label;
        });
    }
    return _titleCenterLabel;
}


-(UIView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = OSSVThemesColors.col_EEEEEE;
            view;
        });
    }
    return _bottomLine;
}

@end
