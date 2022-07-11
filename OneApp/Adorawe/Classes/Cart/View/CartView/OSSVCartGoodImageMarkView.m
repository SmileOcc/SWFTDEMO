//
//  OSSVCartGoodImageMarkView.m
// XStarlinkProject
//
//  Created by odd on 2020/11/8.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCartGoodImageMarkView.h"


@interface OSSVCartGoodImageMarkView()

@property (nonatomic,copy) NSString    *name;

@property (nonatomic, assign) BOOL     showImage;

@property (nonatomic, strong) UILabel   *titleLabel;
@property (nonatomic, strong) YYAnimatedImageView *imageView;

@end
@implementation OSSVCartGoodImageMarkView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors col_0D0D0D:0.3];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.imageView];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(16, 16));
            make.bottom.mas_equalTo(self.titleLabel.mas_top).offset(-4);
        }];
        
    }
    return self;
}

- (void)updateName:(NSString *)name showImage:(BOOL)isShow flashProduct:(BOOL)isFlashProduct{
    self.showImage = isShow;
    self.name = name;
    self.imageView.hidden = !isShow;
    self.titleLabel.text = STLToString(name);
    if (isFlashProduct) {
        self.imageView.image = [UIImage imageNamed:@"soldOut_icon"];
    } else {
        self.imageView.image = [UIImage imageNamed:@"shopBag_yijia"];
    }
    if (!STLIsEmptyString(name) && isShow) {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY).offset(8);
        }];
    } else if(!STLIsEmptyString(name)) {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
    } else if(isShow) {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY).offset(8);
        }];
    }
    
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] initWithImage:nil];
    }
    return _imageView;
}
@end
