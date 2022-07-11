//
//  OSSVCategroysCollectionView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAdvsEventsManager.h"
#import "OSSVCategorysModel.h"
#import "OSSVSecondsCategorysModel.h"
#import "OSSVCategroysCollectionView.h"
#import "OSSVCategoyScrollrViewCCell.h"
#import "OSSVCategoryssCCell.h"
#import "OSSVCategoryCollectionHeadView.h"
#import "OSSVCategoryCollectionFootReusabView.h"
#import "OSSVCategoryssViewsModel.h"

@interface OSSVCategroysCollectionView()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,STLCategoyScrollViewCellDelegate,STLCategoryCollectionHeaderViewDelegate>

//@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation OSSVCategroysCollectionView

#pragma mark - public methods

//- (void)updateDataAtSelectedIndex:(NSInteger)selectedIndex
//{
//    self.selectedIndex = selectedIndex;
//    [self scrollRectToVisible:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) animated:YES];
//    [self reloadData];
//    
//    
//}

- (void)updateSelectCategoryModel:(OSSVCategorysModel *)catgeoryModel {
    if (catgeoryModel) {
        NSInteger startSection = catgeoryModel.startSection;
        NSIndexPath* cellIndexPath = [NSIndexPath indexPathForItem:0 inSection:startSection];

        UICollectionViewLayoutAttributes*attr=[self.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:cellIndexPath];
        UIEdgeInsets insets = self.scrollIndicatorInsets;
        CGRect rect = attr.frame;
        rect.size = self.frame.size;
        rect.size.height -= insets.top + insets.bottom;
        CGFloat offset = (rect.origin.y + rect.size.height) - self.contentSize.height;
        if ( offset > 0.0 ) rect = CGRectOffset(rect, 0, -offset);
        [self scrollRectToVisible:rect animated:YES];
    }
}



- (NSArray *)allCategoryArrays {
    if (!_allCategoryArrays) {
        _allCategoryArrays = @[];
    }
    return _allCategoryArrays;
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithFrame:frame collectionViewLayout:layout])
    {
        self.dataSource = self;
        self.delegate = self;
        [self registerClass:[OSSVCategoryssCCell class] forCellWithReuseIdentifier:@"CategoriesCell"];
        [self registerClass:[OSSVCategoyScrollrViewCCell class] forCellWithReuseIdentifier:@"ScrollCell"];
        [self registerClass:[OSSVCategoryCollectionHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        [self registerClass:[OSSVCategoryCollectionFootReusabView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
        [self registerClass:[UICollectionReusableView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
        [self registerClass:[UICollectionReusableView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
               withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
    }
    return self;
}


#pragma mark    UICollectionViewDataSource UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *allCategorys = self.allCategoryArrays;
    if (allCategorys.count > section) {
        if ([allCategorys[section] isKindOfClass:[OSSVCategorysModel class]]) {
            return 1;
        } else {
            OSSVSecondsCategorysModel *secondCateModel = allCategorys[section];
            
            NSInteger count = secondCateModel.child.count ;
            NSInteger addcount = count % 3;
            if (addcount != 0) {//填充空白cell
                addcount = (3- addcount);
            }
            if (APP_TYPE == 3) {
                addcount = count % 2;
                if (addcount != 0) {//填充空白cell
                    addcount = (2- addcount);
                }
            }
            return count + addcount;
        }
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.allCategoryArrays.count;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.allCategoryArrays.count > indexPath.section) {
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(categoryCollection:willShowCell:forItemAtIndexPath:)]) {
            [self.myDelegate categoryCollection:self willShowCell:cell forItemAtIndexPath:indexPath];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *allCategorys = self.allCategoryArrays;
    
    if (allCategorys.count > indexPath.section) {
        if ([allCategorys[indexPath.section] isKindOfClass:[OSSVCategorysModel class]]) {
            OSSVCategoyScrollrViewCCell *scrollCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ScrollCell" forIndexPath:indexPath];
            scrollCell.categoriesClickDelegate = self;
            OSSVCategorysModel *channelModel = allCategorys[indexPath.section];
            scrollCell.model = channelModel;
            return scrollCell;
        } else {
            OSSVCategoryssCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoriesCell" forIndexPath:indexPath];
            OSSVCatagorysChildModel *childModel = nil;
            OSSVSecondsCategorysModel *sechondCateModel = allCategorys[indexPath.section];
            
            if (sechondCateModel.child.count > indexPath.row) {
                childModel = sechondCateModel.child[indexPath.row];
            }
            
            cell.categoryChildModel = childModel;
            return cell;

        }
    }
    
    OSSVCategoryssCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoriesCell" forIndexPath:indexPath];
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *allCategorys = self.allCategoryArrays;
    if (allCategorys.count > indexPath.section) {
        if ([allCategorys[indexPath.section] isKindOfClass:[OSSVCategorysModel class]]) {
            
            return CGSizeMake([OSSVCategoryssViewsModel secondRangeCollectionWidth],[OSSVCategoyScrollrViewCCell scrollViewContentH:allCategorys[indexPath.section]]);
        }
    }
    CGSize size = [OSSVCategoryssViewsModel cellRangeItemSize];

    return size;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    OSSVSecondsCategorysModel *model;
    NSArray *allCategorys = self.allCategoryArrays;

    if (allCategorys.count > indexPath.section) {
        if (![allCategorys[indexPath.section] isKindOfClass:[OSSVCategorysModel class]]) {
            
            model = allCategorys[indexPath.section];
            
            if (kind == UICollectionElementKindSectionHeader) {
                OSSVCategoryCollectionHeadView *header = [collectionView  dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
                header.categoriesSeeAllDelegate = self;
                OSSVSecondsCategorysModel *model = allCategorys[indexPath.section];
                header.model = model;
                
                  return header;
            }
        }
    }
    
    if (kind == UICollectionElementKindSectionFooter) {

        OSSVCategoryCollectionFootReusabView * footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        footer.whiteSeparateView.hidden = NO;

        if (model && model.isAllCorners) {
            footer.whiteSeparateView.hidden = YES;
        }
        
        return footer;
    }
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
    headerView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    headerView.hidden = YES;
    
    return headerView;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    NSArray *allCategorys = self.allCategoryArrays;
    if (allCategorys.count > section) {
        if ([allCategorys[section] isKindOfClass:[OSSVCategorysModel class]]) {
            return UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
    
    if (APP_TYPE == 3) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return UIEdgeInsetsMake(0, 14, 0, 14);
}



#pragma mark UICollectionViewDelegateFlowLayout 设置每个头的大小

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    NSArray *allCategorys = self.allCategoryArrays;
    if (allCategorys.count > section) {
        if ([allCategorys[section] isKindOfClass:[OSSVCategorysModel class]]) {
            return CGSizeMake(0, 0);
        }
        return CGSizeMake(0, 40);
    }
    
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    if (APP_TYPE == 3) {
        return  CGSizeMake(0, 0);
    }
    NSArray *allCategorys = self.allCategoryArrays;
    if (allCategorys.count > section) {
        if (![allCategorys[section] isKindOfClass:[OSSVCategorysModel class]]) {
            
            OSSVSecondsCategorysModel *model = allCategorys[section];
            if (model.isAllCorners) {
                return CGSizeMake(0, 12);
            } else {
                return CGSizeMake(0, 24);
            }
        }
    }
    return CGSizeMake(0, 0);

//    if (section !=0 && self.dataArray.count > _selectedIndex) {
//        OSSVCategorysModel *channelModel = self.dataArray[_selectedIndex];
//        if (channelModel.category.count > section - 1) {
//
//            OSSVSecondsCategorysModel *model = channelModel.category[section - 1];
//            if (model.child.count > 0) {
//                return CGSizeMake(0, 24);
//            }
//        }
//    } else {
//        return CGSizeMake(0, 0);
//    }
//
//    return CGSizeMake(0, 12);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *allCategorys = self.allCategoryArrays;
    if (allCategorys.count > indexPath.section) {
        if (![allCategorys[indexPath.section] isKindOfClass:[OSSVCategorysModel class]]) {
            OSSVSecondsCategorysModel *model = allCategorys[indexPath.section];
            if (model.child.count > indexPath.row) {
                OSSVCatagorysChildModel *childModel = model.child[indexPath.row];
                if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(categoryCollection:scecondCategory:childModel:)]) {
                    [self.myDelegate categoryCollection:self scecondCategory:model childModel:childModel];
                }
            }

        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(categoryCollection:beginDragging:)]) {
        [self.myDelegate categoryCollection:self beginDragging:YES];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(categoryCollection:scrollEnd:)]) {
        [self.myDelegate categoryCollection:self scrollEnd:YES];
    }
}

#pragma mark -  STLCategoyScrollViewCCellDelegate guide和banner点击事件

- (void)categoriesCell:(OSSVCategoyScrollrViewCCell *)cell advModel:(OSSVAdvsEventsModel *)model isBanner:(BOOL)isBanner {
    
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(categoryCollection:category:bannerGuide:isBanner:)]) {
        [self.myDelegate categoryCollection:self category:cell.model bannerGuide:model isBanner:isBanner];
    }
}

#pragma mark -  STLCategoryCollectionHeaderViewDelegate seeAll点击事件

- (void)categoriesChannelId:(OSSVSecondsCategorysModel *)model cell:(OSSVCategoryCollectionHeadView *)sender
{
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(categoryCollection:scecondCategory:childModel:)]) {
        [self.myDelegate categoryCollection:self scecondCategory:model childModel:nil];
    }
}


@end
