//
//  ZFCommunityLiveVideoActivityCell.m
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveVideoActivityCCell.h"
#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"

@interface ZFCommunityLiveVideoActivityCCell()

@property (nonatomic, strong) YYAnimatedImageView *imageView;


@end

@implementation ZFCommunityLiveVideoActivityCCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
    return self;
}


- (void)setRedNetModel:(ZFCommunityLiveVideoRedNetModel *)redNetModel {
    _redNetModel = redNetModel;
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:redNetModel.pic_url] placeholder:[UIImage imageNamed:@"community_index_banner_loading"]];
}

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] init];
    }
    return _imageView;
}
@end
