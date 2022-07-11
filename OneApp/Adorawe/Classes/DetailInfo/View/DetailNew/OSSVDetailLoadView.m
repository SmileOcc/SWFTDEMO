//
//  OSSVDetailLoadView.m
// XStarlinkProject
//
//  Created by odd on 2021/7/29.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailLoadView.h"

#define kIPHONEX_Goods_TOP_SPACE44                   ((SCREEN_HEIGHT > 736.0)?44:0)

@implementation OSSVDetailLoadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        self.priceView = [self createView];
        self.nameView = [self createView];
        self.activityView = [self createView];
        self.actiVityNameView = [self createView];
        
        self.attributeColorHeaderView = [self createView];
        self.activityColorView = [self createView];
        self.activityColorView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        self.attributeSizeHeaderView = [self createView];
        self.activitySizeView = [self createView];
        self.activitySizeView.backgroundColor = [OSSVThemesColors stlWhiteColor];

        self.transportHeaderView = [self createView];
        self.transportDescView = [self createView];

        self.oneView = [self createView];
        self.twoView = [self createView];
        self.threeView = [self createView];
        self.fourView = [self createView];

        self.reivewHeaderView = [self createView];
        self.advHeaderView = [self createView];
        self.headerView = [self createView];

        [self addSubview:self.imageView];
        [self addSubview:self.secondImageView];
        
        [self addSubview:self.priceView];
        [self addSubview:self.nameView];
        [self addSubview:self.activityView];
        [self addSubview:self.actiVityNameView];
        
        [self addSubview:self.attributeColorHeaderView];
        [self addSubview:self.activityColorView];
        [self addSubview:self.attributeSizeHeaderView];
        [self addSubview:self.activitySizeView];
        
        [self addSubview:self.transportHeaderView];
        [self addSubview:self.transportDescView];
        
        [self addSubview:self.oneView];
        [self addSubview:self.twoView];
        [self addSubview:self.threeView];
        [self addSubview:self.fourView];
        
        [self addSubview:self.reivewHeaderView];
        [self addSubview:self.advHeaderView];
        [self addSubview:self.headerView];
        
        [self addSubview:self.collectBtn];
        [self addSubview:self.shareBtn];
        
        [self addSubview:self.bottomView];
        
        
        [self hideShare];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.top.mas_equalTo(self.mas_top).mas_offset(APP_TYPE == 3 ? kIPHONEX_Goods_TOP_SPACE44 - 7 : kIPHONEX_Goods_TOP_SPACE44);
            make.height.mas_equalTo(SCREEN_WIDTH);
            if (APP_TYPE == 3) {
                make.width.mas_equalTo(self.imageView.mas_height);
            } else {
                make.width.mas_equalTo(self.imageView.mas_height).multipliedBy(3.0/4.0);
            }
        }];
        
        [self.secondImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.imageView.mas_trailing).offset(8);
            make.top.mas_equalTo(self.imageView.mas_top);
            make.height.mas_equalTo(SCREEN_WIDTH);
            make.width.mas_equalTo(self.imageView.mas_height).multipliedBy(3.0/4.0);
        }];
        
        [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(13);
            make.size.mas_equalTo(CGSizeMake(100, 20));
            make.top.mas_equalTo(self.imageView.mas_bottom).offset(23);
        }];
        
        [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-13);
            make.height.mas_equalTo(16);
            make.top.mas_equalTo(self.priceView.mas_bottom).offset(8);
        }];
        
        [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.size.mas_equalTo(CGSizeMake(122, 16));
            make.top.mas_equalTo(self.nameView.mas_bottom).offset(8);
        }];
        
        [self.actiVityNameView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-54);
            make.height.mas_equalTo(16);
            make.top.mas_equalTo(self.activityView.mas_bottom).offset(8);
        }];
        
        
        
        [self.attributeColorHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.size.mas_equalTo(CGSizeMake(122, 20));
            make.top.mas_equalTo(self.actiVityNameView.mas_bottom).offset(16);
        }];
        
        [self.activityColorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.height.mas_equalTo(48);
            make.top.mas_equalTo(self.attributeColorHeaderView.mas_bottom).offset(8);
        }];
        
        [self.attributeSizeHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.size.mas_equalTo(CGSizeMake(122, 20));
            make.top.mas_equalTo(self.activityColorView.mas_bottom).offset(18);
        }];
        
        [self.activitySizeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.height.mas_equalTo(48);
            make.top.mas_equalTo(self.attributeSizeHeaderView.mas_bottom).offset(8);
        }];
        
        
        [self.transportHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.size.mas_equalTo(CGSizeMake(164, 20));
            make.top.mas_equalTo(self.activitySizeView.mas_bottom).offset(36);
        }];
        
        [self.transportDescView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-13);
            make.height.mas_equalTo(16);
            make.top.mas_equalTo(self.transportHeaderView.mas_bottom).offset(8);
        }];
        
        [self.oneView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.top.mas_equalTo(self.transportDescView.mas_bottom).offset(22);
            make.height.mas_equalTo(16);
        }];
        
        [self.twoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-13);
            make.top.mas_equalTo(self.oneView.mas_top);
            make.leading.mas_equalTo(self.oneView.mas_trailing).offset(24);
            make.width.mas_equalTo(self.oneView.mas_width);
            make.height.mas_equalTo(16);
        }];
        
        [self.threeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.top.mas_equalTo(self.oneView.mas_bottom).offset(8);
            make.height.mas_equalTo(16);
        }];
        
        [self.fourView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-13);
            make.top.mas_equalTo(self.threeView.mas_top);
            make.leading.mas_equalTo(self.threeView.mas_trailing).offset(24);
            make.width.mas_equalTo(self.threeView.mas_width);
            make.height.mas_equalTo(16);
        }];
        
        
        [self.reivewHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.size.mas_equalTo(CGSizeMake(240, 20));
            make.top.mas_equalTo(self.threeView.mas_bottom).offset(33);
        }];
        
        [self.advHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.size.mas_equalTo(CGSizeMake(112, 20));
            make.top.mas_equalTo(self.reivewHeaderView.mas_bottom).offset(36);
        }];
        
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_leading);
            make.size.mas_equalTo(CGSizeMake(164, 20));
            make.top.mas_equalTo(self.advHeaderView.mas_bottom).offset(34);
        }];
        
        
        [self.collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.bottom.mas_equalTo(self.imageView.mas_bottom).offset(-19);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
        
        [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.bottom.mas_equalTo(self.collectBtn.mas_top).offset(-12);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(0);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(kIS_IPHONEX ? 60 + 37 : 60);
        }];
        
        [self createColorItemsView];
        [self createSizeItemsView];
    }
    return self;
}

- (void)setImagUrl:(NSString *)imagUrl {
    if (!STLIsEmptyString(imagUrl)) {
        [self.imageView yy_setImageWithURL:[NSURL URLWithString:imagUrl] placeholder:[UIImage imageNamed:@"placeholder_big3_4"]];
    } else {
        self.imageView.image = [UIImage imageNamed:@"placeholder_big3_4"];
    }
}

- (void)createColorItemsView {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i=0; i<5; i++) {
        UIView *itemsView = [[UIView alloc] initWithFrame:CGRectZero];
        itemsView.backgroundColor = [OSSVThemesColors col_EEEEEE];
        [self.activityColorView addSubview:itemsView];
        
        [tempArray addObject:itemsView];
    }
    
    [tempArray mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:12 leadSpacing:0 tailSpacing:0];
    [tempArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.activityColorView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(36, 48));
    }];
}

- (void)createSizeItemsView {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i=0; i<7; i++) {
        UIView *itemsView = [[UIView alloc] initWithFrame:CGRectZero];
        itemsView.backgroundColor = [OSSVThemesColors col_EEEEEE];

        [self.activitySizeView addSubview:itemsView];
        
        [tempArray addObject:itemsView];
    }
    
    [tempArray mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:12 leadSpacing:0 tailSpacing:0];
    [tempArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.activitySizeView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
}

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        _imageView.backgroundColor = [OSSVThemesColors col_EEEEEE];

    }
    return _imageView;
}

- (YYAnimatedImageView *)secondImageView {
    if (!_secondImageView) {
        _secondImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _secondImageView.image = [UIImage imageNamed:@"placeholder_big3_4"];
        _secondImageView.contentMode = UIViewContentModeScaleAspectFill;
        _secondImageView.backgroundColor = [OSSVThemesColors col_EEEEEE];
        _secondImageView.layer.masksToBounds = YES;

    }
    return _secondImageView;
}

- (UIButton *)collectBtn {
    if (!_collectBtn) {
        _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collectBtn setImage:[UIImage imageNamed:@"goods_like18"] forState:UIControlStateNormal];
        _collectBtn.backgroundColor = [UIColor clearColor];
        _collectBtn.backgroundColor = [OSSVThemesColors col_ffffff:0.8];
        _collectBtn.layer.borderWidth = 0.5;
        _collectBtn.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        _collectBtn.layer.cornerRadius = 16;
        _collectBtn.layer.masksToBounds = YES;
        _collectBtn.userInteractionEnabled = NO;
    }
    return _collectBtn;
}

- (UIButton *)shareBtn {
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareBtn setImage:[UIImage imageNamed:@"goods_share"] forState:UIControlStateNormal];
        _shareBtn.backgroundColor = [OSSVThemesColors col_ffffff:0.8];
        _shareBtn.layer.borderWidth = 0.5;
        _shareBtn.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        _shareBtn.layer.cornerRadius = 16;
        _shareBtn.layer.masksToBounds = YES;
        _shareBtn.userInteractionEnabled = NO;
    }
    return _shareBtn;
}

- (OSSVDetailBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[OSSVDetailBottomView alloc] initWithFrame:CGRectZero];
        _bottomView.userInteractionEnabled = NO;
    }
    return _bottomView;
}

- (UIView *)createView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [OSSVThemesColors col_EEEEEE];
    return view;
}

- (void)hideShare {
    self.shareBtn.hidden = YES;
}

@end
