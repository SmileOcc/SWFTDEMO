//
//  OSSVTrackingcRouteccCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTrackingcRouteccCell.h"
#import "OSSVTrackingcMessagecModel.h"

@interface OSSVTrackingcRouteccCell ()

@property (nonatomic, strong) UIView *upLineView;
@property (nonatomic, strong) YYAnimatedImageView *routeSelectImageView;
@property (nonatomic, strong) UIView *downLineView;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIView *underBreakLineView;

@end

@implementation OSSVTrackingcRouteccCell

+ (OSSVTrackingcRouteccCell *)trackingRouteCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [tableView registerClass:[OSSVTrackingcRouteccCell class] forCellReuseIdentifier:NSStringFromClass(OSSVTrackingcRouteccCell.class)];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVTrackingcRouteccCell.class) forIndexPath:indexPath];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _upLineView = [[UIView alloc] init];
        _upLineView.backgroundColor = OSSVThemesColors.col_FFFFFF;
        [self.contentView addSubview:_upLineView];
        [_upLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top);
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(20);
            make.width.mas_equalTo(@1);
            make.height.mas_equalTo(@15);
        }];
        
        _routeSelectImageView = [[YYAnimatedImageView alloc] init];
        _routeSelectImageView.contentMode = UIViewContentModeScaleAspectFill;
        _routeSelectImageView.clipsToBounds = YES;
        _routeSelectImageView.image = [UIImage imageNamed:@"route_circle"];
        [self.contentView addSubview:_routeSelectImageView];
        [_routeSelectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_upLineView.mas_bottom);
            make.centerX.equalTo(_upLineView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(7, 7));
        }];
        
        _downLineView = [[UIView alloc] init];
        _downLineView.backgroundColor = OSSVThemesColors.col_FFFFFF;
        [self.contentView addSubview:_downLineView];
        [_downLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_routeSelectImageView.mas_bottom);
            make.centerX.equalTo(_upLineView.mas_centerX);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.width.mas_equalTo(@1);
        }];
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textColor = OSSVThemesColors.col_999999;
        _detailLabel.font = [UIFont systemFontOfSize:13];
        _detailLabel.numberOfLines = 0;
        [self.contentView addSubview:_detailLabel];
        [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(10);
            make.leading.equalTo(_upLineView.mas_trailing).offset(20);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-20);
        }];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = OSSVThemesColors.col_999999;
        _dateLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:_dateLabel];
        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_detailLabel.mas_bottom).offset(5);
            make.leading.trailing.equalTo(_detailLabel);
        }];
        
        _underBreakLineView = [[UIView alloc] init];
        _underBreakLineView.backgroundColor = OSSVThemesColors.col_F1F1F1;
        [self.contentView addSubview:_underBreakLineView];
        [_underBreakLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_dateLabel.mas_bottom).offset(10);
            make.bottom.trailing.equalTo(self.contentView);
            make.leading.equalTo(_detailLabel.mas_leading);
            make.height.mas_equalTo(@1);
        }];
        
    }
    return self;
}

#pragma mark - 赋值
- (void)setTrackingRouteMessageModel:(OSSVTrackingcMessagecModel *)trackingRouteMessageModel {
    self.dateLabel.text = trackingRouteMessageModel.origin_time;
    self.detailLabel.text = trackingRouteMessageModel.detail;
}

#pragma mark - method
- (void)isNearestRouteCell {
    
    self.upLineView.hidden = YES;
    self.detailLabel.textColor = OSSVThemesColors.col_333333;
    self.dateLabel.textColor = OSSVThemesColors.col_333333;
    self.routeSelectImageView.image = [UIImage imageNamed:@"tracking_route_select"];
    [self.routeSelectImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];


}
- (void)isFarthestRouteCell {
    
    self.downLineView.hidden = YES;
}

/**
 *  此处待优化
 */

- (void)prepareForReuse {
    [super prepareForReuse];
    self.upLineView.hidden = NO;
    self.downLineView.hidden = NO;
    self.routeSelectImageView.image = [UIImage imageNamed:@"route_circle"];
    self.detailLabel.textColor = OSSVThemesColors.col_999999;
}

@end
