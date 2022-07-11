//
//  OSSVGoodsHistorEmptCollectionReusView.m
// XStarlinkProject
//
//  Created by odd on 2020/8/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVGoodsHistorEmptCollectionReusView.h"

@implementation OSSVGoodsHistorEmptCollectionReusView

+ (OSSVGoodsHistorEmptCollectionReusView*)goodsHistoryHeaderWithCollectionView:(UICollectionView *)collectionView Kind:(NSString*)kind IndexPath:(NSIndexPath *)indexPath {
    
    [collectionView registerClass:[OSSVGoodsHistorEmptCollectionReusView class] forSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass(OSSVGoodsHistorEmptCollectionReusView.class)];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass(OSSVGoodsHistorEmptCollectionReusView.class) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *noDataView = [self makeCustomNoDataView];
        [self addSubview:noDataView];
        [noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.trailing.mas_equalTo(self);
        }];
        
        //occ阿语适配
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            noDataView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return self;
}


#pragma mark make - privateCustomView(NoDataView)
- (UIView *)makeCustomNoDataView {
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectZero];
    customView.backgroundColor = [UIColor whiteColor];
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:@"loading_failed"];
    imageView.userInteractionEnabled = YES;
    [customView addSubview:imageView];

    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(customView.mas_top).offset(52 * DSCREEN_HEIGHT_SCALE);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];

    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = OSSVThemesColors.col_333333;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.text = STLLocalizedString_(@"Sorry_Not_history", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [customView addSubview:titleLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(36);
        make.width.mas_equalTo(SCREEN_WIDTH - 30);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];

//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.backgroundColor = OSSVThemesColors.col_FF9522;
//    button.titleLabel.font = [UIFont systemFontOfSize:14];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button setTitle:STLLocalizedString_(@"retry", nil) forState:UIControlStateNormal];
//    /**
//        emptyOperationTouch
//        emptyJumpOperationTouch
//        暂时两个动态选择
//     */
//    [button addTarget:self action:@selector(emptyOperationTouch) forControlEvents:UIControlEventTouchUpInside];
//    button.layer.cornerRadius = 3;
//    [customView addSubview:button];
//
//    [button mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(titleLabel.mas_bottom).offset(33);
//        make.centerX.mas_equalTo(customView.mas_centerX);
//        make.width.mas_equalTo(@180);
//        make.height.mas_equalTo(@40);
//    }];
    return customView;
}
@end
