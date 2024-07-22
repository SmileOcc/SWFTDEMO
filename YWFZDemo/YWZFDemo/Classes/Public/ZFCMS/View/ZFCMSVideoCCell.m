//
//  ZFCMSVideoCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/9/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSVideoCCell.h"
#import "ZFNetworkManager.h"
#import <Masonry/Masonry.h>
#import <YYWebImage/YYWebImage.h>

@interface ZFCMSVideoCCell ()

@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIImageView *videoImage;

@end

@implementation ZFCMSVideoCCell

+ (ZFCMSVideoCCell *)reusableTextModuleCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.videoImage];
        [self addSubview:self.startButton];

        [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.4);
            make.width.mas_equalTo(self.startButton.mas_height);
        }];
        
        [self.videoImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)playerButtonClick
{
    if (self.CMSCellPlayerVideo) {
        self.CMSCellPlayerVideo(self.itemModel);
    }
}

#pragma mark - Property Method

- (void)setItemModel:(ZFCMSItemModel *)itemModel
{
    _itemModel = itemModel;
    
    [self.videoImage yy_setImageWithURL:[NSURL URLWithString:_itemModel.image]
                                      placeholder:nil//[UIImage imageNamed:@"index_banner_loading"]
                                          options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                         progress:nil
                                        transform:^UIImage *(UIImage *image, NSURL *url) {
                                            return image;
                                        } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                        }];
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"community_home_play_big"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(playerButtonClick) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _startButton;
}

- (UIImageView *)videoImage
{
    if (!_videoImage) {
        _videoImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerButtonClick)];
            [img addGestureRecognizer:tap];
            img;
        });
    }
    return _videoImage;
}

@end
