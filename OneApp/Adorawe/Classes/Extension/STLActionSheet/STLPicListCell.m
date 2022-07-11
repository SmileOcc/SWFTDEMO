
//
//  STLPicListCell.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLPicListCell.h"


@interface STLPicListCell()


@end

@implementation STLPicListCell

+ (STLPicListCell *)STLPicListCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath{
    [collectionView registerClass:[STLPicListCell class] forCellWithReuseIdentifier:@"STLPicListCell"];
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"STLPicListCell" forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpVivew];
    }
    return self;
}

- (void)setUpVivew{
    [self.contentView addSubview:self.imgV];
    [self.imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (YYAnimatedImageView *)imgV{
    if (!_imgV) {
        _imgV = [YYAnimatedImageView new];
        _imgV.contentMode = UIViewContentModeScaleAspectFit;
        _imgV.layer.masksToBounds = YES;
    }
    return _imgV;
}


- (void)setImgUrlStr:(NSString *)imgUrlStr{
    _imgUrlStr = imgUrlStr;
    [self.imgV yy_setImageWithURL:[NSURL URLWithString:_imgUrlStr] placeholder:[UIImage imageNamed:@"ProductImageLogo"]];
}

- (UIImage *)getImgOfCell{
    UIImage *img = self.imgV.image;
    return img;
}

@end
