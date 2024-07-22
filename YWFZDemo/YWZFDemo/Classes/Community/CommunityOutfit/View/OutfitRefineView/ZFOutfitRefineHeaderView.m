//
//  ZFOutfitRefineHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFOutfitRefineHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFOutfitRefineHeaderView ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *attriLabel;
@property (nonatomic, strong) UILabel           *selectedLabel;
@property (nonatomic, strong) UIImageView       *arrowImgView;
@property (nonatomic, strong)  CALayer          *line;
@end

@implementation ZFOutfitRefineHeaderView

#pragma mark - Init Method
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandPropertyTouch)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self addSubview:self.attriLabel];
    [self addSubview:self.selectedLabel];
    [self addSubview:self.arrowImgView];
    [self.layer addSublayer:self.line];
}

- (void)zfAutoLayoutView {
    [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.size.mas_equalTo(CGSizeMake(11, 6));
    }];
    
    [self.attriLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.leading.mas_equalTo(self.mas_leading).offset(12);
    }];
    
    [self.selectedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.leading.mas_equalTo(self.attriLabel.mas_trailing).offset(5);
        make.trailing.mas_equalTo(self.arrowImgView.mas_leading).offset(-12);
        make.width.priorityLow();
    }];
    
    self.line.frame = CGRectMake(0, 44 - MIN_PIXEL, KScreenWidth - 75, MIN_PIXEL);
}

#pragma mark - Gesture Handle
- (void)expandPropertyTouch {
    
    _categoryRefineModel.isExpend = !_categoryRefineModel.isExpend;
    
    CGFloat angle = _categoryRefineModel.isExpend ? -M_PI : 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.arrowImgView.transform =  CGAffineTransformMakeRotation(angle);
    }];
    
    if (self.selectBlock) {
        self.selectBlock(self.categoryRefineModel);
    }
}

#pragma mark - Setter
//-(void)setModel:(ZFOutfitRefineDetailModel *)model {
//    _model = model;
//    self.attriLabel.text = model.name;
//    self.selectedLabel.text = [model.selectArray componentsJoinedByString:@","];
//
//    // 后期这里看看需不需要记住展开状态
//    [self setNeedsDisplay];
//}
- (void)setCategoryRefineModel:(CategoryRefineDetailModel *)categoryRefineModel {
    _categoryRefineModel = categoryRefineModel;
    
    self.attriLabel.text = categoryRefineModel.name;
    self.selectedLabel.text = [categoryRefineModel.selectArray componentsJoinedByString:@","];

    // 后期这里看看需不需要记住展开状态
    [self setNeedsDisplay];
}

#pragma mark - Public Methods
+ (NSString *)setIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - Rewrite Methods
-(void)prepareForReuse {
    [super prepareForReuse];
    self.attriLabel.text = nil;
    self.selectedLabel.text = nil;
}

#pragma mark - Getter
- (UILabel *)attriLabel {
    if (!_attriLabel) {
        _attriLabel = [UILabel new];
        _attriLabel.numberOfLines = 1;
        _attriLabel.font = [UIFont systemFontOfSize:14.0];
        _attriLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _attriLabel.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        
    }
    return _attriLabel;
}

- (UILabel *)selectedLabel {
    if (!_selectedLabel) {
        _selectedLabel = [UILabel new];
        _selectedLabel.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _selectedLabel.numberOfLines = 1;
        _selectedLabel.font = [UIFont systemFontOfSize:14.0];
        _selectedLabel.textColor = ZFC0x2D2D2D();
        _selectedLabel.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    }
    return _selectedLabel;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
        _arrowImgView.image = [UIImage imageNamed:@"arrow_down"];
    }
    return _arrowImgView;
}

- (CALayer *)line {
    if (!_line) {
        _line = [CALayer layer];
        _line.backgroundColor = ZFCOLOR(221, 221, 221, 1).CGColor;
    }
    return _line;
}



@end
