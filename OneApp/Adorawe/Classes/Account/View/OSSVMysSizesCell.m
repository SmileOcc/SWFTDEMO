//
//  OSSVMysSizesCell.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVMysSizesCell.h"
#import "DLRadioButton.h"
#import "OSSVMsySizeSubsCell.h"
@interface OSSVMysSizesCell()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UILabel *titLab;

@property (nonatomic, strong) UIButton *cmBtn;
@property (nonatomic, strong) UIButton *inchBtn;

@property (nonatomic, strong) DLRadioButton *maleBtn;
@property (nonatomic, strong) DLRadioButton *famaleBtn;

@property (nonatomic, strong) UIImageView *rightView;
@property (nonatomic, strong) UILabel *rightLab;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UICollectionView *shapColl;

@property (nonatomic, strong) NSArray *shapArray;

@end

@implementation OSSVMysSizesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setUpView];
    }
    return self;
}

/// setupView
- (void)setUpView{
    [self.contentView addSubview:self.titLab];
    [self.contentView addSubview:self.cmBtn];
    [self.contentView addSubview:self.inchBtn];
    [self.contentView addSubview:self.maleBtn];
    [self.contentView addSubview:self.famaleBtn];
    [self.contentView addSubview:self.rightLab];
    [self.contentView addSubview:self.rightView];
    [self.contentView addSubview:self.shapColl];
    [self.contentView addSubview:self.lineView];
    [self addAllConstraint];
    [self hideAllSub];
}

/// 添加约束
- (void)addAllConstraint{
    
    [self.titLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    
    [self.inchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-12);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(64);
    }];
    [self.cmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.inchBtn.mas_leading);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(64);
    }];
    
    [self.famaleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(68);
    }];
    [self.maleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.famaleBtn.mas_leading).offset(-27);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(68);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-10);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(24);
    }];
    [self.rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.rightView.mas_leading).offset(0);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    [self.shapColl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titLab.mas_bottom).offset(13);
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
        make.height.mas_equalTo(0);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
}


/// delegate

/// lazy
- (UILabel *)titLab{
    if (!_titLab) {
        _titLab = [UILabel new];
        _titLab.font = FontWithSize(12);
        _titLab.textColor = OSSVThemesColors.col_666666;
    }
    return _titLab;
}

- (UIButton *)cmBtn{
    if (!_cmBtn) {
        _cmBtn = [UIButton new];
        [_cmBtn setTitle:STLLocalizedString_(@"CM", nil) forState:UIControlStateNormal];
        _cmBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_cmBtn setBackgroundImage:[UIImage yy_imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_cmBtn setBackgroundImage:[UIImage yy_imageWithColor:[UIColor blackColor]] forState:UIControlStateSelected];
        [_cmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _cmBtn.layer.borderColor = [UIColor blackColor].CGColor;
        _cmBtn.layer.borderWidth = 1;
        [_cmBtn addTarget:self action:@selector(cmBtnDidSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cmBtn;
}

- (UIButton *)inchBtn{
    if (!_inchBtn) {
        _inchBtn = [UIButton new];
        [_inchBtn setTitle:STLLocalizedString_(@"INCH", nil) forState:UIControlStateNormal];
        _inchBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_inchBtn setBackgroundImage:[UIImage yy_imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_inchBtn setBackgroundImage:[UIImage yy_imageWithColor:[UIColor blackColor]] forState:UIControlStateSelected];
        [_inchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_inchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _inchBtn.layer.borderColor = [UIColor blackColor].CGColor;
        _inchBtn.layer.borderWidth = 1;
        [_inchBtn addTarget:self action:@selector(inchBtnDidSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _inchBtn;
}

- (DLRadioButton *)maleBtn{
    if (!_maleBtn) {
        _maleBtn = [[DLRadioButton alloc] init];
        [_maleBtn setTitle:STLLocalizedString_(@"Male", nil) forState:UIControlStateNormal];
        _maleBtn.iconColor = OSSVThemesColors.col_CCCCCC;
        _maleBtn.iconStrokeWidth = 1.5;
        _maleBtn.titleLabel.font = FontWithSize(14);
        [_maleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_maleBtn setTitleColor:OSSVThemesColors.col_666666 forState:UIControlStateNormal];
        [_maleBtn addTarget:self action:@selector(maleBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
        _maleBtn.otherButtons = @[self.famaleBtn];
    }
    return _maleBtn;
}

- (DLRadioButton *)famaleBtn{
    if (!_famaleBtn) {
        _famaleBtn = [[DLRadioButton alloc] init];
        [_famaleBtn setTitle:STLLocalizedString_(@"Female", nil) forState:UIControlStateNormal];
        _famaleBtn.iconColor = OSSVThemesColors.col_CCCCCC;
        _famaleBtn.iconStrokeWidth = 1.5;
        _famaleBtn.titleLabel.font = FontWithSize(14);
        [_famaleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_famaleBtn setTitleColor:OSSVThemesColors.col_666666 forState:UIControlStateNormal];
        [_famaleBtn addTarget:self action:@selector(femaleBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _famaleBtn;
}

- (UIImageView *)rightView{
    if (!_rightView) {
        _rightView = [UIImageView new];
        _rightView.image = [UIImage imageNamed:@"detail_right_arrow"];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _rightView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
    }
    return _rightView;
}

- (UILabel *)rightLab{
    if (!_rightLab) {
        _rightLab = [UILabel new];
        _rightLab.font = FontWithSize(14);
        _rightLab.textColor = OSSVThemesColors.col_999999;
    }
    return _rightLab;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [OSSVThemesColors col_F5F5F5];
    }
    return _lineView;
}

- (UICollectionView *)shapColl{
    if (!_shapColl) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.minimumLineSpacing = 8.0f;
        flow.minimumInteritemSpacing = 8.0f;
        flow.itemSize = CGSizeMake((SCREEN_WIDTH - 48 - 16)/3, 32);
        _shapColl = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
        _shapColl.backgroundColor = OSSVThemesColors.stlWhiteColor;
        [_shapColl registerClass:[OSSVMsySizeSubsCell class] forCellWithReuseIdentifier:@"OSSVMsySizeSubsCell"];
        _shapColl.delegate = self;
        _shapColl.dataSource = self;
        _shapColl.userInteractionEnabled = NO;
    }
    return _shapColl;
}

/// data
- (void)setSizeModel:(OSSVSizesModel *)sizeModel{
    _sizeModel = sizeModel;
}

/// 隐藏全部按钮
- (void)hideAllSub{
    self.titLab.hidden = NO;
    self.cmBtn.hidden = YES;
    self.inchBtn.hidden = YES;
    self.maleBtn.hidden = YES;
    self.famaleBtn.hidden = YES;
    self.rightLab.hidden = YES;
    self.rightView.hidden = YES;
    self.shapColl.hidden = YES;
    self.lineView.hidden = YES;
    
    self.backgroundColor = OSSVThemesColors.stlWhiteColor;
}

- (void)setCellType:(sizeCellType)cellType{
    _cellType = cellType;
    [self hideAllSub];
    switch (cellType) {
        case sizeCellTypeSize:{
            self.inchBtn.hidden = NO;
            self.cmBtn.hidden = NO;
            self.backgroundColor = [OSSVThemesColors col_F5F5F5];
        }
            break;
        case sizeCellTypeGender:{
            self.famaleBtn.hidden = NO;
            self.maleBtn.hidden = NO;
            self.lineView.hidden = NO;
        }
            
            break;
        case sizeCellTypeHeight:
        case sizeCellTypeWeight:{
            self.rightView.hidden = NO;
            self.rightLab.hidden = NO;
            self.lineView.hidden = NO;
        }
            
            break;
        case sizeCellTypeShap:{
            self.shapColl.hidden = NO;
            [self.titLab mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentView.mas_top).offset(13);
                make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
//                make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
                make.height.mas_equalTo(18);
            }];
            [self.shapColl mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.titLab.mas_bottom).offset(13);
                make.leading.mas_equalTo(12);
                make.trailing.mas_equalTo(-12);
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-13);
            }];
        }
            
            break;
            
        default:{
        }
            break;
    }
    
    [self showDataView];
}

// 显示数据视图
- (void)showDataView{
    _titLab.font = FontWithSize(14);
    if (_cellType == sizeCellTypeSize) {
        if (_sizeModel.size_type != 2) {
            _cmBtn.selected = YES;
            _inchBtn.selected = NO;
            _titLab.text = STLLocalizedString_(@"My_Size", nil);
        }else{
            _cmBtn.selected = NO;
            _inchBtn.selected = YES;
            _titLab.text = STLLocalizedString_(@"My_Size", nil);
        }
        _titLab.font = [UIFont boldSystemFontOfSize:14];
        _titLab.textColor = OSSVThemesColors.stlBlackColor;
    }
    if (_cellType == sizeCellTypeGender) {
        if (_sizeModel.gender == 1) {
            _maleBtn.selected = YES;
            _titLab.text = STLLocalizedString_(@"Gender", nil);
        }else if(_sizeModel.gender == 2){
            _famaleBtn.selected = YES;
            _titLab.text = STLLocalizedString_(@"Gender", nil);
        }
    }
    
    NSInteger flag = 0;
    if (_sizeModel.size_type == 2) {
        flag = 1;
    }
    
    if (_cellType == sizeCellTypeHeight) {
        _titLab.text = STLLocalizedString_(@"Height", nil);
        _rightLab.text = STLLocalizedString_(@"Choose", nil);
        if ([_sizeModel.height integerValue]!= 0) {
            if (flag == 0) {
                if (_sizeModel.size_type != 2) {
                    NSString *height = [NSString stringWithFormat:@"%.0ld", [_sizeModel.height integerValue]];
                    _rightLab.text = [NSString stringWithFormat:@"%@ %@", height, STLLocalizedString_(@"cm", nil)];
                }else{
                    _rightLab.text = [NSString stringWithFormat:@"%@ %@", _sizeModel.height, STLLocalizedString_(@"cm", nil)];
                }
            }else{
                _rightLab.text = [NSString stringWithFormat:@"%@ %@", _sizeModel.height, STLLocalizedString_(@"inch", nil)];
            }
            if (_sizeModel.height > 0) {
                _rightLab.textColor = OSSVThemesColors.col_0D0D0D;
            }
        }
    }
    if (_cellType == sizeCellTypeWeight) {
        _titLab.text = STLLocalizedString_(@"Weight", nil);
        _rightLab.text = STLLocalizedString_(@"Choose", nil);
        if ([_sizeModel.weight integerValue]!= 0) {
            if (flag == 0) {
                _rightLab.text = [NSString stringWithFormat:@"%@ %@", _sizeModel.weight, STLLocalizedString_(@"kg", nil)];
            }else{
                _rightLab.text = [NSString stringWithFormat:@"%@ %@", _sizeModel.weight, STLLocalizedString_(@"lbs", nil)];
            }
            if (_sizeModel.weight > 0) {
                _rightLab.textColor = OSSVThemesColors.col_0D0D0D;
            }
        }
    }
    
    if (_cellType == sizeCellTypeShap) {
        self.shapArray = _sizeModel.shape_options;
        [self.shapColl reloadData];
        _titLab.text = STLLocalizedString_(@"Shape", nil);
    }

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.shapArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSVMsySizeSubsCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OSSVMsySizeSubsCell" forIndexPath:indexPath];
    STLSizeShapModel *shapModel = self.shapArray[indexPath.item];
    cell.titStr = shapModel.shape_title;
    cell.selected = NO;
    if ([_sizeModel.height integerValue] > 0 && [_sizeModel.weight integerValue] > 0) {
        // 计算
        [self changeSelectedStatusWithCell:cell indexPath:indexPath];
    }else{
        if ([shapModel.bmi_start isEqualToString:@"25"] && [shapModel.bmi_end isEqualToString:@"29.9"]) {
            cell.selected = YES;
            _sizeModel.option = shapModel.shape_title;
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSArray <OSSVMsySizeSubsCell *> *array = [collectionView visibleCells];
//    for (OSSVMsySizeSubsCell *cell in array) {
//        cell.selected = NO;
//    }
//    OSSVMsySizeSubsCell *cell = (OSSVMsySizeSubsCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.selected = YES;
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}


- (void)changeSelectedStatusWithCell:(OSSVMsySizeSubsCell *)cell indexPath:(NSIndexPath *) indexPath{
    //BMI公式 = 体重（kg） / 身高的平方 （m²）
    CGFloat height = [_sizeModel.height floatValue];
    CGFloat weight = [_sizeModel.weight floatValue];
    if (_sizeModel.size_type == 2) {
        // inch lbs 转化成cm 与 lbs
        height = height / 0.3937;
        weight = weight / 2.2046;
    }
    CGFloat BMI = weight/(pow(height/100, 2));
    
    NSString *BmiStr = [NSString stringWithFormat:@"%.1lf", BMI];
    
    STLSizeShapModel *shapModel = self.shapArray[indexPath.item];
    if ([BmiStr floatValue] >= [shapModel.bmi_start floatValue] && [BmiStr floatValue] <= [shapModel.bmi_end floatValue]) {
        cell.selected = YES;
        _sizeModel.option = shapModel.shape_title;
        NSString *shapDesc = shapModel.shape_desc;
        if (self.changeSizeDsceblock) {
            self.changeSizeDsceblock(shapDesc);
        }
    }
}

+ (CGFloat)getHeightWithType:(sizeCellType)cellType{
    if (cellType == sizeCellTypeSize) {
        return 56.0f;
    }else if(cellType == sizeCellTypeShap){
        return  44.f + 84.f;
    }else{
        return 44;
    }
}

// 性别按钮
- (void)maleBtnSelected:(DLRadioButton *)sender{
    if (self.sizeDidSelectedblock) {
        self.sizeDidSelectedblock(sizeCellTypeGender, 1);
    }
}

- (void)femaleBtnSelected:(DLRadioButton *)sender{
    if (self.sizeDidSelectedblock) {
        self.sizeDidSelectedblock(sizeCellTypeGender, 2);
    }
}

// size 按钮
- (void)cmBtnDidSelected:(UIButton *)sender{
    if (_cmBtn.isSelected) {
        return;
    }
    self.cmBtn.selected = !self.cmBtn.selected;
    if (self.cmBtn.isSelected) {
        self.inchBtn.selected = !self.cmBtn.isSelected;
    }
    if (self.sizeDidSelectedblock) {
        self.sizeDidSelectedblock(sizeCellTypeSize, 1);
    }
}

- (void)inchBtnDidSelected:(UIButton *)sender{
    if (_inchBtn.selected) {
        return;
    }
    self.inchBtn.selected = !self.inchBtn.selected;
    if (self.inchBtn.isSelected) {
        self.cmBtn.selected = !self.inchBtn.isSelected;
    }
    if (self.sizeDidSelectedblock) {
        self.sizeDidSelectedblock(sizeCellTypeSize, 2);
    }
}


- (NSNumber *)formatValue:(NSString *)valueStr {
    return  @(valueStr.floatValue);
}
@end
