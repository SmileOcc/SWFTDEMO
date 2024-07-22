//
//  ZFUserSexImageView.m
//  ZZZZZ
//
//  Created by 602600 on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFUserSexImageView.h"
#import "ZFColorDefiner.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"

@interface ZFUserSexImageView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *selectImageView;

@property (nonatomic, strong) UILabel *sexLabel;

@end

@implementation ZFUserSexImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)setSelectViewImageName:(NSString *)imageName text:(NSString *)text {
    self.imageView.image = [UIImage imageNamed:ZFToString(imageName)];
    self.sexLabel.text = ZFToString(text);
}

- (void)resetUI {
    self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    self.selectImageView.image = [UIImage imageNamed:@"sex_selected_no"];
}

- (void)selectUI {
    self.imageView.layer.borderColor = ZFCOLOR(254, 82, 105, 1).CGColor;
    self.selectImageView.image = [UIImage imageNamed:@"sex_selected"];
}

- (void)zfInitView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.imageView];
    [self addSubview:self.sexLabel];
    [self addSubview:self.selectImageView];
}

- (void)zfAutoLayoutView {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(90, 90));
    }];
    
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.sexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageView.mas_bottom).offset(12);
        make.leading.trailing.bottom.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 45;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.borderWidth = 2;
        _imageView.layer.borderColor =  [UIColor clearColor].CGColor;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc] init];
        _selectImageView.image = [UIImage imageNamed:@"sex_selected_no"];
        _selectImageView.userInteractionEnabled = YES;
    }
    return _selectImageView;
}

- (UILabel *)sexLabel {
    if (!_sexLabel) {
        _sexLabel = [[UILabel alloc] init];
        _sexLabel.font = [UIFont systemFontOfSize:14];
        _sexLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _sexLabel.textAlignment = NSTextAlignmentCenter;
        _sexLabel.userInteractionEnabled = YES;
    }
    return _sexLabel;
}

@end
