//
//  ZFAccountBannerCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/6/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountBannerCCell.h"
#import "ZFBannerModel.h"
#import <YYWebImage/YYWebImage.h>
#import <Masonry/Masonry.h>

@interface ZFAccountBannerCCell ()

@property (nonatomic, strong) YYAnimatedImageView *bannerImage;

@end

@implementation ZFAccountBannerCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bannerImage];
        
        [self.bannerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

#pragma mark - protocol

+ (CGSize)itemSize:(NSInteger)sectionRows protocol:(id<ZFCollectionCellDatasourceProtocol>)protocol
{
    if ([protocol isKindOfClass:[ZFBannerModel class]]) {
        ZFBannerModel *bannerModel = (ZFBannerModel *)protocol;
        CGFloat screenWidth = ([[UIScreen mainScreen] bounds].size.width);
        CGFloat width   = screenWidth / sectionRows;
        CGFloat row_heigth  = width * [bannerModel.banner_height floatValue] / [bannerModel.banner_width floatValue];
        return CGSizeMake(floor(width), floor(row_heigth));
    }
    return CGSizeZero;
}

#pragma mark - Property Method

-(void)setModel:(id<ZFCollectionCellDatasourceProtocol>)model
{
    _model = model;
    
    if ([_model isKindOfClass:[ZFBannerModel class]]) {
        ZFBannerModel *bannerModel = (ZFBannerModel *)_model;
        [self.bannerImage yy_setImageWithURL:[NSURL URLWithString:bannerModel.image]
                           placeholder:[UIImage imageNamed:@"index_banner_loading"]
                               options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                              progress:nil
                             transform:nil
                            completion:nil];
    }
}

- (YYAnimatedImageView *)bannerImage
{
    if (!_bannerImage) {
        _bannerImage = ({
            YYAnimatedImageView *img = [[YYAnimatedImageView alloc] init];
            img;
        });
    }
    return _bannerImage;
}

@end
