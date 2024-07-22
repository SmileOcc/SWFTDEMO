//
//  ZFGoodsListColorBlockView.m
//  ZZZZZ
//
//  Created by YW on 2019/5/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsListColorBlockView.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "ZFPubilcKeyDefiner.h"
#import "Masonry.h"
#import "ZFColorBlockCell.h"
#import "ZFGoodsModel.h"
#import "Constants.h"
#import <Bugly/Bugly.h>
#import "YWCFunctionTool.h"

@interface ZFGoodsListColorBlockView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>



@end

@implementation ZFGoodsListColorBlockView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.colorBlockCollectionView];
        [self.colorBlockCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 15));
        }];
    }
    return self;
}

- (UICollectionView *)colorBlockCollectionView {
    if (!_colorBlockCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _colorBlockCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _colorBlockCollectionView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        [_colorBlockCollectionView registerClass:[ZFColorBlockCell class] forCellWithReuseIdentifier:kZFCategoryListColorBlockCellIdentifier];
        _colorBlockCollectionView.delegate = self;
        _colorBlockCollectionView.dataSource = self;
        _colorBlockCollectionView.showsHorizontalScrollIndicator = NO;
        _colorBlockCollectionView.showsVerticalScrollIndicator = NO;
        
        if (@available(iOS 11.0, *)) {
            _colorBlockCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _colorBlockCollectionView;
}

#pragma mark CollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.goodsModel.groupGoodsList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFColorBlockCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCategoryListColorBlockCellIdentifier forIndexPath:indexPath];
    if (self.goodsModel.groupGoodsList.count > indexPath.item && self.goodsModel.groupGoodsList.count > self.goodsModel.selectedColorIndex) {
        [cell setModel:self.goodsModel.groupGoodsList[indexPath.item] indexPath:indexPath seletedIndex:self.goodsModel.selectedColorIndex];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = floor((KScreenWidth - 36) * 0.5);
    CGFloat colorBlockCellWidth = floor((cellWidth-12*4-15) / 4.5);
    return CGSizeMake(colorBlockCellWidth, colorBlockCellWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.colorBlockClick) {
        self.colorBlockClick(indexPath.item);
    }
    self.goodsModel.selectedColorIndex = indexPath.item;
    [collectionView reloadData];
}

- (void)setGoodsModel:(ZFGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    [self.colorBlockCollectionView reloadData];
    if (goodsModel.selectedColorIndex > 4 && goodsModel.groupGoodsList.count > goodsModel.selectedColorIndex && [self.colorBlockCollectionView numberOfItemsInSection:0] > goodsModel.selectedColorIndex) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [self.colorBlockCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:goodsModel.selectedColorIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            } @catch (NSException *exception) {
                [Bugly reportExceptionWithCategory:3
                                              name:ZFToString(exception.name)
                                            reason:ZFToString(exception.reason)
                                         callStack:@[]
                                         extraInfo:exception.userInfo
                                      terminateApp:NO];
            } @finally {
                
            }
        });
    }
}

@end
