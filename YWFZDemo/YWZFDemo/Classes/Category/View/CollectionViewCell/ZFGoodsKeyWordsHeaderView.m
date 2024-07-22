//
//  ZFGoodsKeyWordsHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2018/6/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsKeyWordsHeaderView.h"
#import "ZFGoodsKeywordCollectionViewCell.h"
#import "ZFFrameDefiner.h"

#define kKeywordCellIdentifer   @"kKeywordCellIdentifer"
@interface ZFGoodsKeyWordsHeaderView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *contentCollectionView;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) NSString *selectedKeyword;

@end

@implementation ZFGoodsKeyWordsHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKeyWordsSubviews];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initKeyWordsSubviews];
    }
    return self;
}

- (void)initKeyWordsSubviews {
    self.isSelected = NO;
    self.itemArray = [NSMutableArray new];
    self.contentCollectionView.frame = CGRectMake(0, 0, KScreenWidth, 54);
    [self addSubview:self.contentCollectionView];
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsKeywordCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kKeywordCellIdentifer forIndexPath:indexPath];
    NSString *keyword = [self.itemArray objectAtIndex:indexPath.row];
    BOOL isSelected = indexPath.item == 0 && self.isSelected;
    [cell configDataWithKeyword:keyword isSelected:isSelected];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *keyword = [self.itemArray objectAtIndex:indexPath.row];
    CGSize itemSize   = [keyword sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
    return CGSizeMake(itemSize.width + 24.0, 30.0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedKeyword = [self.itemArray objectAtIndex:indexPath.row];
    if (self.isSelected && indexPath.item == 0) {
        self.isSelected = NO;
    } else {
        self.isSelected = YES;
    }
    
    if (self.selectedKeywordHandle) {
        self.selectedKeywordHandle(self.isSelected ? self.selectedKeyword : @"");
    }
}

#pragma mark - getter/setter
- (UICollectionView *)contentCollectionView {
    if (!_contentCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing          = 12.0f;
        layout.scrollDirection             = UICollectionViewScrollDirectionHorizontal;
        _contentCollectionView             = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _contentCollectionView.backgroundColor                = [UIColor whiteColor];
        _contentCollectionView.showsHorizontalScrollIndicator = NO;
        _contentCollectionView.delegate                       = self;
        _contentCollectionView.dataSource                     = self;
        [_contentCollectionView registerClass:[ZFGoodsKeywordCollectionViewCell class] forCellWithReuseIdentifier:kKeywordCellIdentifer];
    }
    return _contentCollectionView;
}

- (void)setKerwordArray:(NSArray *)kerwordArray {
    _kerwordArray = kerwordArray;
    [self.itemArray removeAllObjects];
    if (self.isSelected) {
        [self.itemArray addObject:self.selectedKeyword];
    }
    [self.itemArray addObjectsFromArray:kerwordArray];
    self.contentCollectionView.frame = CGRectMake(0, 0, KScreenWidth, 54);
    [self layoutIfNeeded];
    [self.contentCollectionView reloadData];
    [self.contentCollectionView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
}

- (void)reset {
    self.isSelected = NO;
    self.selectedKeyword = nil;
}

@end
