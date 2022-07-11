//
//  OSSVTrackingcRoutecHeadView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTrackingcRoutecHeadView.h"

@interface OSSVTrackingcRoutecHeadView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *trackingNumberLabel;

@end

@implementation OSSVTrackingcRoutecHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(SCREEN_WIDTH);
            make.height.mas_offset(70);
        }];
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *topLineView = [UIView new];
        topLineView.backgroundColor = OSSVThemesColors.col_F1F1F1;
        [self addSubview:topLineView];
        [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.trailing.leading.equalTo(@0);
            make.height.mas_equalTo(@1);
        }];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        }
        [self addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topLineView.mas_bottom).offset(16);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(15);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-20);
            make.height.mas_offset(15);
        }];
        
        _trackingNumberLabel = [[UILabel alloc] init];
        _trackingNumberLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:_trackingNumberLabel];
        
        [_trackingNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel.mas_bottom);
            make.trailing.leading.equalTo(_titleLabel);
        }];
        
        UIView *bottomLineView = [UIView new];
        bottomLineView.backgroundColor = OSSVThemesColors.col_F1F1F1;
        [self addSubview:bottomLineView];
        [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_trackingNumberLabel.mas_bottom).offset(7);
            make.bottom.trailing.leading.equalTo(@0);
            make.height.mas_equalTo(@1);
        }];
    }
    return self;
    
}

- (void)setTitleString:(NSString *)titleString trackingNumber:(NSString *)trackingNumber {
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@：%@ ",STLLocalizedString_(@"shipMethod", nil), titleString];
    self.trackingNumberLabel.text = [NSString stringWithFormat:@"%@：%@", STLLocalizedString_(@"TrackingNo", nil), trackingNumber];
    
//    self.trackingNumberLabel.text = [OSSVSystemsConfigsUtils isRightToLeftShow] ? [NSString stringWithFormat:@"%@ :%@",trackingNumber,STLLocalizedString_(@"TrackingNo", nil)] : [NSString stringWithFormat:@"%@: %@",STLLocalizedString_(@"TrackingNo", nil),trackingNumber];
}


@end
