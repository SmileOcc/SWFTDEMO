//
//  HomeItemBannerReusableView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeItemsAdvsReusableView.h"

@implementation OSSVHomeItemsAdvsReusableView

+ (OSSVHomeItemsAdvsReusableView*)homeItemHeaderWithCollectionView:(UICollectionView *)collectionView Kind:(NSString*)kind IndexPath:(NSIndexPath *)indexPath {
    
    [collectionView registerClass:[OSSVHomeItemsAdvsReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:@"HomeItemBannerReusableView"];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HomeItemBannerReusableView" forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setBannersArray:(NSArray *)bannersArray {
    if (_bannersArray != bannersArray) {
        _bannersArray = bannersArray;
        [self createBannersView];
    }
}
// 循环创建banner
- (void)createBannersView {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    UIView *tempView;
    for (int i=0; i<self.bannersArray.count; i++) {
        
        OSSVAdvsEventsModel *bannerModel = self.bannersArray[i];
        float bannerH = SCREEN_WIDTH * [bannerModel.height floatValue] / [bannerModel.width floatValue];
        
        BannerItem *item = [[BannerItem alloc] initWithFrame:CGRectZero];
        [item.imgView yy_setImageWithURL:[NSURL URLWithString:bannerModel.imageURL]
                             placeholder:[UIImage imageNamed:@"placeholder_banner_pdf"]
                                 options:kNilOptions
                              completion:nil];
        
        item.tag = 11000 + i;
        [item addTarget:self action:@selector(bannerTouch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:item];
        
        if (tempView) {
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.mas_equalTo(self);
                make.top.mas_equalTo(tempView.mas_bottom).mas_offset(10);
                make.height.mas_equalTo(bannerH);
            }];
            
        } else {
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.mas_equalTo(self);
                make.top.mas_equalTo(self.mas_top);
                make.height.mas_equalTo(bannerH);
            }];
        }
        
        tempView = item;
    }
}

- (void)bannerTouch:(BannerItem *)item {
    NSInteger flag = item.tag - 11000;
    if (self.bannerBlock && self.bannersArray.count > flag) {
        self.bannerBlock(self.bannersArray[flag]);
    }
}

@end


// ====================== Banner图 ========================== //

@implementation BannerItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imgView];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

- (YYAnimatedImageView *)imgView {
    if (!_imgView) {
        _imgView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
    }
    return _imgView;
}

@end
