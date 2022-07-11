//
//  OSSVCommendFooterView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCommendFooterView.h"
#import "OSSVCommendCell.h"
#import "CommendModel.h"
#import "OSSVDetailsVC.h"

@interface OSSVCommendFooterView ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView       *collectionView;
@property (nonatomic, strong) UILabel                *titleLabel;

@end

@implementation OSSVCommendFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *ws = self;
        
        [ws addSubview:self.titleLabel];
        [ws addSubview:self.collectionView];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.mas_top).offset(16);
            make.leading.mas_equalTo(@10);
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
            make.bottom.mas_equalTo(ws.mas_bottom);
            make.leading.mas_equalTo(ws.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing);
        }];
        
    }
    return self;
}

#pragma mark -
- (void)changeCommendList {
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[OSSVCartsOperateManager sharedManager] commendList].count;
}

// 内容边框
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

// cell 大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(75, collectionView.bounds.size.height);
}

// cell 行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

// cell 列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OSSVCommendCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVCommendCell.class) forIndexPath:indexPath];
    cell.itemModel = [[OSSVCartsOperateManager sharedManager] commendList][indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    CommendModel *model = [[OSSVCartsOperateManager sharedManager] commendList][indexPath.row];
    OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
    goodsDetailsVC.goodsId = model.goodsId;
    goodsDetailsVC.wid = model.wid;
    goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceCartRecommend;
    goodsDetailsVC.coverImageUrl = STLToString(model.goodsThumb);
    [self.viewController.navigationController pushViewController:goodsDetailsVC animated:YES];
}

#pragma mark - LazyLoad

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = STLLocalizedString_(@"mayLike",nil);
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = OSSVThemesColors.col_333333;
    }
    return _titleLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[OSSVCommendCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVCommendCell.class)];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}
@end
