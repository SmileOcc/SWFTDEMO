//
//  OSSVSearchMatchResultView.m
// XStarlinkProject
//
//  Created by odd on 2020/9/28.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSearchMatchResultView.h"
#import "OSSVSearchMatchResultCCell.h"
#import "OSSVSearchRecommendReusltCCell.h"
#import "OSSVSearchHeaderReusableView.h"

#import "UICollectionViewLeftAlignedLayout.h"
#import "UICollectionViewRightAlignedLayout.h"

static NSString *const kSearchResultMatchTableViewCellIdentifier = @"kSearchResultMatchTableViewCellIdentifier";

@interface OSSVSearchMatchResultView() <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView          *collectView;
@property (nonatomic, strong) UIView                *maskView;
/// 关联结果词与历史搜索重复的词
@property (nonatomic, strong) NSMutableArray        *repeatArray;

@end

@implementation OSSVSearchMatchResultView

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = STLRandomColor();
        self.matchResult = [[NSArray alloc] init];
        self.recommendArray = [[NSArray alloc] init];
        [self stlInitView];
        [self stlAutoLayoutView];
    }
    return self;
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.recommendArray.count > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0 && self.recommendArray.count > 0) {
        return self.recommendArray.count;
    }
    
    return self.matchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.recommendArray.count > indexPath.row) {
        OSSVSearchRecommendReusltCCell *cell = [OSSVSearchRecommendReusltCCell attributeCellWithCollectionView:collectionView indexPath:indexPath];
        
        STLSearchAssociateCatModel *catModel = self.recommendArray[indexPath.row];
        cell.titleLabel.text = STLToString(catModel.cat_name);
        return cell;
    }
    OSSVSearchMatchResultCCell *cell = [OSSVSearchMatchResultCCell attributeCellWithCollectionView:collectionView indexPath:indexPath];
    
    if (self.matchResult.count > 0) {
        STLSearchAssociateGoodsModel *goodsModel = self.matchResult[indexPath.row];
        
        
        cell.titleLabel.attributedText = nil;
        if (STLToString(self.searchKey).length > 0) {
            
            NSMutableAttributedString *contentStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", STLToString(goodsModel.goods_title)]];
            NSRange colorRange = [[contentStr.string lowercaseString] rangeOfString:[STLToString(self.searchKey) lowercaseString]];
            
            if (colorRange.location != NSNotFound) {
                [contentStr addAttributes:@{NSForegroundColorAttributeName : [OSSVThemesColors col_999999]} range:colorRange];
            }
            
            cell.titleLabel.attributedText = contentStr;
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (indexPath.section == 0 && self.recommendArray.count > indexPath.row) {
//        OSSVSearchRecommendReusltCCell *cell = [OSSVSearchRecommendReusltCCell attributeCellWithCollectionView:collectionView indexPath:indexPath];
//        
//        STLSearchAssociateCatModel *catModel = self.recommendArray[indexPath.row];
//    }
//    
//    if (self.matchResult.count > 0) {
//        STLSearchAssociateGoodsModel *goodsModel = self.matchResult[indexPath.row];
//    }

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        if (indexPath.section == 0 && self.recommendArray.count > 0) {
            OSSVSearchHeaderReusableView *footerView = [OSSVSearchHeaderReusableView actionCollectionFooterView:collectionView kind:kind indexPath:indexPath];
            footerView.contentLabel.text = STLLocalizedString_(@"category", nil);
            return footerView;
        }
    }

    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
    headerView.backgroundColor = OSSVThemesColors.col_F1F1F1;
    headerView.hidden = YES;
    
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.searchMatchResultSelectCompletionHandler) {
        
        if (indexPath.section == 0 && self.recommendArray.count > indexPath.row) {
            STLSearchAssociateCatModel *catModel = self.recommendArray[indexPath.row];
            self.searchMatchResultSelectCompletionHandler(catModel, nil);
        } else if (self.matchResult.count > indexPath.row){
            STLSearchAssociateGoodsModel *goodsModel = self.matchResult[indexPath.row];
            self.searchMatchResultSelectCompletionHandler(nil, goodsModel);
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.searchMatchCloseKeyboardCompletionHandler) {
        self.searchMatchCloseKeyboardCompletionHandler();
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if (section == 0 && self.recommendArray.count > 0) {
        return UIEdgeInsetsMake(1, 12, 10, 12);
    }
    return UIEdgeInsetsMake(1, 12, 0, 12);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    if (section == 0 && self.recommendArray.count > 0) {
        return CGSizeMake(SCREEN_WIDTH, 40);
    }
    return CGSizeMake(SCREEN_WIDTH, 12);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize itemSize = CGSizeZero;
    if (indexPath.section == 0 && self.recommendArray.count > 0) {
        
        if (self.recommendArray.count > indexPath.row) {
            STLSearchAssociateCatModel *catModel = self.recommendArray[indexPath.row];
            itemSize = [OSSVSearchRecommendReusltCCell sizeAttributeContent:STLToString(catModel.cat_name)];
        }
        
        return itemSize;
    }
    
    itemSize = CGSizeMake(SCREEN_WIDTH - 24, 44);
    return itemSize;
}

#pragma mark - <STLInitViewProtocol>
- (void)stlInitView {
    //self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.maskView];
    [self addSubview:self.collectView];
}

- (void)stlAutoLayoutView {
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];
    
    [self.collectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - setter
- (void)setSearchKey:(NSString *)searchKey {
    _searchKey = searchKey;
}

- (void)setMatchResult:(NSArray *)matchResult {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:matchResult];
//    [self.repeatArray removeAllObjects];
//    //  找出历史搜索与关联词相同的词，并放到关联词的前面
//    for (int i = (int)self.recommendArray.count - 1; i >= 0; i --) {
//        NSString *keyword = STLToString(self.recommendArray[i]);
//        if ([tempArray containsObject:keyword.lowercaseString]) {
//            [tempArray removeObject:keyword.lowercaseString];
//            [tempArray insertObject:keyword.lowercaseString atIndex:0];
//            [self.repeatArray addObject:keyword.lowercaseString];
//        }
//    }
    
    _matchResult = tempArray;
    if (_matchResult.count > 0) {
        self.collectView.hidden = NO;
        [self.collectView reloadData];
    } else {
        [self.collectView reloadData];
    }
}

#pragma mark - getter
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        @weakify(self);
        [_maskView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.searchMatchHideMatchViewCompletionHandler) {
                self.searchMatchHideMatchViewCompletionHandler();
            }
        }];
    }
    return _maskView;
}

- (UICollectionView *)collectView {
    if (!_collectView) {
        UICollectionViewFlowLayout *layout;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            layout = [[UICollectionViewRightAlignedLayout alloc] init];
        } else {
            layout = [[UICollectionViewLeftAlignedLayout alloc] init];
        }
        _collectView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectView.backgroundColor = OSSVThemesColors.col_FFFFFF;
        _collectView.dataSource = self;
        _collectView.delegate = self;
        
        [_collectView registerClass:[UICollectionReusableView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
        [_collectView registerClass:[UICollectionReusableView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
               withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
    }
    return _collectView;
}

- (NSMutableArray *)repeatArray {
    if (!_repeatArray) {
        _repeatArray = [NSMutableArray array];
    }
    return _repeatArray;
}

@end
