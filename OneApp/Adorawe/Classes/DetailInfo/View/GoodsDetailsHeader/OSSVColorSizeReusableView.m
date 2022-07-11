//
//  OSSVColorSizeReusableView.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVColorSizeReusableView.h"
#import "Adorawe-Swift.h"

@interface OSSVColorSizeReusableView ()

@property (nonatomic, strong)UILabel        *mainLab;
@property (nonatomic, strong)UILabel        *optionLab;
@property (nonatomic, strong)UIView         *rightView;
@property (nonatomic, strong)UIButton       *rightBtn;

@end


@implementation OSSVColorSizeReusableView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (UILabel *)mainLab{
    if (!_mainLab) {
        _mainLab = [UILabel new];
        _mainLab.textColor = OSSVThemesColors.col_0D0D0D;
        _mainLab.font  = [UIFont boldSystemFontOfSize:14];
    }
    return _mainLab;
}

- (UILabel *)optionLab{
    if (!_optionLab) {
        _optionLab = [UILabel new];
        _optionLab.font  = FontWithSize(14);
    }
    return _optionLab;
}

- (UIView *)rightView{
    if (!_rightView) {
        _rightView = [UIView new];
        _rightView.hidden = YES;
    }
    return _rightView;
}
- (UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.titleLabel.font = FontWithSize(12);
        [_rightBtn setImage:[UIImage imageNamed:@"detail_size"] forState:UIControlStateNormal];
        _rightBtn.tintColor = OSSVThemesColors.col_B62B21;
        [_rightBtn setAttributedTitle:[NSString underLineSizeChatWithTitleStr:nil] forState:UIControlStateNormal];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
        }else{
            [_rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -4, 0, 4)];
        }
        
        [_rightBtn addTarget:self action:@selector(sizeChatAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}


-(void)setUpView{
    [self addSubview:self.mainLab];
    [self addSubview:self.optionLab];
    
    [self addSubview:self.rightView];
    [self.rightView addSubview:self.rightBtn];
    
    [self.mainLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(14);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.optionLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mainLab.mas_trailing);
        make.centerY.mas_equalTo(self.mainLab.mas_centerY);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo(84);
        make.height.mas_equalTo(20);
    }];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.rightView.mas_trailing);
        make.centerY.mas_equalTo(self.rightView.mas_centerY);
    }];
}

- (void)setGoods_id:(NSString *)goods_id{
    _goods_id = goods_id;
}

- (void)setSpecsModel:(OSSVSpecsModel *)specsModel{
    if (specsModel) {
        if (![OSSVNSStringTool isEmptyString:STLToString(specsModel.size_chart_url)] && ![OSSVNSStringTool isEmptyString:STLToString(specsModel.size_chart_title)]) {
            [_rightBtn setAttributedTitle:[NSString underLineSizeChatWithTitleStr:specsModel.size_chart_title] forState:UIControlStateNormal];
        }
        if ([specsModel.spec_type integerValue] == 1) {
            self.rightView.hidden = YES;
        }else if([specsModel.spec_type integerValue] == 2){
            if (![OSSVNSStringTool isEmptyString:STLToString(specsModel.size_chart_url)] && ![OSSVNSStringTool isEmptyString:STLToString(specsModel.size_chart_title)]) {
                self.rightView.hidden = NO;
                [self.rightBtn setTitle:specsModel.size_chart_title forState:UIControlStateNormal];
            }else{
                self.rightView.hidden = YES;
            }
        }
        
        NSString *spec_name = [NSString stringWithFormat:@"%@:", specsModel.spec_name];
        self.mainLab.text = spec_name;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *optionStr;
            for (OSSVAttributeItemModel *itemModel in specsModel.brothers) {
                if ([itemModel.goods_id isEqualToString:_goods_id]) {
                    optionStr = itemModel.value;
                    break;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (specsModel.isSelectSize && [specsModel.spec_type integerValue] == 2) {
                    self.optionLab.text = optionStr;
                    self.optionLab.textColor = OSSVThemesColors.col_0D0D0D;
                }else if([specsModel.spec_type integerValue] == 1){
                    self.optionLab.text = optionStr;
                    self.optionLab.textColor = OSSVThemesColors.col_0D0D0D;
                }else{
                    _optionLab.textColor = OSSVThemesColors.col_B62B21;
//                    _optionLab.text = STLLocalizedString_(@"selectSize", nil);
                    _optionLab.text = @"";
                }
            });
        });
    }
}


- (void)sizeChatAction:(UIButton *)sender{
    if (self.sizeChatblock) {
        self.sizeChatblock();
    }
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.optionLab.text = nil;
}

@end
