//
//  OSSVSearchMatchResultCCell.m
// XStarlinkProject
//
//  Created by occ on 10/11/20.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSearchMatchResultCCell.h"

@interface OSSVSearchMatchResultCCell ()


@end

@implementation OSSVSearchMatchResultCCell

+ (OSSVSearchMatchResultCCell *)attributeCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[OSSVSearchMatchResultCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVSearchMatchResultCCell.class)];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVSearchMatchResultCCell.class) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        }
        [self.contentView addSubview:_titleLabel];
        

        _imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imgView.image = [UIImage imageNamed:@"arrow_beveled"];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_imgView convertUIWithARLanguage];
        }
        [self.contentView addSubview:self.imgView];
        
        
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.mas_equalTo(self.contentView);
            make.trailing.mas_equalTo(self.imgView.mas_leading).offset(-5);
        }];
        
    }
    return self;
}

@end
