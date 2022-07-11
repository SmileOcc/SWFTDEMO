//
//  OSSVCheckOutProductListCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCheckOutProductListCell.h"
#import "OSSVCartGoodsModel.h"
#import "OSSVCheckOutOneProductCell.h"

#pragma mark - one product view



#pragma mark - OSSVCheckOutProductListCell

@interface OSSVCheckOutProductListCell ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource
>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation OSSVCheckOutProductListCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *contentView = self.contentView;
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).priorityHigh();
        }];
        
        [contentView addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 12, 0));
            if (APP_TYPE == 3) {
                make.height.mas_offset(72 + 12).priorityHigh();
            } else {
                make.height.mas_offset(96 + 12).priorityHigh();
            }
        }];
        
//        [self addBottomLine:CellSeparatorStyle_LeftRightInset];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([_model isKindOfClass:[OSSVProductListCellModel class]]) {
        OSSVProductListCellModel *model = _model;
        return [model.productList count];
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_model isKindOfClass:[OSSVProductListCellModel class]]) {
        OSSVProductListCellModel *model = _model;
        OSSVCartGoodsModel *goodsModel = model.productList[indexPath.row];
        NSInteger count = model.productList.count;
        if (count == 1) {
            collectionView.scrollEnabled = false;
            OSSVCheckOutOneProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OneCell" forIndexPath:indexPath];
            [cell.iconView yy_setImageWithURL:[NSURL URLWithString:goodsModel.goodsThumb]
                                  placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                      options:kNilOptions
                                   completion:nil];
            cell.titleLabel.text = STLToString(goodsModel.goodsName);
            cell.propertyLabel.text = STLToString(goodsModel.goodsAttr);
            cell.priceLabel.text = STLToString(goodsModel.shop_price_converted);
            cell.countLabel.text = [NSString stringWithFormat:@"x %ld", (long)goodsModel.goodsNumber];
            
            cell.markView.hidden = YES;
            cell.priceLabel.alpha = 1;
            cell.titleLabel.alpha = 1;
            cell.countLabel.alpha = 1;
            if ([goodsModel.shield_status integerValue] == 1) {
                cell.markView.hidden = NO;
                cell.priceLabel.alpha = 0.5;
                cell.titleLabel.alpha = 0.5;
                cell.countLabel.alpha = 0.5;

            }
            return cell;
        }else{
            collectionView.scrollEnabled = true;
            OSSVCheckOutProductCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
            cell.goodsModel = goodsModel;
            cell.markView.hidden = YES;
            if ([goodsModel.shield_status integerValue] == 1) {
                cell.markView.hidden = NO;
            }
            return cell;
        }
    }
    return [UICollectionViewCell new];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_model isKindOfClass:[OSSVProductListCellModel class]]) {
        OSSVProductListCellModel *model = _model;
        if ([model.productList count] == 1) {
            if (APP_TYPE == 3) {
                return CGSizeMake(collectionView.bounds.size.width - 24, 72 + 12);
            } else {
                return CGSizeMake(collectionView.bounds.size.width - 24, 96 + 12);
            }
            
        }else{
            if (APP_TYPE == 3) {
                return CGSizeMake(72, 72 + 12);
            } else {
                return CGSizeMake(72, 96 + 12);
            }
        }
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if ([_model isKindOfClass:[OSSVProductListCellModel class]]) {
        OSSVProductListCellModel *model = _model;
        if ([model.productList count] == 1) {
            return UIEdgeInsetsMake(0, 14, 0, 14);
        }else{
            return UIEdgeInsetsMake(0, 14, 0, 14);
        }
    }
    return UIEdgeInsetsZero;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVProductListCellModel *model = _model;
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_CheckOutProductListDidClickCell:)] && [model.productList count] >= 1) {
        [self.delegate STL_CheckOutProductListDidClickCell:self.model];
    }
}

#pragma mark - setter and getter

-(void)setModel:(OSSVProductListCellModel *)model
{
    _model = model;
    
    [self.collectionView reloadData];
}

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.minimumLineSpacing = 10;
            layout.minimumInteritemSpacing = 10;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.backgroundColor = self.backgroundColor;
            
            [collectionView registerClass:[OSSVCheckOutProductCollectionCell class] forCellWithReuseIdentifier:@"Cell"];
            [collectionView registerClass:[OSSVCheckOutOneProductCell class] forCellWithReuseIdentifier:@"OneCell"];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            
            collectionView;
        });
    }
    return _collectionView;
}

@end
