//
//  OSSVMyRulerVC.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVMyRulerVC.h"
#import "OSSVRulesView.h"

@interface OSSVMyRulerVC ()

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIButton *bgBtn;

@property (nonatomic, strong) OSSVRulesView *ruleView;

@property (nonatomic, strong) UIButton *disBtn;
@property (nonatomic, strong) UILabel *titLab;
@property (nonatomic, strong) UILabel *valueLab;
@property (nonatomic, strong) UILabel *lastLab;
@property (nonatomic, strong) UIButton *saveBtn;;

@end

@implementation OSSVMyRulerVC

- (instancetype)init{
    self = [super init];
    if (self) {
        // 设置半透明
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }else{
            self.modalPresentationStyle=UIModalPresentationCurrentContext;
        }
        //
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    
    [self setUpView];
    
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    
}

- (void)setUpView{
    [self.view addSubview:self.bgBtn];
    [self.view addSubview:self.mainView];
    [self.mainView addSubview:self.disBtn];
    [self.mainView addSubview:self.titLab];
    [self.mainView addSubview:self.valueLab];
    [self.mainView addSubview:self.lastLab];
    [self.mainView addSubview:self.ruleView];
    [self.mainView addSubview:self.saveBtn];
    
    
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(289 + kIPHONEX_BOTTOM);
    }];
    
    [self.bgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.mainView.mas_top);
    }];
    
    [self.disBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(15);
        make.trailing.mas_offset(-15);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.titLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainView.mas_top).offset(46);
        make.centerX.mas_equalTo(self.mainView.mas_centerX);
    }];
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titLab.mas_bottom).offset(25);
            make.centerX.mas_equalTo(self.mainView.mas_centerX).offset(10);
        }];
    }else{
        [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titLab.mas_bottom).offset(25);
            make.centerX.mas_equalTo(self.mainView.mas_centerX).offset(-10);
        }];
    }
    
    
    [self.lastLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.valueLab.mas_bottom);
        make.leading.mas_equalTo(self.valueLab.mas_trailing);
    }];
    
    [self.ruleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.valueLab.mas_bottom).offset(12);
        make.leading.trailing.mas_equalTo(self.mainView);
        make.height.mas_equalTo(76);
    }];
    
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.ruleView.mas_bottom).offset(32);
        make.leading.mas_equalTo(self.mainView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-12);
        make.height.mas_equalTo(44);
    }];
    
    [self.mainView layoutIfNeeded];
    [self.mainView stlAddCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(6, 6)];
    
    if (self.type == sizeCellTypeHeight) {
        _titLab.text = STLLocalizedString_(@"Choose_Height", nil);
    }else if (self.type == sizeCellTypeWeight){
        _titLab.text = STLLocalizedString_(@"Choose_Weight", nil);
    }
}

- (void)setSizeModel:(OSSVSizesModel *)sizeModel{
    [self setUpView];
    self.ruleView.sizeType = sizeModel.size_type;
    self.ruleView.type = self.type;
    if (sizeModel.size_type == 1) {
        // cm
        if (sizeModel.gender == 1) {
            // male 男生
            if (self.type == sizeCellTypeHeight) {
                _valueLab.text = @"180.0";
                if ([sizeModel.height floatValue] > 0) {
                    _valueLab.text = [NSString stringWithFormat:@"%@", sizeModel.height];
                }
                _lastLab.text = STLLocalizedString_(@"cm", nil);
            }else if (self.type == sizeCellTypeWeight){
                _valueLab.text = @"67.0";
                if ([sizeModel.weight floatValue] > 0) {
                    _valueLab.text = [NSString stringWithFormat:@"%@", sizeModel.weight];
                }
                _lastLab.text = STLLocalizedString_(@"kg", nil);
            }
            
        }else{
            // female 女生
            if (self.type == sizeCellTypeHeight) {
                _valueLab.text = @"160.0";
                if ([sizeModel.height floatValue] > 0) {
                    _valueLab.text = [NSString stringWithFormat:@"%@", sizeModel.height];
                }
                _lastLab.text = STLLocalizedString_(@"cm", nil);
            }else if (self.type == sizeCellTypeWeight){
                _valueLab.text = @"50.0";
                if ([sizeModel.weight floatValue] > 0) {
                    _valueLab.text = [NSString stringWithFormat:@"%@", sizeModel.weight];
                }
                _lastLab.text = STLLocalizedString_(@"kg", nil);
            }
        }
        self.ruleView.defaultValue = [_valueLab.text doubleValue];
    }else{
        // inch
        if (sizeModel.gender == 1) {
            // male 男生
            if (self.type == sizeCellTypeHeight) {
                _valueLab.text = @"70.9";
                if ([sizeModel.height floatValue] > 0) {
                    _valueLab.text = [NSString stringWithFormat:@"%@", sizeModel.height];
                }
                _lastLab.text = STLLocalizedString_(@"inch", nil);
            }else if (self.type == sizeCellTypeWeight){
                _valueLab.text = @"147.7";
                if ([sizeModel.weight floatValue] > 0) {
                    _valueLab.text = [NSString stringWithFormat:@"%@", sizeModel.weight];
                }
                _lastLab.text = @"lbs";
                _lastLab.text = STLLocalizedString_(@"lbs", nil);
            }
            
        }else{
            // female 女生
            if (self.type == sizeCellTypeHeight) {
                _valueLab.text = @"63.0";
                if ([sizeModel.height floatValue] > 0) {
                    _valueLab.text = [NSString stringWithFormat:@"%@", sizeModel.height];
                }
                _lastLab.text = STLLocalizedString_(@"inch", nil);
            }else if (self.type == sizeCellTypeWeight){
                _valueLab.text = @"110.2";
                if ([sizeModel.weight floatValue] > 0) {
                    _valueLab.text = [NSString stringWithFormat:@"%@", sizeModel.weight];
                }
                _lastLab.text = STLLocalizedString_(@"lbs", nil);
            }
        }
        self.ruleView.defaultValue = [_valueLab.text doubleValue];
    }
}


// lazy
- (UIButton *)bgBtn{
    if (!_bgBtn) {
        _bgBtn = [UIButton new];
        [_bgBtn addTarget:self action:@selector(disBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgBtn;
}

- (UIView *)mainView{
    if (!_mainView) {
        _mainView = [UIView new];
        _mainView.backgroundColor = OSSVThemesColors.stlWhiteColor;
    }
    return _mainView;
}
- (UIButton *)disBtn{
    if (!_disBtn) {
        _disBtn = [UIButton new];
        [_disBtn setImage:[UIImage imageNamed:@"close_16"] forState:UIControlStateNormal];
        [_disBtn addTarget:self action:@selector(disBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _disBtn;
}
- (UILabel *)titLab{
    if (!_titLab) {
        _titLab = [UILabel new];
        _titLab.font = [UIFont boldSystemFontOfSize:14];
        
    }
    return _titLab;
}

- (UILabel *)valueLab{
    if (!_valueLab) {
        _valueLab = [UILabel new];
        _valueLab.font = [UIFont boldSystemFontOfSize:24];
    }
    return _valueLab;
}

- (UILabel *)lastLab{
    if (!_lastLab) {
        _lastLab = [UILabel new];
        _lastLab.font = FontWithSize(18);
    }
    return _lastLab;
}
- (OSSVRulesView *)ruleView{
    if (!_ruleView) {
        _ruleView = [OSSVRulesView new];
        _ruleView.backgroundColor = OSSVThemesColors.col_F5F5F5;
        @weakify(self);
        _ruleView.scrollblock = ^(NSString * _Nonnull value) {
            @strongify(self);
            self.valueLab.text = [NSString stringWithFormat:@"%@", value];
        };
    }
    return _ruleView;
}
- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [UIButton new];
        [_saveBtn setTitle:STLLocalizedString_(@"SAVE", nil) forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveBtn.backgroundColor = OSSVThemesColors.stlBlackColor;
        _saveBtn.layer.cornerRadius = 3;
        _saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        
        [_saveBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _saveBtn;
}

- (void)saveBtnClick:(UIButton *)sender{
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        if (self.saveBtnblock) {
            self.saveBtnblock(_type, _valueLab.text);
        }
    }];
}

- (void)disBtnClick:(UIButton *)sender{
    @weakify(self)
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        if (self.disBtnblock) {
            self.disBtnblock();
        }
    }];
}

@end
