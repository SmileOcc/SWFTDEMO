//
//  STLDiscoveryJustForYouView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeRecomdJustYouView.h"

@interface OSSVHomeRecomdJustYouView ()

@property (nonatomic, strong) UILabel *centerTitleLabel;
@property (nonatomic, strong) UIView  *leftLineView;
@property (nonatomic, strong) UIView  *rightLineView;

@end

@implementation OSSVHomeRecomdJustYouView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
       
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.centerTitleLabel];
        [self addSubview:self.leftLineView];
        [self addSubview:self.rightLineView];


        CGFloat textWith = [self.centerTitleLabel.text
                            boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 40)
                            options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
                            context:nil].size.width + 10;
        [self.centerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.width.mas_equalTo(textWith);
            make.top.bottom.equalTo(@(0));
        }];
        
        [self.leftLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.centerTitleLabel.centerY);
            make.trailing.equalTo(self.centerTitleLabel.mas_leading).offset(-7);
            make.size.mas_equalTo(CGSizeMake(40, 1));
        }];
        
        [self.rightLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.centerTitleLabel.centerY);
            make.leading.equalTo(self.centerTitleLabel.mas_trailing).offset(7);
            make.size.mas_equalTo(CGSizeMake(40, 1));
        }];

    }
    return self;
}

#pragma mark - LazyLoad

- (UILabel *)centerTitleLabel {
    if (!_centerTitleLabel) {
        _centerTitleLabel = [[UILabel alloc] init];
        _centerTitleLabel.textColor = OSSVThemesColors.col_333333;
        _centerTitleLabel.text = STLLocalizedString_(@"Recommendations", nil);
        _centerTitleLabel.textAlignment = NSTextAlignmentCenter;
        _centerTitleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _centerTitleLabel;
}

- (UIView *)leftLineView {
    if (!_leftLineView) {
        _leftLineView = [[UIView alloc] init];
        _leftLineView.backgroundColor = OSSVThemesColors.col_333333;
    }
    return _leftLineView;
}

- (UIView *)rightLineView {
    if (!_rightLineView) {
        _rightLineView = [[UIView alloc] init];
        _rightLineView.backgroundColor = OSSVThemesColors.col_333333;
    }
    return _rightLineView;
}
@end
