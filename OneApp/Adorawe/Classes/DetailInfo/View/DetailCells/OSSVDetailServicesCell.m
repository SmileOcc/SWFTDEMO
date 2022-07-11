//
//  OSSVDetailServicesCell.m
// XStarlinkProject
//
//  Created by odd on 2021/6/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailServicesCell.h"

@interface OSSVDetailServicesCell()<OSSVDetailsHeaderServiceViewDelegate>

@end

@implementation OSSVDetailServicesCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:self.goodsServiceView];
        
        [self.goodsServiceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.bgView);
        }];
    }
    return self;
}

- (void)goodsDetailsHeaderGoodsServiceView:(OSSVDetailsHeaderServiceView *)goodsServiceView serviceDesc:(BOOL)flag {
    if (self.stlDelegate && [self.stlDelegate respondsToSelector:@selector(OSSVDetialCell:serviceTip:)]) {
        [self.stlDelegate OSSVDetialCell:self serviceTip:YES];
    }
}
- (void)goodsDetailsHeaderGoodsTransportTime:(OSSVDetailsHeaderServiceView *)goodsServiceView serviceDesc:(BOOL)flag {
    if (self.stlDelegate && [self.stlDelegate respondsToSelector:@selector(OSSVDetialCell:shipTip:)]) {
        [self.stlDelegate OSSVDetialCell:self shipTip:YES];
    }
}


- (void)setInfoModel:(OSSVDetailsBaseInfoModel *)infoModel {
    _infoModel = infoModel;
    [self.goodsServiceView updateHeaderGoodsService:infoModel];
}

- (OSSVDetailsHeaderServiceView *)goodsServiceView {
    if (!_goodsServiceView) {
        _goodsServiceView = [[OSSVDetailsHeaderServiceView alloc] initWithFrame:CGRectZero];
        _goodsServiceView.delegate = self;
    }
    return _goodsServiceView;
}
@end
