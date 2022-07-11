//
//  OSSVCheckOutBottomView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCheckOutBottomView.h"
#import "OSSVPriceView.h"

@interface OSSVCheckOutBottomView ()
@property (nonatomic, strong) OSSVPriceView     *totalPriceView;
@property (nonatomic, strong) UIButton        *purchaseButton;
@property (nonatomic, strong) UILabel         *totalPayable; //总支付label
@property (nonatomic, strong) UILabel         *taxLabel;     //含税label
@property (nonatomic, assign, readwrite) AddressViewAnimateStatus stauts;
@end

@implementation OSSVCheckOutBottomView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.stauts = AddressViewAnimateStatusHidden;
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = NO;
        [self addSubview:self.totalPriceView];
        [self addSubview:self.purchaseButton];
        [self addSubview:self.taxLabel];
        [self addSubview:self.totalPayable];
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(SCREEN_WIDTH);
            if (kIS_IPHONEX) {
                make.height.mas_offset(88 + STL_TABBAR_IPHONEX_H + 8);
            } else {
                make.height.mas_offset(88 + 8);
            }
        }];
        
        
        [self.purchaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            if (kIS_IPHONEX) {
                make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-STL_TABBAR_IPHONEX_H - 8);
            } else {
                make.bottom.mas_equalTo(self.mas_bottom).mas_offset( - 8);
            }
            make.height.mas_offset(44);
        }];
        
        [self.totalPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.purchaseButton.mas_trailing);
            make.height.mas_offset(18);
            make.top.mas_equalTo(self.mas_top).offset(13);
        }];
        
        [self.totalPayable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.centerY.mas_equalTo(self.totalPriceView.mas_centerY);
        }];

        [self.taxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.totalPayable.mas_trailing).offset(1);
            make.centerY.mas_equalTo(self.totalPayable.mas_centerY);
        }];
       
        
        UIView *line = [UIView new];
        line.backgroundColor = OSSVThemesColors.col_CCCCCC;
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_offset(.5);
        }];
    }
    return self;
}


#pragma mark - target

-(void)purchaseButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_CheckOutBottomDidClickBuy:)]) {
        [self.delegate STL_CheckOutBottomDidClickBuy:self.dataSourceModel];
    }
}

#pragma mark - setter and getter

-(void)setDataSourceModel:(OSSVCartOrderInfoViewModel *)dataSourceModel {
    _dataSourceModel = dataSourceModel;
    
    ///总金额要粗体

//    NSString *totalTips = [NSString stringWithFormat:@"%@:", STLLocalizedString_(@"totalPayable", nil)];
//    NSString *totalValue = [NSString stringWithFormat:@"%@%.2f", dataSourceModel.checkOutModel.currencyInfo.symbol, dataSourceModel.totalPrice];
    NSString *totalValue = STLToString(self.dataSourceModel.checkOutModel.fee_data.total_converted);


    NSString *taxStr = STLUserDefaultsGet(@"tax");
    NSLog(@"获取到的含税信息：%@", taxStr);
    if (taxStr.length) {
        self.taxLabel.text = [NSString stringWithFormat:@"(%@)", taxStr];
    }

    [self.totalPriceView updateFirstDesc:@"" secondPrice:totalValue];
    
    OSSVAddresseBookeModel *addressModel = dataSourceModel.addressModel;
    
    NSArray *addressList = @[addressModel.streetMore,addressModel.street,addressModel.city,addressModel.state,addressModel.country];
    NSMutableString *addressMut = [[NSMutableString alloc] init];
    for (int i = 0; i < [addressList count]; i++){
        NSString *address = addressList[i];
        if (address.length) {
            [addressMut appendFormat:@"%@", address];
            if (i < [addressList count] - 1){
                [addressMut appendString:@","];
            }
        }
    }
    
    
    
    if ([dataSourceModel.checkOutModel.paymentList count] == 0) {
        //置灰按钮
        self.purchaseButton.enabled = NO;
        self.purchaseButton.backgroundColor = OSSVThemesColors.col_999999;
        [self.purchaseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        self.purchaseButton.enabled = YES;
        self.purchaseButton.backgroundColor = [OSSVThemesColors col_262626];
        [self.purchaseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }

    
}

#pragma mark -----懒加载View

- (UILabel *)totalPayable {
    if (!_totalPayable) {
        _totalPayable = [UILabel new];
        _totalPayable.textColor = OSSVThemesColors.col_0D0D0D;
        _totalPayable.font = [UIFont systemFontOfSize:13];
        _totalPayable.text = [NSString stringWithFormat:@"%@:", STLLocalizedString_(@"totalPayable", nil)];
    }
    return _totalPayable;
}

- (UILabel *)taxLabel {
    if (!_taxLabel) {
        _taxLabel = [UILabel new];
        _taxLabel.textColor = OSSVThemesColors.col_999999;
        _taxLabel.font = [UIFont systemFontOfSize:10];
    }
    return _taxLabel;
}

- (OSSVPriceView *)totalPriceView {
    if (!_totalPriceView) {
        _totalPriceView = [[OSSVPriceView alloc] initWithFrame:CGRectZero font:[UIFont systemFontOfSize:16] textColor:[UIColor blackColor]];
        _totalPriceView.priceLabel.font = [UIFont boldSystemFontOfSize:16];
//        _totalPriceView.descLabel.text = [NSString stringWithFormat:@"%@:", STLLocalizedString_(@"totalPayable", nil)];
    }
    return _totalPriceView;
}

-(UIButton *)purchaseButton
{
    if (!_purchaseButton) {
        _purchaseButton = ({
            UIButton *button = [[UIButton alloc] init];
            if (APP_TYPE == 3) {
                [button setTitle:STLLocalizedString_(@"placeOrder", nil) forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont vivaiaSemiBoldFont:18];

            } else {
                [button setTitle:STLLocalizedString_(@"placeOrder", nil).uppercaseString forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont stl_buttonFont:14];
            }
            
            [button setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = OSSVThemesColors.col_0D0D0D;
            button.layer.cornerRadius = 0;
            button.layer.masksToBounds = YES;
            [button addTarget:self action:@selector(purchaseButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _purchaseButton;
}

@end
