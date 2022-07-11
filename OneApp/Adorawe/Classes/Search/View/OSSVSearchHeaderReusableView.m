//
//  OSSVSearchHeaderReusableView.m
// XStarlinkProject
//
//  Created by occ on 10/11/20.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSearchHeaderReusableView.h"

@implementation OSSVSearchHeaderReusableView

+ (OSSVSearchHeaderReusableView *)actionCollectionFooterView:(UICollectionView *)collectionView kind:(NSString*)kind indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[OSSVSearchHeaderReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:@"OSSVSearchHeaderReusableView"];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"OSSVSearchHeaderReusableView" forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.contentLabel];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
    }
    
    return self;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _contentLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    return _contentLabel;
}
@end
