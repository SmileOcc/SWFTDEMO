//
//  OSSVAsinglesAdvCCell.m
// OSSVAsinglesAdvCCell
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
// -----首页以及专题页的 图片

#import "OSSVAsinglesAdvCCell.h"

@interface OSSVAsinglesAdvCCell ()

@property (nonatomic, strong) UIView              *ruleView;
@property (nonatomic, strong) UILabel             *ruleLabel;
@property (nonatomic, strong) UIButton            *ruleButton;
@end

@implementation OSSVAsinglesAdvCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

-(void)dealloc {
    STLLog(@"--- ccc");
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addSubview:self.goodsImageView];
        [self addSubview:self.ruleView];
        [self.ruleView addSubview:self.ruleLabel];
        [self.ruleView addSubview:self.ruleButton];
        
        
        [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self.ruleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(24);
            make.top.mas_equalTo(self.mas_top).offset(10);
            make.trailing.mas_equalTo(self.mas_trailing).offset(12);
        }];
        
        [self.ruleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.ruleView.mas_centerY);
            make.leading.mas_equalTo(self.ruleView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.ruleView.mas_trailing).offset(-24);
        }];
        
        [self.ruleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.ruleView);
        }];
        
    }
    return self;
}

#pragma mark - setter and getter

- (void)setModel:(id<CollectionCellModelProtocol>)model
{
    _model = model;
    
    self.ruleView.hidden = YES;
    
    if ([_model.dataSource isKindOfClass:[OSSVAdvsEventsModel class]]) {
        OSSVAdvsEventsModel *model = (OSSVAdvsEventsModel *)_model.dataSource;
        [self.goodsImageView.imageView yy_setImageWithURL:[NSURL URLWithString:model.imageURL]
                                  placeholder:nil
                                      options:kNilOptions
                                   completion:nil];
    }
    if ([_model.dataSource isKindOfClass:[STLAdvEventSpecialModel class]]) {
        STLAdvEventSpecialModel *model = (STLAdvEventSpecialModel *)_model.dataSource;
        [self.goodsImageView.imageView yy_setImageWithURL:[NSURL URLWithString:model.images]
                                  placeholder:nil
                                      options:kNilOptions
                                   completion:nil];
        
        if (model.hasRule) {
            self.ruleView.hidden = NO;
        }
    }
    
}

-(void)setAdvModel:(STLAdvEventSpecialModel *)model{
    self.ruleView.hidden = YES;
    NSString *str = model.images;
    self.goodsImageView.imageView.yy_imageURL = [NSURL URLWithString:str];
    
    if (model.hasRule) {
        self.ruleView.hidden = NO;
    }
}

- (void)actionRule:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_asingleCCell:contentModel:)]) {
        [self.delegate stl_asingleCCell:self contentModel:self.model.dataSource];
    }
}

#pragma mark - setter

-(STLProductImagePlaceholder *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = ({
            STLProductImagePlaceholder *imageView = [[STLProductImagePlaceholder alloc] init];
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView;
        });
    }
    return _goodsImageView;
}

- (UIView *)ruleView {
    if (!_ruleView) {
        _ruleView = [[UIView alloc] initWithFrame:CGRectZero];
        _ruleView.layer.cornerRadius = 12.0;
        _ruleView.layer.masksToBounds = YES;
        _ruleView.layer.borderColor = [OSSVThemesColors col_CC4337].CGColor;
        _ruleView.layer.borderWidth = 1.0;
        _ruleView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _ruleView;
}

- (UILabel *)ruleLabel {
    if (!_ruleLabel) {
        _ruleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _ruleLabel.font = [UIFont boldSystemFontOfSize:13];
        _ruleLabel.textColor = [OSSVThemesColors col_CC4337];
        
        _ruleLabel.text = STLLocalizedString_(@"Rules>", nil);
    }
    return _ruleLabel;
}

- (UIButton *)ruleButton {
    if (!_ruleButton) {
        _ruleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ruleButton addTarget:self action:@selector(actionRule:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ruleButton;
}
@end
