//
//  STLCartCCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeCartCCell.h"
#import "OSSVPuresImgCCell.h"
#import "OSSVCartGoodsModel.h"
#import "OSSVHomeCartPGoodstCCell.h"

@interface OSSVHomeCartCCell ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) OSSVSecondsKillsModel *datasModel;
@end

@implementation OSSVHomeCartCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

#pragma mark - datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger isMore = [self isMoreButton] ? 1 : 0;
    return [self.datasModel.goods_list count] + isMore;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isMoreButton] && indexPath.row == [self.datasModel.goods_list count]) {
        OSSVPuresImgCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PureCell" forIndexPath:indexPath];
        cell.advEventModel = self.datasModel.end_more;
        cell.size = CGSizeMake(ProductImageWidth, ProductImageHeight);
        return cell;
    }else{
        OSSVHomeCartPGoodstCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        cell.cartGoodsModel = self.datasModel.goods_list[indexPath.row];
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(ProductImageWidth, 90);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isMoreButton] && indexPath.row == [self.datasModel.goods_list count]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(STL_CartCollectionViewCell:didClickMore:)]) {
            [self.delegate STL_CartCollectionViewCell:self didClickMore:self.datasModel.end_more];
        }
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_CartCollectionViewCell:didClickProduct:advEventModel:)]) {
        OSSVCartGoodsModel *model = self.datasModel.goods_list[indexPath.row];
        [self.delegate STL_CartCollectionViewCell:self didClickProduct:model advEventModel:self.datasModel.banner];
    }
}

-(BOOL)isMoreButton {
    BOOL isMore = self.datasModel.end_more ? YES : NO;
    return isMore;
}


-(void)setModel:(id<CollectionCellModelProtocol>)model {
    _model = model;
    
    if ([_model.dataSource isKindOfClass:[NSArray class]]) {
        OSSVSecondsKillsModel *model = [[OSSVSecondsKillsModel alloc] init];
        model.goods_list = (NSArray *)_model.dataSource;
        self.datasModel = model;
        [self.collectionView reloadData];
    }
}

-(UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat padding = 10;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = padding;
        layout.minimumLineSpacing = padding;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(padding, padding, padding, padding);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[OSSVHomeCartPGoodstCCell class] forCellWithReuseIdentifier:@"Cell"];
        [_collectionView registerClass:[OSSVPuresImgCCell class] forCellWithReuseIdentifier:@"PureCell"];
    }
    return _collectionView;
}

@end
