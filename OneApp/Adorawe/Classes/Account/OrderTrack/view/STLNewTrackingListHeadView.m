//
//  OSSVNewTrackieListeHeadView.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVNewTrackieListeHeadView.h"
//#import "OSSVAlreadyeSigneModel.h"
@interface OSSVNewTrackieListeHeadView ()
@property (nonatomic, strong) UILabel *trackStatus; //物流状态
@property (nonatomic, strong) UILabel *timeLabel; //时间
@property (nonatomic, strong) UILabel *trackNumLabel; //物流单号
@property (nonatomic, strong) UIView  *grayLineView;
@end
@implementation OSSVNewTrackieListeHeadView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.trackStatus];
        [self addSubview:self.timeLabel];
        [self addSubview:self.trackNumLabel];
        [self addSubview:self.grayLineView];
    }
    return self;
}

- (UILabel *)trackStatus {
    if (!_trackStatus) {
        _trackStatus = [UILabel new];
        _trackStatus.textColor = STLThemeColor.col_0D0D0D;
//        _trackStatus.text = @"Waiting for shipment";
        _trackStatus.font = [UIFont boldSystemFontOfSize:15];
    }
    return _trackStatus;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel  new];
        _timeLabel.textColor = STLThemeColor.col_666666;
        _timeLabel.font = [UIFont systemFontOfSize:11];
//        _timeLabel.text = @"2020-11-01 11:23";
    }
    return _timeLabel;
}

- (UILabel *)trackNumLabel {
    if (!_trackNumLabel) {
        _trackNumLabel = [UILabel  new];
//        _trackNumLabel.text = @"No logistics tracking number";
        _trackNumLabel.textColor = STLThemeColor.col_666666;
        _trackNumLabel.textAlignment = NSTextAlignmentRight;
        _trackNumLabel.font = [UIFont systemFontOfSize:11];

    }
    return _trackNumLabel;
}
- (UIView *)grayLineView {
    if (!_grayLineView) {
        _grayLineView = [UIView new];
        _grayLineView.backgroundColor = STLThemeColor.col_F5F5F5;
    }
    return _grayLineView;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.trackStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.top.mas_equalTo(self.mas_top).offset(12);
        make.height.equalTo(15);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.top.mas_equalTo(self.trackStatus.mas_bottom).offset(4);
        make.height.equalTo(12);
    }];
    
    [self.trackNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.mas_top).offset(14);
        make.height.equalTo(12);
    }];
    
    [self.grayLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(10);
        make.height.equalTo(8);
    }];
}

- (void)setModel:(OSSVTrackingcTotalInformcnModel *)model {
    _model = model;
    if (STLToString(model.trackingNumber).length) {
        self.trackNumLabel.text = [NSString stringWithFormat:@"%@:%@",STLLocalizedString_(@"TrackingNo",nil),STLToString(model.trackingNumber)];

    } else {
        self.trackNumLabel.text = STLLocalizedString_(@"NoTrackingNumber", nil);

    }
    if (model.alreadySign) {
        //已签收
        self.timeLabel.text = STLToString(model.alreadySign.date);
        self.trackStatus.text = STLToString(model.alreadySign.logistics_status);
        return;
    }
    
    if (model.refuseSign) {
        //拒签收
        self.timeLabel.text = STLToString(model.refuseSign.date);
        self.trackStatus.text = STLToString(model.refuseSign.status);
        return;
    }



    if (model.transport) {
        //运输中
        self.timeLabel.text = STLToString(model.transport.date);
        self.trackStatus.text = STLToString(model.transport.logistics_status);
        return;
    }

    if (model.alreadyShip) {
        //已发货
        self.timeLabel.text = STLToString(model.alreadyShip.date);
        self.trackStatus.text = STLToString(model.alreadyShip.logistics_status);
        return;
    }

    //判断对象是否存在
    if (model.waitingShip) {
        //待发货
        self.timeLabel.text = STLToString(model.waitingShip.date);
        self.trackStatus.text = STLToString(model.waitingShip.logistics_status);
        return;
    }

    
}
@end
