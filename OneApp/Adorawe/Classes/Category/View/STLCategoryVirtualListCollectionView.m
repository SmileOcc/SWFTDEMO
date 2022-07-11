//
//  OSSVCategorysVirtualListsCollectionView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategoryListsCCell.h"
#import "OSSVCategorysVirtualListsCollectionView.h"
#import "OSSVCategorysVirtualAnalyseAP.h"
@interface OSSVCategorysVirtualListsCollectionView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) EmptyCustomViewManager *emptyViewManager;
@property (nonatomic, assign) EmptyViewShowType emptyViewShowType;

@property (nonatomic, strong) OSSVCategorysVirtualAnalyseAP   *categoryListAnalyticsManager;

@end

@implementation OSSVCategorysVirtualListsCollectionView


#pragma mark - public methods

- (void)refreshStart {
    [self.categoryListAnalyticsManager refreshDataSource];
}
- (void)updateData
{
    self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;
    [self reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithFrame:frame collectionViewLayout:layout])
    {
        [[STLAnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.categoryListAnalyticsManager];

        self.dataSource = self;
        self.delegate = self;
        self.emptyDataSetDelegate = self;
        self.emptyDataSetSource = self;
        [self registerClass:[OSSVCategoryListsCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVCategoryListsCCell.class)];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.dataArray.count > 0)//为防万一，APP上拉加载的判断逻辑调整，由之前判定返回的数量<请求的数量即认为无更多商品，改为判断返回的数量=0。
    {
        collectionView.mj_footer.hidden = NO;
    }
    else
    {
        collectionView.mj_footer.hidden = YES;
    }
    return self.dataArray.count;
}

//构建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVCategoryListsCCell *cell = [OSSVCategoryListsCCell categoriesCellWithCollectionView:collectionView andIndexPath:indexPath];
    cell.backgroundColor = STLThemeColor.col_FFFFFF;
    cell.model = self.dataArray[indexPath.row];
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [OSSVCategoryListsCCell categoryListCCellRowHeightForListModel:self.dataArray[indexPath.row]];
    return CGSizeMake(kGoodsWidth, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.myDelegate didDeselectVirtualGoodListModel:self.dataArray[indexPath.row]];
}

#pragma mark - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate


- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    
    self.emptyViewManager.customNoDataView = [self makeCustomNoDataView];
    return [self.emptyViewManager accordingToTypeReBackView:self.emptyViewShowType];
}

#pragma mark - private methods


- (UIView *)makeCustomNoDataView
{
    UIView * customView = [[UIView alloc] initWithFrame:CGRectZero];
    customView.backgroundColor = STLThemeColor.col_FFFFFF;
    
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:@"reviews_bank"];
    [customView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(customView.mas_top).mas_offset(52 * DSCREEN_HEIGHT_SCALE);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = STLThemeColor.col_333333;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.text = STLLocalizedString_(@"load_failed", nil);
    [customView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(36);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(emptyOperationTouch) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [STLThemeColor col_262626];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:STLLocalizedString_(@"refresh", nil) forState:UIControlStateNormal];
    button.layer.cornerRadius = 3;
    [customView addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(33);
        make.centerX.mas_equalTo(customView.mas_centerX);
        make.width.mas_equalTo(@180);
        make.height.mas_equalTo(@40);
    }];
    
    return customView;
}

- (void)emptyOperationTouch
{
    self.emptyOperationBlock();
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 0;
}


- (OSSVCategorysVirtualAnalyseAP *)categoryListAnalyticsManager {
    if (!_categoryListAnalyticsManager) {
        _categoryListAnalyticsManager = [[OSSVCategorysVirtualAnalyseAP alloc] init];
        _categoryListAnalyticsManager.source = STLAppsflyerGoodsSourceCategoryList;
    }
    return _categoryListAnalyticsManager;
}
@end
