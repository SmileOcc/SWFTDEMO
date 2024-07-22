

//
//  ZFSubmitReviewAddImageCell.m
//  ZZZZZ
//
//  Created by YW on 2018/3/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSubmitReviewAddImageCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "Masonry.h"

@interface ZFSubmitReviewAddImageCell() <ZFInitViewProtocol>

@property (nonatomic, strong) UIImageView               *imageView;
@property (nonatomic, strong) UIButton                  *deleteButton;
@end

@implementation ZFSubmitReviewAddImageCell
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)deleteButtonAction:(UIButton *)sender {
    if (self.submitReviewDeleteImageCompletionHandler) {
        self.submitReviewDeleteImageCompletionHandler();
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.deleteButton];
}

- (void)zfAutoLayoutView {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsZero);
    }];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(28, 28));
        make.top.trailing.mas_equalTo(self.contentView);
    }];
}

#pragma mark - setter
- (void)setType:(SubmitReviewAddImageType)type {
    _type = type;
    switch (_type) {
        case SubmitReviewAddImageTypeNormal: {
            self.deleteButton.hidden = NO;
        }
            break;
        case SubmitReviewAddImageTypeAdd: {
            self.imageView.image = [UIImage imageNamed:@"camera_review"];
            self.deleteButton.hidden = YES;
        }
            break;
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = _image;
}

#pragma mark - getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_review"]];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"review_delete"] forState:UIControlStateNormal];
        _deleteButton.hidden = YES;
        [_deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

@end
