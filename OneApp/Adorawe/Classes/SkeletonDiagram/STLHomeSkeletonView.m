//
//  STLHomeSkeletonView.m
// XStarlinkProject
//
//  Created by Kevin on 2021/6/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLHomeSkeletonView.h"
@interface STLHomeSkeletonView ()
@property (nonatomic, strong) UIView *topView; //跑马灯骨架图
@property (nonatomic, strong) UIView *topBannerView; //跑马灯骨架图
@property (nonatomic, strong) UIView *singleView; //单列商品骨架图
@property (nonatomic, strong) UIView *flashTopView; //闪购头部骨架图
@property (nonatomic, strong) STLFlashSkeletionView *flashView; //闪购商品骨架图
@property (nonatomic, strong) UIView *secondLineView; //第二条宽横线
@property (nonatomic, strong) UIView *secondBannerView; //第二个banner图
@property (nonatomic, strong) UIView *thirdLineView; //第三条宽横条
@property (nonatomic, strong) UIView *thirdBannerView; //第三个banner图
//@property (nonatomic, strong) UIView *topView; //跑马灯骨架图

@end


@implementation STLHomeSkeletonView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.topView];
        [self addSubview:self.topBannerView];
        [self addSubview:self.singleView];

        for (int i = 0; i < 7; i++) {
            _singleView = [UIView new];
            _singleView.backgroundColor = [OSSVThemesColors col_EEEEEE];
            [self addSubview:self.singleView];
            
            [self.singleView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).offset(12*(i+1)+(i*72));
                make.top.mas_equalTo(self.topBannerView.mas_bottom).offset(12);
                make.width.equalTo(72);
                make.height.equalTo(96);
            }];

        }
        
        [self addSubview:self.flashTopView];
        
        for (int i = 0; i < 6; i++) {
            _flashView = [STLFlashSkeletionView new];
            _flashView.backgroundColor = [UIColor whiteColor];
            [self addSubview:_flashView];
            
            [self.flashView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).offset(12*(i+1)+(i*102));
                make.top.mas_equalTo(self.flashTopView.mas_bottom).offset(12);
                make.width.equalTo(102);
                make.height.equalTo(180);
            }];
        }
        
        [self addSubview:self.secondLineView];
        [self addSubview:self.secondBannerView];
        [self addSubview:self.thirdLineView];
        [self addSubview:self.thirdBannerView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.mas_top).offset(12);
        make.height.equalTo(20);
    }];
    
    [self.topBannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.topView.mas_bottom).offset(12);
        make.height.equalTo(201);
    }];
    
    
    [self.flashTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.singleView.mas_bottom).offset(12);
        make.height.equalTo(24);
    }];
    
    [self.secondLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.flashView.mas_bottom).offset(12);
        make.height.equalTo(24);
    }];
    
    [self.secondBannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.secondLineView.mas_bottom).offset(12);
        make.height.equalTo(160);
    }];

    [self.thirdLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.secondBannerView.mas_bottom).offset(24);
        make.height.equalTo(24);
    }];
    
    [self.thirdBannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.thirdLineView.mas_bottom).offset(12);
        make.height.equalTo(120);
    }];
}
- (UIView *)topView {
    if (!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _topView;
}
- (UIView *)topBannerView {
    if (!_topBannerView) {
        _topBannerView = [UIView new];
        _topBannerView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _topBannerView;
}


- (UIView *)flashTopView {
    if (!_flashTopView) {
        _flashTopView = [UIView new];
        _flashTopView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _flashTopView;
}

- (UIView *)secondLineView {
    if (!_secondLineView) {
        _secondLineView = [UIView new];
        _secondLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _secondLineView;
}

- (UIView *)secondBannerView {
    if (!_secondBannerView) {
        _secondBannerView = [UIView new];
        _secondBannerView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _secondBannerView;
}

- (UIView *)thirdLineView {
    if (!_thirdLineView) {
        _thirdLineView = [UIView new];
        _thirdLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _thirdLineView;
}

- (UIView *)thirdBannerView {
    if (!_thirdBannerView) {
        _thirdBannerView = [UIView new];
        _thirdBannerView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _thirdBannerView;
}


@end


///闪购商品

@interface STLFlashSkeletionView ()
@property (nonatomic, strong) UIView *productImgView;
@property (nonatomic, strong) UIView *priceView;
@property (nonatomic, strong) UIView *oldPriceView;
@end

@implementation STLFlashSkeletionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addSubview:self.productImgView];
        [self addSubview:self.priceView];
        [self addSubview:self.oldPriceView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.productImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading);
        make.top.mas_equalTo(self.mas_top);
        make.width.equalTo(102);
        make.height.equalTo(136);
    }];
    
    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.productImgView.mas_leading);
        make.top.mas_equalTo(self.productImgView.mas_bottom).offset(6);
        make.height.equalTo(12);
        make.width.equalTo(74);
    }];
    
    [self.oldPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.productImgView.mas_leading);
        make.top.mas_equalTo(self.priceView.mas_bottom).offset(4);
        make.height.equalTo(12);
        make.width.equalTo(51);
    }];
}
- (UIView *)productImgView {
    if (!_productImgView) {
        _productImgView = [UIView new];
        _productImgView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _productImgView;
}

- (UIView *)priceView {
    if (!_priceView) {
        _priceView = [UIView new];
        _priceView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _priceView;
}
- (UIView *)oldPriceView{
    if (!_oldPriceView) {
        _oldPriceView = [UIView new];
        _oldPriceView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _oldPriceView;
}


@end
