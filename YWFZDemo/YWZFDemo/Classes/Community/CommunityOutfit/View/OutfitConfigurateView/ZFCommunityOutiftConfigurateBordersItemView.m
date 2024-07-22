//
//  ZFCommunityOutiftConfigurateBordersItemView.m
//  ZZZZZ
//
//  Created by YW on 2019/3/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityOutiftConfigurateBordersItemView.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "Masonry.h"

#import "ZFOutfitBuilderSingleton.h"

#import "ZFOutfitSelectItemCollectionViewCell.h"

#import "ZFCommunityOutfitSelectItemViewModel.h"


@interface ZFCommunityOutiftConfigurateBordersItemView()<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>


@property (nonatomic, strong) UICollectionView                        *collectionView;

@property (nonatomic, strong) ZFCommunityOutfitBorderViewModel        *borderViewModel;

@property (nonatomic, assign) BOOL                                    hadRequest;


@end


@implementation ZFCommunityOutiftConfigurateBordersItemView


- (void)dealloc {
    YWLog(@"--- dealloc: %@",NSStringFromClass(self.class));
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Public Method

- (void)zfViewWillAppear {
    YWLog(@"------  zfViewWillAppear border: %@",self.cateModel.cate_id);
    if (!self.hadRequest) {
        [self.collectionView.mj_header beginRefreshing];
    }
}

- (void)zfReloadView {
    [self.collectionView reloadData];
}

- (void)loadCateGoods:(NSString*)isRefresh {
    
    self.hadRequest = YES;
    @weakify(self);
    [self.borderViewModel requestOutfitBorderCateID:ZFToString(self.cateModel.cate_id) finished:^{
        @strongify(self)
        [self.collectionView reloadData];
        
        NSDictionary *pageData = @{ kTotalPageKey  :@"0",
                                    kCurrentPageKey:@"1" };
        [self.collectionView showRequestTip:pageData isNeedNetWorkStatus:NO];
    }];
}


#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource/UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.borderViewModel.borderArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFOutfitSelectItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFOutfitSelectItemCollectionViewCell" forIndexPath:indexPath];
    
    if (self.borderViewModel.borderArray.count > indexPath.item) {
        
        ZFCommunityOutfitBorderModel *borderModel = self.borderViewModel.borderArray[indexPath.item];
        BOOL isSelect = NO;
        
        if ([ZFOutfitBuilderSingleton shareInstance].borderModel) {
            if ([[ZFOutfitBuilderSingleton shareInstance].borderModel.border_id isEqualToString:borderModel.border_id]) {
                isSelect = YES;
            }
        }
        [cell configDataWithImageURL:ZFToString(borderModel.border_img_url) isSelected:isSelect];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.borderViewModel.borderArray.count > indexPath.item) {
        ZFCommunityOutfitBorderModel *borderModel = self.borderViewModel.borderArray[indexPath.item];
        
        if ([ZFOutfitBuilderSingleton shareInstance].borderModel) {
            if ([[ZFOutfitBuilderSingleton shareInstance].borderModel.border_id isEqualToString:borderModel.border_id]) {
                return;
            }
        }
        ZFOutfitSelectItemCollectionViewCell *cell = (ZFOutfitSelectItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell selectedAnimation];
        
        [ZFOutfitBuilderSingleton shareInstance].borderModel = borderModel;

        [self.collectionView reloadData];

        if (self.selectOutfitBorderBlock) {
            self.selectOutfitBorderBlock(borderModel);
        }
    }
}

#pragma mark - Property Method

- (ZFCommunityOutfitBorderViewModel *)borderViewModel {
    if (!_borderViewModel) {
        _borderViewModel = [[ZFCommunityOutfitBorderViewModel alloc] init];
    }
    return _borderViewModel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat kItemSpace = 12;
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        CGFloat itemWidth = (KScreenWidth - kItemSpace * 4) / 3;
        layout.itemSize   = CGSizeMake(itemWidth, itemWidth);
        layout.minimumLineSpacing      = kItemSpace;
        layout.minimumInteritemSpacing = kItemSpace;
        layout.scrollDirection         = UICollectionViewScrollDirectionVertical;
        layout.sectionInset            = UIEdgeInsetsMake(kItemSpace, kItemSpace, kItemSpace, kItemSpace);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask     = UIViewAutoresizingFlexibleHeight;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate             = self;
        _collectionView.dataSource           = self;
        _collectionView.backgroundColor      = [UIColor clearColor];
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        @weakify(self)
        [_collectionView addCommunityHeaderRefreshBlock:^{
            @strongify(self)
            [self loadCateGoods:Refresh];
        } footerRefreshBlock:^{
            @strongify(self)
            [self loadCateGoods:LoadMore];
        } startRefreshing:NO];
        
        [_collectionView registerClass:[ZFOutfitSelectItemCollectionViewCell class] forCellWithReuseIdentifier:@"ZFOutfitSelectItemCollectionViewCell"];
        
        _collectionView.blankPageViewCenter = CGPointMake(KScreenWidth / 2.0, 110);
    }
    return _collectionView;
}

@end
