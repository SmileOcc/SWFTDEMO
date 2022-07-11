//
//  GoodsDetailHeaderGoodsServiceView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  商品服务信息以及运输时长的视图

#import "OSSVDetailsHeaderServiceView.h"
#import "Adorawe-Swift.h"

@interface OSSVDetailsHeaderServiceView ()
@property (nonatomic, weak) OSSVDetailsBaseInfoModel                  *baseInfoModel;
@property (nonatomic, strong) UIView *lineView; //底部的线条--- V站使用
@end

@implementation OSSVDetailsHeaderServiceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.separateLineView];
        [self addSubview:self.transportView];
        [self addSubview:self.arrowImgeView];
        [self addSubview:self.firstLeftItem];
        [self addSubview:self.secondRightItem];
        [self addSubview:self.thirdLeftItem];
        [self addSubview:self.fourRightItem];
        
        [self addSubview:self.serviceBgControl];
        
        if (APP_TYPE == 3) {
            UIView *topBorder = [UIView new];
            [self addSubview:topBorder];
            topBorder.backgroundColor = OSSVThemesColors.col_F5F5F5;
            [topBorder mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(12);
                make.top.equalTo(0);
                make.leading.equalTo(0);
                make.trailing.equalTo(0);
                make.height.equalTo(8);
            }];
            self.transportView.hidden = true;
            [self.transportView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.mas_equalTo(self);
//                make.top.mas_equalTo(topBorder).offset(18);
//                make.height.mas_equalTo(67);
                make.top.mas_equalTo(topBorder).offset(6);
                make.height.mas_equalTo(0);
            }];

        }else{
            [self.transportView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.mas_equalTo(self);
                make.top.mas_equalTo(self.mas_top);
                make.height.mas_equalTo(67);
            }];
        }
        
        
        
        [self.serviceBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self.transportView.mas_bottom);
            make.height.mas_equalTo(64);
        }];
        
        [self.separateLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(14);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
            make.top.mas_equalTo(self.transportView.mas_bottom);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.arrowImgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.serviceBgControl.mas_centerY);
            make.trailing.mas_equalTo(self.serviceBgControl.mas_trailing).mas_offset(-14);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];

        CGFloat item_w = (SCREEN_WIDTH - 24 -28 - 8) / 2.0;
        [self.firstLeftItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.serviceBgControl.mas_leading).mas_offset(14);
            make.bottom.mas_equalTo(self.serviceBgControl.mas_centerY).mas_offset(-4.5);
            make.size.mas_equalTo(CGSizeMake(item_w, 12));
        }];

        [self.secondRightItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.arrowImgeView.mas_leading);
            make.bottom.mas_equalTo(self.serviceBgControl.mas_centerY).mas_offset(-4.5);
            make.size.mas_equalTo(CGSizeMake(item_w, 12));
        }];

        [self.thirdLeftItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.serviceBgControl.mas_leading).mas_offset(14);
            make.top.mas_equalTo(self.serviceBgControl.mas_centerY).mas_offset(4.5);
            make.size.mas_equalTo(CGSizeMake(item_w, 12));
        }];

        [self.fourRightItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.arrowImgeView.mas_leading);
            make.top.mas_equalTo(self.serviceBgControl.mas_centerY).mas_offset(4.5);
            make.size.mas_equalTo(CGSizeMake(item_w, 12));
        }];
        
        if (APP_TYPE == 3) {
            [self addSubview:self.lineView];
            [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).offset(14);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
                make.height.equalTo(0.6);
                make.bottom.mas_equalTo(self.mas_bottom).offset(0);
            }];
        }
    }
    return self;
}

#pragma mark -

- (void)updateHeaderGoodsService:(OSSVDetailsBaseInfoModel *)goodsInforModel {
    
    //赋值
    self.transportView.shipGlobal.text = STLToString(goodsInforModel.transportTimeModel.titleSting);
    self.transportView.shipTimeLabel.text = STLToString(goodsInforModel.transportTimeModel.contentSting);
    if (goodsInforModel.serviceTipModel.count == 4) {
        self.firstLeftItem.descLabel.text = [NSString stringWithFormat:@"%@%@",STLToString(goodsInforModel.serviceTipModel[0].titleString), STLToString(goodsInforModel.serviceTipModel[0].titleExt)];
        
        self.secondRightItem.descLabel.text = [NSString stringWithFormat:@"%@%@",STLToString(goodsInforModel.serviceTipModel[1].titleString), STLToString(goodsInforModel.serviceTipModel[1].titleExt)];
        self.thirdLeftItem.descLabel.text = [NSString stringWithFormat:@"%@%@",STLToString(goodsInforModel.serviceTipModel[2].titleString), STLToString(goodsInforModel.serviceTipModel[2].titleExt)];
        self.fourRightItem.descLabel.text = [NSString stringWithFormat:@"%@%@",STLToString(goodsInforModel.serviceTipModel[3].titleString), STLToString(goodsInforModel.serviceTipModel[3].titleExt)];

        self.arrowImgeView.image = [UIImage imageNamed:@"goods_more"];
        self.firstLeftItem.iconImageView.image = [UIImage imageNamed:@"goods_tick"];
        self.secondRightItem.iconImageView.image = [UIImage imageNamed:@"goods_tick"];
        self.thirdLeftItem.iconImageView.image = [UIImage imageNamed:@"goods_tick"];
        self.fourRightItem.iconImageView.image = [UIImage imageNamed:@"goods_tick"];

    }
 
}

+ (CGFloat)heightGoodsServiceView:(OSSVDetailsBaseInfoModel *)goodsInforModel {

    if (goodsInforModel.transportTimeModel && goodsInforModel.serviceTipModel.count) {
        return  8 + 64 + 60;
    } else if (goodsInforModel.transportTimeModel && !goodsInforModel.serviceTipModel.count) {
        return 8 + 64;
    } else if (!goodsInforModel.transportTimeModel && goodsInforModel.serviceTipModel.count) {
        return  8 + 60;
    }
    return 0;
}

#pragma mark - Action

- (void)actionService:(UIControl *)control {
    [GATools logGoodsDetailSimpleEventWithEventName:@"product_description"
                                            screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.baseInfoModel.goodsTitle)]
                                             buttonName:@"Return Info"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(goodsDetailsHeaderGoodsServiceView:serviceDesc:)]) {
        [self.delegate goodsDetailsHeaderGoodsServiceView:self serviceDesc:YES];
    }
}


- (void)lookUpTransportTime:(UIControl *)control {
    [GATools logGoodsDetailSimpleEventWithEventName:@"product_description"
                                            screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.baseInfoModel.goodsTitle)]
                                             buttonName:@"Shipping Info"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(goodsDetailsHeaderGoodsTransportTime:serviceDesc:)]) {
        [self.delegate goodsDetailsHeaderGoodsTransportTime:self serviceDesc:YES];
    }
}

#pragma mark - LazyLoad
//运输时间View
- (TransportTimeView *)transportView {
    if (!_transportView) {
        _transportView = [[TransportTimeView alloc] initWithFrame:CGRectZero];
        _transportView.backgroundColor = [UIColor whiteColor];
        _transportView.userInteractionEnabled = YES;
        [_transportView addTarget:self action:@selector(lookUpTransportTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _transportView;
}
- (UIControl *)serviceBgControl {
    if (!_serviceBgControl) {
        _serviceBgControl = [[UIControl alloc] init];
        [_serviceBgControl addTarget:self action:@selector(actionService:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _serviceBgControl;
}

- (UIImageView *)arrowImgeView {
    if (!_arrowImgeView) {
        _arrowImgeView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        _arrowImgeView.image = [UIImage imageNamed:@"detail_right_arrow"];
        [_arrowImgeView convertUIWithARLanguage];
    }
    return _arrowImgeView;
}

- (UIView *)separateLineView {
    if (!_separateLineView) {
        _separateLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _separateLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _separateLineView;
}

- (ServiceItemView *)firstLeftItem {
    if (!_firstLeftItem) {
        _firstLeftItem = [[ServiceItemView alloc] initWithFrame:CGRectZero];
//        _firstLeftItem.iconImageView.image = [UIImage imageNamed:@"detail_service_mark"];
    }
    return _firstLeftItem;
}

- (ServiceItemView *)secondRightItem {
    if (!_secondRightItem) {
        _secondRightItem = [[ServiceItemView alloc] initWithFrame:CGRectZero];
//        _secondRightItem.iconImageView.image = [UIImage imageNamed:@"detail_service_mark"];
    }
    return _secondRightItem;
}

- (ServiceItemView *)thirdLeftItem {
    if (!_thirdLeftItem) {
        _thirdLeftItem = [[ServiceItemView alloc] initWithFrame:CGRectZero];
//        _thirdLeftItem.iconImageView.image = [UIImage imageNamed:@"detail_service_mark"];
    }
    return _thirdLeftItem;
}

- (ServiceItemView *)fourRightItem {
    if (!_fourRightItem) {
        _fourRightItem = [[ServiceItemView alloc] initWithFrame:CGRectZero];
//        _fourRightItem.iconImageView.image = [UIImage imageNamed:@"detail_service_mark"];
    }
    return _fourRightItem;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = OSSVThemesColors.col_E1E1E1;
    }
    return _lineView;
}
@end







#pragma mark -
#pragma mark
//***************************************服务信息*****************************************//

@implementation ServiceItemView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.iconImageView];
        [self addSubview:self.descLabel];
        
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.centerY.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.iconImageView.mas_trailing).mas_offset(3);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.centerY.mas_equalTo(self.iconImageView.mas_centerY);
        }];
    }
    return self;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _iconImageView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _descLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _descLabel;
}
@end

//***************************************运输时间******************************************//
@implementation TransportTimeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.shipGlobal];
        [self addSubview:self.shipTimeLabel];
        [self addSubview:self.arrowImageView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.shipGlobal mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(14);
        if (APP_TYPE == 3) {
            make.top.mas_equalTo(self.mas_top).offset(5);
            make.height.equalTo(23);
        } else {
            make.top.mas_equalTo(self.mas_top).offset(12);
            make.height.equalTo(16);
        }
    }];
    
    [self.shipTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.shipGlobal.mas_leading);
        make.top.mas_equalTo(self.shipGlobal.mas_bottom).offset(8);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-38);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-14);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    
}

- (UILabel *)shipGlobal {
    if (!_shipGlobal) {
        _shipGlobal = [UILabel new];
        _shipGlobal.textColor = [OSSVThemesColors col_0D0D0D];
        if (APP_TYPE == 3) {
            _shipGlobal.font = [UIFont vivaiaRegularFont:18];
        } else {
            _shipGlobal.font = [UIFont boldSystemFontOfSize:14];
        }
        _shipGlobal.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _shipGlobal.textAlignment = NSTextAlignmentRight;
        }

    }
    return _shipGlobal;
}

- (UILabel *)shipTimeLabel {
    if (!_shipTimeLabel) {
        _shipTimeLabel = [UILabel new];
        _shipTimeLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _shipTimeLabel.font = [UIFont systemFontOfSize:12];
        _shipTimeLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _shipTimeLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _shipTimeLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [UIImageView new];
        _arrowImageView.image = [UIImage imageNamed:@"goods_arrow"];
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
};
@end
