//
//  OSSVTotalDetailCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTotalDetailCell.h"

@interface STLTotalDetailView : UIView
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, assign) BOOL isHighLight;
@property (nonatomic,weak) UILabel *centerLinePrice;
@end

@implementation STLTotalDetailView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.detailLabel];
        [self addSubview:self.priceLabel];
        
        UILabel *centerLineprice = [[UILabel alloc] init];
        [self addSubview:centerLineprice];
        self.centerLinePrice = centerLineprice;
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self);
            make.leading.mas_equalTo(self.mas_leading);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self);
            make.trailing.mas_equalTo(self.mas_trailing);
        }];
        
        [centerLineprice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.priceLabel.mas_leading).offset(-2);
            make.top.bottom.mas_equalTo(self);
        }];
    }
    return self;
}

#pragma mark - setter and getter

-(void)setIsHighLight:(BOOL)isHighLight
{
    _isHighLight = isHighLight;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"test", nil);
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _detailLabel;
}

- (UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"test", nil);
            label.textAlignment = NSTextAlignmentRight;
            label;
        });
    }
    return _priceLabel;
}

@end

#pragma mark - OSSVTotalDetailCell

@interface OSSVTotalDetailCell ()
@property (nonatomic, strong) STLTotalDetailView *detailView;
@end

@implementation OSSVTotalDetailCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *contentView = self.contentView;
   
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).priorityHigh();
        }];
        
        [contentView addSubview:self.detailView];
        [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(contentView.mas_leading).mas_offset(CheckOutCellLeftPadding);
            make.top.bottom.mas_equalTo(contentView);
            make.trailing.mas_equalTo(contentView.mas_trailing).mas_offset(-CheckOutCellLeftPadding);
            make.height.mas_offset(32).priorityHigh();
        }];
    }
    return self;
}

#pragma mark - setter and getter

-(void)setModel:(OSSVTotalDetailCellModel *)model
{
    _model = model;

    self.detailView.detailLabel.text = [NSString stringWithFormat:@"%@ :",model.title];
    self.detailView.priceLabel.attributedText = model.value;
    self.detailView.centerLinePrice.attributedText = model.centerLineValue;
}

-(STLTotalDetailView *)detailView
{
    if (!_detailView) {
        _detailView = [[STLTotalDetailView alloc] init];
    }
    return _detailView;
}

@end
