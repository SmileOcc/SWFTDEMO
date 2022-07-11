//
//  OSSVSearchRecommendReusltCCell.m
// XStarlinkProject
//
//  Created by occ on 10/11/20.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSearchRecommendReusltCCell.h"

@interface OSSVSearchRecommendReusltCCell ()


@end

@implementation OSSVSearchRecommendReusltCCell

+ (OSSVSearchRecommendReusltCCell *)attributeCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[OSSVSearchRecommendReusltCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVSearchRecommendReusltCCell.class)];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVSearchRecommendReusltCCell.class) forIndexPath:indexPath];
}


+ (CGSize)sizeAttributeContent:(NSString *)content {
    
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:11]};
    CGSize itemSize = [STLToString(content) boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    
    if (itemSize.width <= 60) {
        if ((60 - itemSize.width) >= 20) { //最小宽 60
            itemSize = CGSizeMake(60, 32);
            
        } else { // 在50 - 60之间，加一个间隙
            itemSize = CGSizeMake(itemSize.width + 20, 32);
        }
    } else {
        itemSize = CGSizeMake(itemSize.width + 24, 32);
    }
    
    return itemSize;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:11];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.layer.cornerRadius = 16;
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.textColor = [OSSVThemesColors col_666666];
        _titleLabel.backgroundColor = [OSSVThemesColors col_F5F5F5];
        [self.contentView addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
    return self;
}

@end
