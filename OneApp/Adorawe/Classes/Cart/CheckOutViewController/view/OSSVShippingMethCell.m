//
//  OSSVShippingMethCell.m
// XStarlinkProject
//
//  Created by fan wang on 2021/8/4.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVShippingMethCell.h"
#import "OSSVShippingCellModel.h"

@interface OSSVShippingMethCell()
@property (nonatomic, strong) UILabel *shippingMethod;
@property (nonatomic, strong) UILabel *descripLbl;
@property (nonatomic, strong) UIView  *cellBgView; //新增背景边框
@end

@implementation OSSVShippingMethCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.contentView addSubview:self.cellBgView];
        [self.cellBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(14);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-14);
            make.top.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-6);
        }];
        
        UILabel *shippingMethod = [[UILabel alloc] init];
        shippingMethod.font = [UIFont systemFontOfSize:14];
        shippingMethod.textColor = OSSVThemesColors.col_0D0D0D;
        self.shippingMethod = shippingMethod;
        [self.cellBgView addSubview:shippingMethod];
        [shippingMethod mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.leading.equalTo(12);
                make.top.equalTo(7.5);
            } else {
                make.leading.equalTo(0);
                make.top.equalTo(0);

            }
        }];
        
        UILabel *price = [[UILabel alloc] init];
        [self.contentView addSubview:price];
        self.priceLbl = price;
        [self.contentView addSubview:price];
        price.font = [UIFont systemFontOfSize:14];
        price.textColor = APP_TYPE == 3 ? OSSVThemesColors.col_9F5123 : OSSVThemesColors.col_0D0D0D;
        [self.cellBgView addSubview:price];
        [price mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.trailing.equalTo(-12);
                make.centerY.mas_equalTo(self.cellBgView.mas_centerY);

            } else {
                make.trailing.equalTo(0);
                make.centerY.mas_equalTo(self.cellBgView.mas_centerY);
            }
        }];
        
        UILabel *describeModel = [[UILabel alloc] init];
        describeModel.font = [UIFont systemFontOfSize:12];
        describeModel.textColor = OSSVThemesColors.col_B2B2B2;
        describeModel.numberOfLines = 0;
        self.descripLbl = describeModel;
        [self.cellBgView addSubview:describeModel];
        [describeModel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(shippingMethod.mas_leading);
            make.top.equalTo(shippingMethod.mas_bottom).offset(2);
            make.bottom.equalTo(self.cellBgView.mas_bottom).offset(-13.5);
            make.trailing.mas_lessThanOrEqualTo(price.mas_leading);
        }];
        
        UILabel *centerLineLbl = [[UILabel alloc] init];
        [self.cellBgView addSubview:centerLineLbl];
        self.centerLinelbl = centerLineLbl;
        
        [centerLineLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(price.mas_leading).offset(-2);
            make.centerY.mas_equalTo(self.cellBgView.mas_centerY);
        }];
        
    }
    return self;
}

- (UIView *)cellBgView {
    if (!_cellBgView) {
        _cellBgView = [UIView new];
        _cellBgView.backgroundColor = self.backgroundColor;
        if (APP_TYPE == 3) {
            _cellBgView.layer.borderColor = OSSVThemesColors.stlBlackColor.CGColor;
            _cellBgView.layer.borderWidth = 1.f;
            _cellBgView.layer.masksToBounds = YES;
        }
    }
    return _cellBgView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@synthesize delegate = _delegate;
@synthesize model = _model;

-(void)setModel:(id<OSSVBaseCellModelProtocol>)model{
    if ([model isKindOfClass:OSSVShippingCellModel.class]) {
        OSSVShippingCellModel *shippingModel = model;
        self.shippingMethod.text = STLToString(shippingModel.dataSourceModel.shipName);
        self.descripLbl.text = STLToString(shippingModel.dataSourceModel.shipDesc);

//        self.priceLbl.text = STLToString(shippingModel.dataSourceModel.shipping_fee_converted);
    }
}

- (void)prepareForReuse{
    [super prepareForReuse];
    _descripLbl.text = @"";
    _shippingMethod.text = @"";
}

@end
