//
//  OSSVThemeGoodsItesRankModuleCCell.m
// OSSVThemeGoodsItesRankModuleCCell
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVThemeGoodsItesRankModuleCCell.h"


@interface OSSVThemeGoodsItesRankModuleCCell ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
STLThemeGoodsRankCCellDelegate
>

@property (nonatomic, strong) OSSVScrollGoodsItesCCellModel          *cellModel;

@property (nonatomic, assign) CGSize                                  itemSize;
@property (nonatomic, assign) CGSize                                  subItemSize;

@end

@implementation OSSVThemeGoodsItesRankModuleCCell


@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;

//默认显示3个+3/4
+ (CGSize)itemSize:(NSInteger)goodsCount{
    
    CGSize size = [OSSVThemeGoodsItesRankModuleCCell subItemSize];
    
    if (goodsCount <= 0) {
        return CGSizeZero;
    }

    
    //子视图 + 12底部间隙
    return CGSizeMake(SCREEN_WIDTH, goodsCount * size.height + 12);
}

+ (CGSize)subItemSize {
    return CGSizeMake(SCREEN_WIDTH, (SCREEN_WIDTH - 24) * 144 / 350.0);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = STLRandomColor();
        
        self.itemSize = CGSizeZero;
        self.subItemSize = CGSizeZero;
        
        self.backgroundColor = [OSSVThemesColors stlClearColor];
        [self addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
        
    }
    return self;
}

#pragma mark - datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceModels.goodsList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVThemeGoodsItesRankCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVThemeGoodsItesRankCCell.class) forIndexPath:indexPath];
    if (self.dataSourceModels.goodsList.count > indexPath.row) {
        id<CollectionCellModelProtocol> model = self.dataSourceModels.goodsList[indexPath.row];
        cell.model = model;
    }
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OSSVThemeGoodsItesRankCCell *cell = (OSSVThemeGoodsItesRankCCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeGoodsRankModuleCCell:selectItemCell:isMore:)]) {
//        BOOL isMore = NO;
//        if (indexPath.row + 1 == 10) {
//            isMore = YES;
//        }
        //暂时没有more
        [self.delegate stl_themeGoodsRankModuleCCell:self selectItemCell:cell isMore:NO];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.subItemSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return CGSizeMake(SCREEN_WIDTH, 12);
}

#pragma mark - STLThemeGoodsRankCCellDelegate

- (void)stl_themeGoodsRankCCell:(OSSVThemeGoodsItesRankCCell *)cell addCart:(STLHomeCGoodsModel *)model {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeGoodsRankCCell:addCart:)]) {
        [self.delegate stl_themeGoodsRankModuleCCell:self selectItemCell:cell addMCart:model];
    }
}

#pragma mark - setter and getter

-(void)setModel:(id<CollectionCellModelProtocol>)model
{
    _model = model;
    
    self.itemSize = CGSizeZero;
    self.subItemSize = CGSizeZero;
    if (model && [model isKindOfClass:[OSSVThemeItemGoodsRanksModuleModel class]]) {
        OSSVThemeItemGoodsRanksModuleModel *blockModel = (OSSVThemeItemGoodsRanksModuleModel *)model;
        self.itemSize = blockModel.size;
        self.subItemSize = blockModel.subItemSize;
    }
    if ([_model.dataSource isKindOfClass:[OSSVHomeCThemeModel class]]) {
        self.cellModel = model;
        self.dataSourceModels = (OSSVHomeCThemeModel *)model.dataSource;
        [self.collectionView reloadData];
    }
}


-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = ({
            CGFloat padding = 12;
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.minimumLineSpacing = 0;
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            //layout.sectionInset = UIEdgeInsetsMake(0, padding, padding, padding);

            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.showsVerticalScrollIndicator = NO;
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.backgroundColor = [UIColor clearColor];
            collectionView.showsHorizontalScrollIndicator = NO;
            
            [collectionView registerClass:[OSSVThemeGoodsItesRankCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVThemeGoodsItesRankCCell.class)];
            
            collectionView;
        });
    }
    return _collectionView;
}

@end
