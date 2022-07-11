//
//  OSSVDetailAdvertiseViewCell.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailAdvertiseViewCell.h"
#import "OSSVDetailsHeaderScrollverAdvView.h"
#import "Adorawe-Swift.h"

@interface OSSVDetailAdvertiseViewCell ()
/** 推荐广告*/
@property (nonatomic, strong) OSSVDetailsHeaderScrollverAdvView *advView;
@end


@implementation OSSVDetailAdvertiseViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];

        self.bgView.backgroundColor = STLRandomColor();
        [self.bgView addSubview:self.advView];
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    [self.advView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bgView);
    }];

}

-(void)setModel:(OSSVDetailsListModel *)model{
    // 滑动广告
    self.advView.goodsInforModel = model.goodsBaseInfo;
    self.advView.advBanners = model.banner;
}

- (OSSVDetailsHeaderScrollverAdvView *)advView {
    if (!_advView) {
        _advView = [[OSSVDetailsHeaderScrollverAdvView alloc] init];
        @weakify(self)
        _advView.advBlock = ^(OSSVAdvsEventsModel * _Nonnull model) {
            @strongify(self)
            [GATools logGoodsBannerImgWithItemListName:model.name screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.model.goodsBaseInfo.goodsTitle)]];
            if (self.stlDelegate && [self.stlDelegate respondsToSelector:@selector(OSSVDetialCell:adv:)]) {
                [self.stlDelegate OSSVDetialCell:self adv:model];
            }
        };
    }
    return _advView;
}
@end
