//
//  OSSVScrollCCell.m
// OSSVScrollCCell
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVScrollCCell.h"
#import "OSSVPuresImgCCell.h"
#import "OSSVCartGoodsModel.h"

@interface OSSVScrollCCell ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation OSSVScrollCCell
@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;

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
    return [self.datasourceModel.goods_list count] + isMore;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isMoreButton] && indexPath.row == [self.datasourceModel.goods_list count]) {
        OSSVPuresImgCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PureCell" forIndexPath:indexPath];
        cell.advEventModel = self.datasourceModel.end_more;
        cell.size = CGSizeMake(ProductImageWidth, ProductImageHeight);
        return cell;
    }else{
        OSSVPductGoodsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        cell.model = self.datasourceModel.goods_list[indexPath.row];
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ///10 是sectionInset top 10
    float height = collectionView.height - 5;
    return CGSizeMake(ProductImageWidth, height);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_scrollerCollectionViewCell:itemCell:)]) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        [self.delegate stl_scrollerCollectionViewCell:self itemCell:cell];
    }
    if ([self isMoreButton] && indexPath.row == [self.datasourceModel.goods_list count]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(STL_ScrollerCollectionViewCell:didClickMore:)]) {
            [self.delegate STL_ScrollerCollectionViewCell:self didClickMore:self.datasourceModel.end_more];
        }
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_ScrollerCollectionViewCell:didClickProduct:advEventModel:)]) {
        OSSVHomeGoodsListModel *model = self.datasourceModel.goods_list[indexPath.row];
        [self.delegate STL_ScrollerCollectionViewCell:self didClickProduct:model advEventModel:self.datasourceModel.banner];
    }
}

- (BOOL)isMoreEvent:(UICollectionViewCell *)cell {
    if (cell && [cell isKindOfClass:[OSSVPuresImgCCell class]]) {
        return YES;
    }
    return NO;
}

-(BOOL)isMoreButton {
    BOOL isMore = self.datasourceModel.end_more ? YES : NO;
    return isMore;
}

-(void)setModel:(id<CollectionCellModelProtocol>)model {
    _model = model;
    
    if ([_model.dataSource isKindOfClass:[OSSVSecondsKillsModel class]]) {
        self.datasourceModel = (OSSVSecondsKillsModel *)_model.dataSource;
    }
    if ([_model.dataSource isKindOfClass:[OSSVHomeCThemeModel class]]) {
        OSSVSecondsKillsModel *model = [[OSSVSecondsKillsModel alloc] init];
        OSSVHomeCThemeModel *themeModel = (OSSVHomeCThemeModel *)_model.dataSource;
        model.goods_list = themeModel.slideList;
        self.datasourceModel = model;
    }
}

-(UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat padding = 5;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = padding;
        layout.minimumLineSpacing = padding;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(padding, padding, 0, padding);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [OSSVThemesColors stlClearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionView registerClass:[OSSVPductGoodsCCell class] forCellWithReuseIdentifier:@"Cell"];
        [_collectionView registerClass:[OSSVPuresImgCCell class] forCellWithReuseIdentifier:@"PureCell"];
    }
    return _collectionView;
}

@end
