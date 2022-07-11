//
//  STLProductImagePlaceholder.m
// XStarlinkProject
//
//  Created by Kevin on 2021/6/14.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLProductImagePlaceholder.h"

@interface STLProductImagePlaceholder()

@property (nonatomic, assign) BOOL isCategoryClass;

@end

@implementation STLProductImagePlaceholder

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.grayView];
        [self addSubview:self.imageView];
        [self addSubview:self.placeImageView];
        
        [self.grayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(6);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-6);
            make.top.mas_equalTo(self.mas_top).offset(6);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-6);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(self);
        }];
        
        [self.placeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.equalTo(CGSizeMake(38, 27));
        }];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame isCategory:(BOOL)isCategory {
    if (self = [super initWithFrame:frame]) {
        
        self.isCategoryClass = isCategory;
        
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.grayView];
        [self addSubview:self.imageView];
        [self addSubview:self.placeImageView];
        
        [self.grayView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (self.isCategoryClass) {
                make.leading.mas_equalTo(self.mas_leading);
                make.trailing.mas_equalTo(self.mas_trailing);
                make.top.mas_equalTo(self.mas_top);
                make.bottom.mas_equalTo(self.mas_bottom);

            } else {
                make.leading.mas_equalTo(self.mas_leading).offset(6);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-6);
                make.top.mas_equalTo(self.mas_top).offset(6);
                make.bottom.mas_equalTo(self.mas_bottom).offset(-6);

            }
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(self);
        }];
        
        [self.placeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.equalTo(CGSizeMake(38, 27));
        }];
    }
    
    return self;
}

- (UIView *)grayView {
    if (!_grayView) {
        _grayView = [UIView new];
        _grayView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _grayView;
}

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [YYAnimatedImageView new];
//        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}
- (YYAnimatedImageView *)placeImageView {
    if (!_placeImageView) {
        _placeImageView = [YYAnimatedImageView new];
        _placeImageView.backgroundColor = [UIColor clearColor];
        _placeImageView.hidden = YES;
    }
    return _placeImageView;
}

@end
