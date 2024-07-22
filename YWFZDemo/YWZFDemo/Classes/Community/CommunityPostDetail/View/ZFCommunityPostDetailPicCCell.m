//
//  ZFCommunityPostDetailPicCCell.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostDetailPicCCell.h"
#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"
#import "Constants.h"

@interface ZFCommunityPostDetailPicCCell ()


@end

@implementation ZFCommunityPostDetailPicCCell

+ (ZFCommunityPostDetailPicCCell *)picCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifer = NSStringFromClass([self class]);
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:cellIdentifer];
    ZFCommunityPostDetailPicCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifer forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        [self layout];
                
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired  = 1;
        
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 1;

        [self.contentView addGestureRecognizer:singleTap];
        [self.contentView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];


    }
    return self;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    YWLog(@"----- handleDoubleTap %lu",(unsigned long)tap.numberOfTouches);
    if (self.picTapBlock) {
        self.picTapBlock(YES);
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    YWLog(@"----- handleSingleTap %lu",(unsigned long)tap.numberOfTouches);
    if (self.picTapBlock) {
        self.picTapBlock(NO);
    }
}


- (void)setupView {
    [self.contentView addSubview:self.imageView];
}

- (void)layout {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.mas_equalTo(self.contentView);
    }];
}

- (void)configWithPicURL:(NSString *)picURL {
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:picURL]
                           placeholder:[UIImage imageNamed:@"community_loading_product"]];
    YWLog(@"-----------ccccc : %@",picURL);
}

- (void)previewImage:(UIImage *)image {
    self.imageView.image = image ? image : [UIImage imageNamed:@"community_loading_product"];
}
#pragma mark - getter/setter
- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end
