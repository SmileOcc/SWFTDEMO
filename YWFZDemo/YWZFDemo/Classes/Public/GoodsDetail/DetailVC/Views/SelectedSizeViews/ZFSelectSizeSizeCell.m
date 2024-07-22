//
//  ZFSelectSizeSizeCell.m
//  ZZZZZ
//
//  Created by YW on 2017/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSelectSizeSizeCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFSelectSizeSizeCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *attrLabel;
@property (nonatomic, strong) CAShapeLayer      *borderLayer;
@property (nonatomic, assign) CGSize            attrSize;
@end

@implementation ZFSelectSizeSizeCell
- (void)prepareForReuse {
    [super prepareForReuse];
    self.attrLabel.text = nil;
}

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.attrLabel];
    [self.attrLabel.layer addSublayer:self.borderLayer];
}

- (void)zfAutoLayoutView {
    self.attrSize = CGSizeMake(48, kSelectSizeItemHeight);
    [self.attrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.centerY.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.attrSize.height);
    }];
}

- (void)updateColorSize:(CGSize)size itmesModel:(ZFSizeSelectItemsModel *)model {
    if (!CGSizeEqualToSize(size, self.attrSize)) {
        self.attrSize = size;
    }
    
    [self.attrLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.centerY.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.attrSize.height);

    }];
    
    self.model = model;
}

#pragma mark - setter
- (void)setModel:(ZFSizeSelectItemsModel *)model {
    _model = model;
    
    self.attrLabel.text = model.attrName;
    self.attrLabel.layer.borderColor = ZFCClearColor().CGColor;
    self.attrLabel.textColor = ZFC0xCCCCCC();

    if (_model.is_click) {//可点击
        self.attrLabel.layer.borderColor = ZFC0xCCCCCC().CGColor;
        self.attrLabel.textColor = ZFC0x2D2D2D();
        if (_model.isSelect) {
            self.attrLabel.textColor = ZFC0x2D2D2D();
            self.attrLabel.layer.borderColor = ZFC0x2D2D2D().CGColor;
            self.attrLabel.layer.borderWidth = 1.5f;
        } else {
            self.attrLabel.layer.borderWidth = 1.f;
        }
        self.borderLayer.hidden = YES;
        
    } else {//不可点击
        
        //设置虚线边框
        self.borderLayer.hidden = NO;
        CGSize textSize = CGSizeMake(_model.width, self.attrSize.height);
        self.borderLayer.bounds = CGRectMake(0, 0, textSize.width, textSize.height); //中心点位置
        self.borderLayer.position = CGPointMake(textSize.width *0.5, textSize.height *0.5);
        self.borderLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, textSize.width, textSize.height)].CGPath;
        self.borderLayer.lineWidth = 1; //边框的宽度
        self.borderLayer.lineDashPattern = @[@(1.5),@(1.5)]; //边框虚线线段的宽度
        self.borderLayer.fillColor = ZFCClearColor().CGColor;
        self.borderLayer.strokeColor = ZFC0xCCCCCC().CGColor;
    }
}

- (CAShapeLayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.hidden = YES;
    }
    return _borderLayer;
}

#pragma mark - getter
- (UILabel *)attrLabel {
    if (!_attrLabel) {
        _attrLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _attrLabel.font = ZFFontSystemSize(14);
        _attrLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1.0);
        _attrLabel.textAlignment = NSTextAlignmentCenter;
        _attrLabel.layer.borderColor = ColorHex_Alpha(0x2D2D2D, 1.0).CGColor;
        _attrLabel.layer.borderWidth = 2.f;
        _attrLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _attrLabel;
}

@end
