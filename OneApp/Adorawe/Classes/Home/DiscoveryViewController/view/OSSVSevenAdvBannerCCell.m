//
//  OSSVSevenAdvBannerCCell.m
// OSSVSevenAdvBannerCCell
//
//  Created by odd on 2020/10/22.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSevenAdvBannerCCell.h"
#import "OSSVMutilBannersCCell.h"
#import "OSSVAdvsEventsModel.h"
#import "UIView+WhenTappedBlocks.h"
@interface OSSVSevenAdvBannerCCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) YYAnimatedImageView *bgImgView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation OSSVSevenAdvBannerCCell
@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        @weakify(self)
        self.contentView.backgroundColor = [UIColor clearColor];
        _bgImgView = [[YYAnimatedImageView alloc] initWithFrame:self.contentView.frame];
        _bgImgView.userInteractionEnabled = YES;
        [_bgImgView whenTapped:^{
	        @strongify(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(STL_HomeBannerCCell:advEventModel:index:)]) {
                [self.delegate STL_HomeBannerCCell:self advEventModel:self.blockModel.banner index:-1];
            }
        }];
        [self.contentView addSubview:_bgImgView];
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        flowLayout.minimumLineSpacing = 10;

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.bgImgView.bounds)-192*kScale_375, SCREEN_WIDTH, 192*kScale_375) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[OSSVMutilBannersCCell class] forCellWithReuseIdentifier:@"STLSevenBannerCollectionViewCell"];
        _collectionView.backgroundColor = [UIColor clearColor];
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
    return self.blockModel.images.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.blockModel.images.count > indexPath.row) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(STL_HomeBannerCCell:advEventModel:showCellIndex:)]) {
            [self.delegate STL_HomeBannerCCell:self advEventModel:self.blockModel.images[indexPath.row] showCellIndex:indexPath.row];
        }
    }
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSVMutilBannersCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STLSevenBannerCollectionViewCell" forIndexPath:indexPath];

    OSSVAdvsEventsModel *model = self.blockModel.images[indexPath.item];
//    @weakify(cell)
    [cell.imageView.imageView yy_setImageWithURL:[NSURL URLWithString:STLToString(model.imageURL)]
                           placeholder:nil
                               options:kNilOptions
                                      completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
//        @strongify(cell)
//        cell.imageView.grayView.hidden = YES;
    }];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OSSVAdvsEventsModel *model = self.blockModel.images[indexPath.item];
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_HomeBannerCCell:advEventModel:index:)]) {
        [self.delegate STL_HomeBannerCCell:self advEventModel:model index:indexPath.row];
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(floor(120*kScale_375), floor(180*kScale_375));
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 12, 12, 12);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0001;
}

-(void)setModel:(id<CollectionCellModelProtocol>)model {
    _model = model;    
    if ([_model.dataSource isKindOfClass:[OSSVDiscoverBlocksModel class]]) {
        OSSVDiscoverBlocksModel *model = (OSSVDiscoverBlocksModel *)_model.dataSource;
        self.blockModel = model;
        NSString *imgUrlStr = STLToString(self.blockModel.banner.imageURL);
        
        [self.bgImgView yy_setImageWithURL:[NSURL URLWithString:imgUrlStr] placeholder:[UIImage imageNamed:@"placeholder_banner_pdf"]];
        [self.collectionView reloadData];
    }
}


@end
