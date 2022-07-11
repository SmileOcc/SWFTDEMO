//
//  OSSVDetailBottomView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailBottomView.h"

@implementation OSSVDetailBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = OSSVThemesColors.col_FFFFFF;
        
        [self addSubview:self.addBtn];
        [self addSubview:self.horizontalLine];

        [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(13);
            make.top.mas_equalTo(self.mas_top).offset(8);
            make.height.mas_equalTo(44);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-13);
        }];
        
        [self.horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(0.5);
            make.top.mas_equalTo(self.mas_top);
        }];
         
    }
    return self;
}

- (void)setEnableCart:(BOOL)enableCart {
    _enableCart = enableCart;
    
    if (enableCart) {
        _addBtn.backgroundColor = [OSSVThemesColors col_262626];
        _addBtn.userInteractionEnabled = YES;
        [_addBtn setTitle:STLLocalizedString_(@"addToBag",nil) forState:UIControlStateNormal];
    } else {
       ///断码订阅
        _addBtn.backgroundColor = APP_TYPE == 3 ? OSSVThemesColors.col_9F5123 : [OSSVThemesColors col_262626];
        ///不禁用 改为弹出断码订阅
        _addBtn.userInteractionEnabled = YES;
        [_addBtn setTitle:STLLocalizedString_(@"Arrival_Notify", nil) forState:UIControlStateNormal];
    }
}

#pragma mark - action
- (void)cartBtnTouch:(UIButton*)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(goodsDetailBottomEvent:)]) {
        [self.delegate goodsDetailBottomEvent:GoodsDetailBottomEventCart];
    }
}

- (void)chatBtnTouch:(UIButton*)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(goodsDetailBottomEvent:)]) {
        [self.delegate goodsDetailBottomEvent:GoodsDetailBottomEventChat];
    }
}

- (void)actionSheet:(UIButton*)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(goodsDetailBottomEvent:)]) {
        if (_enableCart) {
            [self.delegate goodsDetailBottomEvent:GoodsDetailBottomEventAddCart];
        }else{
            [self.delegate goodsDetailBottomEvent:GoodsDetailBottomEventSubscribeAlert];
        }
        
    }
}

#pragma mark - LazyLoad

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [[UIButton alloc] init];
        _addBtn.tag = GoodsDetailEnumTypeAdd+2000;
        _addBtn.userInteractionEnabled = NO;
        [_addBtn addTarget:self action:@selector(actionSheet:) forControlEvents:UIControlEventTouchUpInside];
        _addBtn.backgroundColor = [OSSVThemesColors col_0D0D0D];
        if (APP_TYPE == 3) {
            [_addBtn setTitle:STLLocalizedString_(@"addToBag",nil)  forState:UIControlStateNormal];

        } else {
            [_addBtn setTitle:[STLLocalizedString_(@"addToBag",nil) uppercaseString] forState:UIControlStateNormal];
        }
        _addBtn.titleLabel.font = [UIFont stl_buttonFont:APP_TYPE == 3 ? 18 : 14];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _addBtn;
}

- (UIView *)horizontalLine {
    if (!_horizontalLine) {
        _horizontalLine = [[UIView alloc] init];
        _horizontalLine.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _horizontalLine;
}
@end
