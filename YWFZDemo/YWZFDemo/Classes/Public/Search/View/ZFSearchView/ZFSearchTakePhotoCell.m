//
//  ZFSearchTakePhotoCell.m
//  ZZZZZ
//
//  Created by YW on 2018/9/26.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFSearchTakePhotoCell.h"
#import <AVFoundation/AVFoundation.h>
#import "ZFCameraButton.h"
#import "UIColor+ExTypeChange.h"
#import "Masonry.h"

@interface ZFSearchTakePhotoCell()
@property (nonatomic, strong) ZFCameraButton *imageViewButton;
@end

@implementation ZFSearchTakePhotoCell

+ (ZFSearchTakePhotoCell *)searchAlbumCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFSearchTakePhotoCell class]  forCellWithReuseIdentifier:NSStringFromClass([ZFSearchTakePhotoCell class])];
    ZFSearchTakePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFSearchTakePhotoCell class]) forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        [self layout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.imageViewButton setCamera];
        });
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.imageViewButton];
}

- (void)layout {
    [self.imageViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    [self.contentView layoutIfNeeded];
}

#pragma mark - getter/setter
- (UIButton *)imageViewButton {
    if (!_imageViewButton) {
        _imageViewButton = [ZFCameraButton buttonWithType:UIButtonTypeCustom];
        _imageViewButton.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.2];
        [_imageViewButton setImage:[UIImage imageNamed:@"search_tool_camera"] forState:UIControlStateNormal];
        _imageViewButton.userInteractionEnabled = NO;
    }
    return _imageViewButton;
}

@end
