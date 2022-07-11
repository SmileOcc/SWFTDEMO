//
//  OSSVScrollAdvBannerCCell.m
// OSSVScrollAdvBannerCCell
//
//  Created by odd on 2020/10/22.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVScrollAdvBannerCCell.h"
#import "OSSVScrollAdvCCellModel.h"
#import "OSSVScrollAdvsConfigsModel.h"

@interface OSSVScrollAdvBannerCCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *slideImgArray;

@property (nonatomic, weak) YYAnimatedImageView *backgroundImageView;
@end
@implementation OSSVScrollAdvBannerCCell
@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _slideImgArray = [NSMutableArray array];
        ///1.3.8
        self.backgroundColor = [UIColor whiteColor];
        YYAnimatedImageView *bgImage = [[YYAnimatedImageView alloc] init];
        [self.contentView addSubview:bgImage];
        [bgImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        _backgroundImageView = bgImage;
        bgImage.contentMode = UIViewContentModeScaleAspectFill;
        bgImage.clipsToBounds = YES;
        bgImage.layer.masksToBounds = YES;
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 116*kScale_375) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[OSSVScrollAdverCCell class] forCellWithReuseIdentifier:@"STLScrollBannerCollectionViewCell"];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.minimumZoomScale = 0;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        
    }
    return _collectionView;
}
#pragma mark --UICollectionDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.slideImgArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_HomeBannerCCell:advEventModel:showCellIndex:)]) {
        OSSVAdvsEventsModel *model = self.slideImgArray[indexPath.item];
        [self.delegate STL_HomeBannerCCell:self advEventModel:model showCellIndex:indexPath.row];
        
    }
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSVScrollAdverCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STLScrollBannerCollectionViewCell" forIndexPath:indexPath];
    OSSVAdvsEventsModel *model = self.slideImgArray[indexPath.item];
    [cell.imgView yy_setImageWithURL:[NSURL URLWithString:STLToString(model.imageURL)]
                              placeholder:[UIImage imageNamed:@"scrollerBanner"]
                                  options:kNilOptions
                                    completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
    }];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OSSVAdvsEventsModel *model = self.slideImgArray[indexPath.item];
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_HomeBannerCCell:advEventModel:index:)]) {
        [self.delegate STL_HomeBannerCCell:self advEventModel:model index:indexPath.row];
    }

}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(floor(84*kScale_375), floor(116*kScale_375));
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // UIEdgeInsets insets = {top, left, bottom, right};
    return UIEdgeInsetsMake(0, 0, 0, 12);
}
///如果不加这个，cell之间有间隙
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.00001;
}
-(void)setModel:(id<CollectionCellModelProtocol>)model {
    
    ///1.3.8
    //TODO 根据后台返回数据设置背景
    if ([model isKindOfClass:OSSVScrollAdvCCellModel.class]) {
        OSSVScrollAdvsConfigsModel *config = ((OSSVScrollAdvCCellModel*)model).backgroundConfig.firstObject;
        if (config) {
            NSURL *bgImageURL = [NSURL URLWithString:config.image_url];
            if (bgImageURL && config.image_url.length) {
                self.backgroundImageView.yy_imageURL = bgImageURL;
            }else{
                if (config.banner_background_colour.length > 0) {
                    self.backgroundColor = [UIColor colorWithHexString:config.banner_background_colour];
                }
            }
        }else{
            self.backgroundColor = [UIColor whiteColor];
        }
    }
    _model = model;
    if ([_model.dataSource isKindOfClass:[NSArray class]]) {
        NSArray *list = (NSArray *)model.dataSource;
        NSMutableArray *slideBannerArray = [[NSMutableArray alloc] init];
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[OSSVAdvsEventsModel class]]) {*stop = YES;}
            OSSVAdvsEventsModel *model = obj;
            [slideBannerArray addObject:model];
        }];
        [self.slideImgArray removeAllObjects];
        [self.slideImgArray addObjectsFromArray:slideBannerArray];
        [self.collectionView reloadData];
    }
}

@end

