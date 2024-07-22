//
//  CategoryRefineHeaderView.m
//  ListPageViewController
//
//  Created by YW on 3/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryRefineHeaderView.h"
#import "CategoryRefineDetailModel.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface CategoryRefineHeaderView ()
@property (nonatomic, strong) UILabel           *attriLabel;
@property (nonatomic, strong) UILabel           *selectedLabel;
@property (nonatomic, strong) UIImageView       *arrowImgView;
@property (nonatomic, strong)  CALayer          *line;
@end

@implementation CategoryRefineHeaderView
#pragma mark - Init Method
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureSubViews];
        [self autoLayoutSubViews];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandPropertyTouch)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - Initialize
- (void)configureSubViews {
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self addSubview:self.attriLabel];
    [self addSubview:self.selectedLabel];
    [self addSubview:self.arrowImgView];
    [self.layer addSublayer:self.line];
}

- (void)autoLayoutSubViews {
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
    
    _model.isExpend = !_model.isExpend;
    
    CGFloat angle = _model.isExpend ? -M_PI : 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.arrowImgView.transform =  CGAffineTransformMakeRotation(angle);
    }];
    
    if (self.didSelectRefineSelectInfoViewCompletionHandler) {
        self.didSelectRefineSelectInfoViewCompletionHandler(self.model);
    }
}

#pragma mark - Setter
-(void)setModel:(CategoryRefineDetailModel *)model {
    _model = model;
    self.attriLabel.text = model.name;
    self.selectedLabel.text = [model.selectArray componentsJoinedByString:@","];
    
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
        _selectedLabel.textColor = ZFC0xFE5269();
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
