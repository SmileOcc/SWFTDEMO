//
//  OSSColorSizeCell.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSColorSizeCell.h"

@interface OSSColorSizeCell()
@property (nonatomic, assign)NSInteger      spec_type;

@property (nonatomic, strong) UIView        *bgView;
@property (nonatomic, strong) UIView        *colorUnableV;
@property (nonatomic, strong) UIView        *colorSelectV;

@property (nonatomic, strong) CAShapeLayer *border;

@property (nonatomic, strong) UILabel       *sizeLab;

@end

@implementation OSSColorSizeCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView{
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.colorImgV];
    [self.bgView addSubview:self.sizeLab];
    [self.bgView addSubview:self.colorUnableV];
    [self.bgView addSubview:self.colorSelectV];
    [self.contentView addSubview:self.flagLab];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView.mas_top).offset(2);
        
//        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.colorImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.sizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.colorUnableV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.colorSelectV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(1);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-1);
        make.top.mas_equalTo(self.bgView.mas_top).offset(1);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-1);
    }];
    
    [self.flagLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_top).offset(-2);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(8);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(10);
    }];
}

// 设置数据源
//- (void)setSpec_type:(NSInteger)spec_type{
//    _spec_type = spec_type;
//}

- (void)setItemModel:(OSSVAttributeItemModel *)itemModel{
    _itemModel = itemModel;
    if (_itemModel) {
        _spec_type = [_itemModel.type integerValue];
        if (_spec_type == 0) {
            // 颜色
            [self updateColorAction];
        }else{
            [self updateSizeAction];
        }
    }
}

- (void)setGoodsSpecModel:(OSSVSpecsModel *)goodsSpecModel{
    _goodsSpecModel = goodsSpecModel;
}

- (void)setIsJiaoJi:(BOOL)isJiaoJi{
    _isJiaoJi = isJiaoJi;
}

- (void)updateColorAction{
    _sizeLab.hidden = YES;
    _colorImgV.hidden = NO;
    [_colorImgV yy_setImageWithURL:[NSURL URLWithString:_itemModel.goods_thumb] placeholder:[UIImage imageNamed:@"detail_colorPlaceholder"]];
    
    if (_itemModel.is_hot) {
        NSString *str = STLLocalizedString_(@"hot", nil);
        CGFloat sizeToFit = [str boundingRectWithSize:CGSizeMake(36, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil].size.width;
        self.flagLab.text = str;
        [self.flagLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(sizeToFit + 2);
        }];
        self.flagLab.hidden = NO;
    }else{
        [self.flagLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        self.flagLab.hidden = YES;
    }
    
    if ([_goos_id isEqualToString:_itemModel.goods_id]) {
        if (self.goos_numeber > 0 || !self.goodsSpecModel.isSelectSize) {
            [self setSelectedState:ColorSizeStateSelected WithType:_spec_type];
        }else{
            [self setSelectedState:ColorSizeStateAndNoNumber WithType:_spec_type];
        }
    }else{
        [self setSelectedState:ColorSizeStateUnselected WithType:_spec_type];
    }
}

- (void)updateSizeAction{
    _sizeLab.hidden = NO;
    _colorImgV.hidden = YES;
    _sizeLab.text = STLToString(_itemModel.value);
    
    if ([_goos_id isEqualToString:_itemModel.goods_id] && _goodsSpecModel.isSelectSize) {
        if (_goos_numeber < 20 && _goos_numeber > 0) {
            NSString *str =  nil;
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                str = [NSString stringWithFormat:@"%@ %ld",  STLLocalizedString_(@"left", nil), _goos_numeber];
            }else{
                str = [NSString stringWithFormat:@"%ld %@", _goos_numeber, STLLocalizedString_(@"left", nil)];
            }
             
            CGFloat sizeToFit = [str boundingRectWithSize:CGSizeMake(1000, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil].size.width;
            self.flagLab.text = str;
            self.flagLab.hidden = NO;
            [self.flagLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(sizeToFit + 2);
            }];
        }else{
            self.flagLab.hidden = YES;
        }
    }else{
        self.flagLab.hidden = YES;
    }
    
    if (self.isJiaoJi) {
        if (_goodsSpecModel.isSelectSize) {
            if ([_goos_id isEqualToString:_itemModel.goods_id]) {
                if (self.goos_numeber > 0) {
                    [self setSelectedState:ColorSizeStateSelected WithType:_spec_type];
                }else{
                    [self setSelectedState:ColorSizeStateAndNoNumber WithType:_spec_type];
                }
            }else{
                [self setSelectedState:ColorSizeStateUnselected WithType:_spec_type];
            }
            
        }else{
            [self setSelectedState:ColorSizeStateUnselected WithType:_spec_type];
        }
    }else{
        [self setSelectedState:ColorSizeStateUnAble WithType:_spec_type];
    }
    
}

// 设置是否被选中
- (void)setSelectedState:(ColorSizeState)state WithType:(NSInteger)type{
    
    self.bgView.layer.borderWidth = 1;
    if (_border) {
        [_border removeFromSuperlayer];
    }
    if (_colorUnableV) {
        _colorUnableV.hidden = YES;
    }
//    self.contentView.layer.masksToBounds = YES;
    
    switch (state) {
        case ColorSizeStateSelected:{
            self.bgView.layer.borderColor = [UIColor blackColor].CGColor;
            self.bgView.backgroundColor = [UIColor whiteColor];
            self.sizeLab.textColor = OSSVThemesColors.col_0D0D0D;
            self.userInteractionEnabled = YES;
            self.colorSelectV.hidden = NO;
            self.isSelected = YES;
        }
            
            break;
        case ColorSizeStateUnAble:{
            self.bgView.layer.borderColor = [UIColor clearColor].CGColor;
            [self.bgView layoutIfNeeded];
            if (type == 0) {
                [self disPlayLineBorderWithType:type withColor:[UIColor whiteColor]];
                _colorUnableV.hidden = NO;
                self.userInteractionEnabled = NO;
            }else{
                self.bgView.backgroundColor = OSSVThemesColors.col_FAFAFA;
                self.sizeLab.textColor = OSSVThemesColors.col_CCCCCC;
                self.bgView.layer.borderColor = OSSVThemesColors.col_F5F5F5.CGColor;
                self.userInteractionEnabled = NO;
            }
            self.colorSelectV.hidden = YES;
            self.isSelected = NO;
        }
            
            break;
            
        case ColorSizeStateAndNoNumber:{
            self.bgView.layer.borderColor = [UIColor clearColor].CGColor;
            [self.bgView layoutIfNeeded];
            if (type == 0) {
                [self disPlayLineBorderWithType:type withColor:[UIColor blackColor]];
                self.colorUnableV.hidden = NO;
                self.colorSelectV.hidden = NO;
                self.userInteractionEnabled = NO;
            }else{
                self.bgView.backgroundColor = OSSVThemesColors.col_FAFAFA;
                self.sizeLab.textColor = OSSVThemesColors.col_CCCCCC;
                self.bgView.layer.borderColor = OSSVThemesColors.col_F5F5F5.CGColor;
                self.userInteractionEnabled = NO;
                self.colorSelectV.hidden = YES;
                self.colorUnableV.hidden = YES;
                self.userInteractionEnabled = NO;
            }
            self.isSelected = YES;
            
        }
            break;
            
        default:{
            self.bgView.layer.borderColor = OSSVThemesColors.col_EEEEEE.CGColor;
            self.bgView.backgroundColor = [UIColor whiteColor];
            self.sizeLab.textColor = OSSVThemesColors.col_0D0D0D;
            self.userInteractionEnabled = YES;
            self.colorSelectV.hidden = YES;
            self.isSelected = NO;
        }
            
            break;
    }
}

// 没有这个颜色或者尺码的时候 实现虚线边框
- (void)disPlayLineBorderWithType:(NSInteger)type withColor:(UIColor *)lineColor{
    if (!_border) {
        NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
        CGFloat width = [_itemModel.value boundingRectWithSize:CGSizeMake(1000, MAXFLOAT)  options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
        
        width = MAX(width + 14, 36);
        
        
        _border = [CAShapeLayer layer];
        //虚线的颜色
        _border.strokeColor = lineColor.CGColor;
        //填充的颜色
        _border.fillColor = [UIColor clearColor].CGColor;
        //设置路径
        if (type == 0) {
            //颜色
            _border.frame = CGRectMake(0, 0, 36, 46);
            _border.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 36, 46)].CGPath;
        }else{
            _border.frame = CGRectMake(0, 0, width, 34);
            _border.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, 34)].CGPath;
        }
        
        //虚线的宽度
        _border.lineWidth = 1.5f;
        //设置线条的样式
        //    border.lineCap = @"square";
        //虚线的间隔
        _border.lineDashPattern = @[@4, @2];
        [self.bgView.layer addSublayer:_border];
    }else{
        [_border removeFromSuperlayer];
        _border = nil;
        [self disPlayLineBorderWithType:type withColor:lineColor];
    }
}

- (UIView *)bgView{
    if (!_bgView) {
        _bgView  = [UIView new];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UIImageView *)colorImgV{
    if (!_colorImgV) {
        _colorImgV = [UIImageView new];
        _colorImgV.contentMode = UIViewContentModeScaleAspectFill;
        _colorImgV.clipsToBounds = YES;
//        _colorImgV.layer.masksToBounds = YES;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _colorImgV.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
    }
    return _colorImgV;
}

- (UILabel *)sizeLab{
    if (!_sizeLab) {
        _sizeLab = [UILabel new];
        _sizeLab.font = FontWithSize(14);
        _sizeLab.textColor = OSSVThemesColors.col_0D0D0D;
        _sizeLab.textAlignment = NSTextAlignmentCenter;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _sizeLab.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
    }
    return _sizeLab;
}

- (UIView *)colorUnableV{
    if (!_colorUnableV) {
        _colorUnableV = [UIView new];
        _colorUnableV.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        _colorUnableV.hidden = YES;
    }
    return _colorUnableV;
}
- (UIView *)colorSelectV{
    if (!_colorSelectV) {
        _colorSelectV = [UIView new];
        _colorSelectV.backgroundColor = [UIColor clearColor];
        _colorSelectV.layer.borderColor = [UIColor whiteColor].CGColor;
        _colorSelectV.layer.borderWidth = 1;
        _colorSelectV.hidden = YES;
    }
    return _colorSelectV;
}

- (UILabel *)flagLab{
    if (!_flagLab) {
        _flagLab = [UILabel new];
        _flagLab.textAlignment = NSTextAlignmentCenter;
        _flagLab.font = [UIFont boldSystemFontOfSize:8];
        _flagLab.textColor = OSSVThemesColors.col_B62B21;
        _flagLab.backgroundColor = OSSVThemesColors.col_FBE9E9;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _flagLab.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
    }
    return _flagLab;
}

// 两个数组求交集带顺序
- (NSArray *)interArrayWithArray:(NSArray *)array1 other:(NSArray *)array2{
    if (array1 && array1.count > 0 && array2 && array2.count >0) {
        NSMutableArray *marray = [NSMutableArray arrayWithCapacity:1];
        for (int i = 0; i<array1.count; i++) {
            NSString *str1 = array1[i];
            for (int j = 0; j<array2.count; j++) {
                NSString *str2 = array2[j];
                if ([str1 isEqualToString:str2]) {
                    [marray addObject:str1];
                }
            }
        }
        return [marray copy];
    }else{
        return nil;
    }
}
@end
