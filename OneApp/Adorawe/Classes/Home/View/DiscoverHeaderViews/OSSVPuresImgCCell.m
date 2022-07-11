//
//  STLPureImageCCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVPuresImgCCell.h"
#import "UICollectionViewCell+STLExtension.h"
@interface OSSVPuresImgCCell ()

//@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, strong) STLProductImagePlaceholder *imageView;
@end

@implementation OSSVPuresImgCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self.contentView addSubview:self.imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        [self setShadowAndCornerCell];
    }
    return self;
}

-(void)setImageUrl:(NSURL *)imageUrl {
    _imageUrl = imageUrl;
//    @weakify(self)
    [self.imageView.imageView yy_setImageWithURL:_imageUrl
                                      placeholder:nil
                                          options:kNilOptions
                                      completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
//        @strongify(self)
//        self.imageView.grayView.hidden = YES;
    }];
}

-(void)setAdvEventModel:(OSSVAdvsEventsModel *)advEventModel {
    _advEventModel = advEventModel;
//    @weakify(self)
    [self.imageView.imageView yy_setImageWithURL:[NSURL URLWithString:_advEventModel.imageURL]
                                      placeholder:nil
                                          options:kNilOptions
                                       completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
//        @strongify(self)
//        self.imageView.grayView.hidden = YES;
    }];
}

#pragma mark - setter and getter

-(void)setSize:(CGSize)size {
    _size = size;
    
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
    }];
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self);
        make.size.mas_offset(size);
    }];
}

//- (YYAnimatedImageView *)imageView {
//    if (!_imageView) {
//        _imageView = ({
//            YYAnimatedImageView *image = [[YYAnimatedImageView alloc] init];
//            image.backgroundColor = [OSSVThemesColors stlWhiteColor];
//            image;
//        });
//    }
//    return _imageView;
//}

- (STLProductImagePlaceholder *)imageView {
    if (!_imageView) {
        _imageView = ({
            STLProductImagePlaceholder *image = [[STLProductImagePlaceholder alloc] init];
//            image.backgroundColor = [OSSVThemesColors stlWhiteColor];
            image;
        });
    }
    return _imageView;
}


@end
