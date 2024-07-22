//
//  ZFReviewPhotoBrowseView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFReviewPhotoBrowseView.h"
#import "ZFReviewPhotoBrowseCell.h"
#import "Masonry.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFInitViewProtocol.h"
#import "GoodsDetailFirstReviewModel.h"
#import "UIView+LayoutMethods.h"
#import "ZFAnalytics.h"
#import "NSStringUtils.h"

#define kReviewTextViewHeight   (80.0)

static NSString *const kZFReviewPhotoBrowseCellIdentifier = @"kZFReviewPhotoBrowseCellIdentifier";

@interface ZFReviewPhotoBrowseView() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate>
@property (nonatomic, strong) NSMutableArray<NSString *>    *imageUrlArray;
@property (nonatomic, strong) NSMutableArray<NSString *>    *reviewTextArray;

@property (nonatomic, strong) UIButton                      *closeButton;
@property (nonatomic, strong) UIButton                      *pageButton;
@property (nonatomic, strong) UIView                        *topBgView;

@property (nonatomic, strong) UIView                        *gradientBgView;
@property (nonatomic, strong) UITextView                    *reviewTextView;
@property (nonatomic, assign) BOOL                          hasHidenToolView;

@property (nonatomic, strong) UICollectionViewFlowLayout    *flowLayout;
@property (nonatomic, strong) UICollectionView              *collectionView;
@property (nonatomic, strong) NSMutableArray                *hasRequestPageIndexArr;
@property (nonatomic, assign) NSInteger                     currentIndexPage;
@property (nonatomic, assign) CGPoint                       gestureBeginPoint;
@property (nonatomic, assign) double                        beginShowTime;
@end

@implementation ZFReviewPhotoBrowseView

#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageUrlArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFReviewPhotoBrowseCell *showsCell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFReviewPhotoBrowseCellIdentifier forIndexPath:indexPath];
    showsCell.imageurl = self.imageUrlArray[indexPath.row];
    @weakify(self)
    showsCell.tapImageBlock = ^{
        @strongify(self)
        [self convertShowToolBar];
    };
    return showsCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(KScreenWidth, KScreenHeight);
}

#pragma mark - setter

- (void)setReviewBrowseData:(NSArray<NSString *> *)imageUrlArray
                 reviewText:(NSArray<NSString *> *)reviewTextArray
                currentPage:(NSInteger)currentPage
               isAppendData:(BOOL)isAppendData
{
    self.beginShowTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
    
    if (isAppendData) {
        [self appendReviewData:imageUrlArray reviewTextData:reviewTextArray];
        return;
    }
    [self layoutIfNeeded];
    [self showBrowseViewWithAnimation:YES];
    [self.hasRequestPageIndexArr removeAllObjects];
    
    self.imageUrlArray = [NSMutableArray arrayWithArray:imageUrlArray];
    self.reviewTextArray = [NSMutableArray arrayWithArray:reviewTextArray];
    
    if (self.reviewTextArray.count > currentPage) {
        self.reviewTextView.text = ZFToString(self.reviewTextArray[currentPage]);
    }
    [self.collectionView reloadData];
    
    NSString *pageString = @"1";
    if (self.imageUrlArray.count > currentPage) {
        //[self.collectionView layoutIfNeeded];
        [self.collectionView setContentOffset:CGPointMake(KScreenWidth * currentPage, 0)];
        pageString = [NSString stringWithFormat:@"%ld/%lu",(long)(currentPage+1) ,(unsigned long)self.imageUrlArray.count];
    }
    [self.pageButton setTitle:pageString forState:UIControlStateNormal];
    self.currentIndexPage = currentPage + 1;
    if (self.refreshStatusBarBlock) {
        self.refreshStatusBarBlock(YES);
    }
}

- (void)appendReviewData:(NSArray<NSString *> *)imageUrlArray
          reviewTextData:(NSArray<NSString *> *)reviewTextArray
{
    [self.imageUrlArray addObjectsFromArray:imageUrlArray];
    [self.reviewTextArray addObjectsFromArray:reviewTextArray];
    [self.collectionView reloadData];
    NSString *pageString = [NSString stringWithFormat:@"%ld/%lu", self.currentIndexPage, (unsigned long)self.imageUrlArray.count];
    [self.pageButton setTitle:pageString forState:UIControlStateNormal];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentIndex = floorf(scrollView.contentOffset.x / KScreenWidth);
    if (currentIndex < 0) return;
    NSString *indexString = [NSString stringWithFormat:@"%ld/%lu",(long)(currentIndex+1) ,(unsigned long)self.imageUrlArray.count];
    [self.pageButton setTitle:indexString forState:UIControlStateNormal];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UITextView class]]) return;
    NSInteger currentIndex = floorf(scrollView.contentOffset.x / KScreenWidth);
    if (currentIndex < 0) return;
    
    NSInteger allCount = self.imageUrlArray.count;
    
    if ((allCount-2) == currentIndex) {
        YWLog(@"显示到 倒数两页就请求下一页===%ld===%ld",allCount-2 ,(long)currentIndex);
        if (![self.hasRequestPageIndexArr containsObject:@(currentIndex)]) {
            [self.hasRequestPageIndexArr addObject:@(currentIndex)];
            if (self.hasShowLastPageBlock) {
                self.hasShowLastPageBlock();
            }
        }
    }
    if (self.reviewTextArray.count > currentIndex) {
        self.reviewTextView.text = ZFToString(self.reviewTextArray[currentIndex]);
    }
    NSString *indexString = [NSString stringWithFormat:@"%ld/%lu",(long)(currentIndex+1) ,(unsigned long)allCount];
    [self.reviewTextView setContentOffset:CGPointMake(0, 0) animated:NO];
    [self.pageButton setTitle:indexString forState:UIControlStateNormal];
    self.currentIndexPage = currentIndex + 1;
}

#pragma mark -Animation

- (void)convertShowToolBar {
    static BOOL animationing = NO;
    if (animationing) return;
    animationing = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.gradientBgView.alpha = self.hasHidenToolView ? 1.0 : 0.0;
        self.topBgView.alpha = self.hasHidenToolView ? 1.0 : 0.0;
        
    } completion:^(BOOL finished) {
        animationing = NO;
        self.hasHidenToolView = !self.hasHidenToolView;
    }];
}

- (void)showBrowseViewWithAnimation:(BOOL)isShow {
    [self.topBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        if (isShow) {
            make.top.mas_equalTo(self.mas_top);
        } else {
            make.bottom.mas_equalTo(self.mas_top);
        }
    }];
    [self.gradientBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo((kReviewTextViewHeight + (IPHONE_X_5_15 ? 34 : 12)));
        if (isShow) {
            make.bottom.mas_equalTo(self.mas_bottom);
        } else {
            make.top.mas_equalTo(self.mas_bottom);
        }
    }];
    if (isShow) {
        self.alpha = 1.0;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.gradientBgView.alpha = 1.0;
        self.topBgView.alpha = 1.0;
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        if (!isShow) {
            [UIView animateWithDuration:0.5 animations:^{
                self.alpha = 0.0;
            }];
        }
    }];
}

- (void)swipeGestureAction:(UISwipeGestureRecognizer *)swipeGesture {
    [self.topBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_top);
    }];
    [self.gradientBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo((kReviewTextViewHeight + (IPHONE_X_5_15 ? 34 : 12)));
        make.top.mas_equalTo(self.mas_bottom);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.refreshStatusBarBlock) {
            self.refreshStatusBarBlock(NO);
        }
    }];
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor clearColor];
                         self.collectionView.backgroundColor = [UIColor clearColor];
                         self.collectionView.top = KScreenHeight;
                         
                     } completion:^(BOOL finished) {
                         self.collectionView.top = 0;
                         self.alpha = 0.0;
                         self.backgroundColor = [UIColor blackColor];
                         self.collectionView.backgroundColor = [UIColor blackColor];
                         [self analyticsPageShowTime];
                     }];
}

- (void)dismissSelfView {
    [self showBrowseViewWithAnimation:NO];
    if (self.refreshStatusBarBlock) {
        self.refreshStatusBarBlock(NO);
    }
    [self analyticsPageShowTime];
}

- (void)analyticsPageShowTime {
    double currentTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
    double showTime = currentTime - self.beginShowTime;
    [ZFAnalytics logSpeedWithCategory:@"App_Cost_Time"
                            eventName:@"Product_Review_List"
                             interval:showTime
                                label:@"Product_Review_List"];
}

#pragma mark - <UITextViewDelegate>

// 禁止弹出复制, 放大, 等操作
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return NO;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = [UIColor blackColor];
    [self addSubview:self.collectionView];
    
    [self addSubview:self.topBgView];
    [self.topBgView addSubview:self.pageButton];
    [self.topBgView addSubview:self.closeButton];
    
    [self addSubview:self.gradientBgView];
    [self.gradientBgView addSubview:self.reviewTextView];
}

- (void)zfAutoLayoutView {
    [self.topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_top);
    }];
    
    [self.pageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topBgView.mas_leading).offset(16);
        make.top.mas_equalTo(self.topBgView.mas_top).offset(40);
        make.height.mas_equalTo(24);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.topBgView.mas_trailing).offset(-16);
        make.centerY.mas_equalTo(self.pageButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.bottom.mas_equalTo(self.topBgView.mas_bottom);
    }];
    
//    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsZero);
//    }];
    
    [self.gradientBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo((kReviewTextViewHeight + (IPHONE_X_5_15 ? 34 : 12)));
        make.top.mas_equalTo(self.mas_bottom);
    }];
    
    [self.reviewTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.gradientBgView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.gradientBgView.mas_trailing).offset(-8);
        make.top.mas_equalTo(self.gradientBgView.mas_top).offset(5);
        make.height.mas_equalTo(kReviewTextViewHeight);
    }];
}

#pragma mark - getter
- (NSMutableArray *)hasRequestPageIndexArr {
    if (!_hasRequestPageIndexArr) {
        _hasRequestPageIndexArr = [NSMutableArray array];
    }
    return _hasRequestPageIndexArr;
}

- (NSMutableArray<NSString *> *)imageUrlArray {
    if (!_imageUrlArray) {
        _imageUrlArray = [NSMutableArray array];
    }
    return _imageUrlArray;
}

- (NSMutableArray<NSString *> *)reviewTextArray {
    if (!_reviewTextArray) {
        _reviewTextArray = [NSMutableArray array];
    }
    return _reviewTextArray;
}

- (UIButton *)pageButton {
    if (!_pageButton) {
        _pageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _pageButton.backgroundColor = ZFCOLOR(0, 0, 0, 0.4);
        _pageButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _pageButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _pageButton.layer.cornerRadius = 12;
        _pageButton.layer.masksToBounds = YES;
    }
    return _pageButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor = ZFCOLOR(0, 0, 0, 0.4);
        [_closeButton setImage:[UIImage imageNamed:@"versionGuide_close"] forState:0];
        [_closeButton addTarget:self action:@selector(dismissSelfView) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.layer.cornerRadius = 20;
        _closeButton.layer.masksToBounds = YES;
    }
    return _closeButton;
}

- (UIView *)topBgView {
    if (!_topBgView) {
        _topBgView = [[UIView alloc] init];
        _topBgView.backgroundColor = [UIColor clearColor];
    }
    return _topBgView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGRect rexct = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        _collectionView = [[UICollectionView alloc]initWithFrame:rexct collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        [_collectionView registerClass:[ZFReviewPhotoBrowseCell class] forCellWithReuseIdentifier:kZFReviewPhotoBrowseCellIdentifier];
        
        /// 向下滑动手势关闭页面
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureAction:)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
        [_collectionView addGestureRecognizer:swipeGesture];
    }
    return _collectionView;
}

- (UIView *)gradientBgView {
    if (!_gradientBgView) {
        _gradientBgView = [[UIView alloc] init];
        
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = CGRectMake(0.0, 0.0, KScreenWidth, (kReviewTextViewHeight + (IPHONE_X_5_15 ? 34 : 20)));
        [_gradientBgView.layer insertSublayer:gradientLayer atIndex:0];
        gradientLayer.colors = @[(__bridge id)[UIColor blackColor].CGColor, (__bridge id)[UIColor clearColor].CGColor];
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(0, 0);
    }
    return _gradientBgView;
}

- (UITextView *)reviewTextView {
    if (!_reviewTextView) {
        _reviewTextView = [[UITextView alloc] init];
        _reviewTextView.backgroundColor = [UIColor clearColor];
        _reviewTextView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _reviewTextView.textColor = [UIColor whiteColor];
        _reviewTextView.font = [UIFont systemFontOfSize:14];
        _reviewTextView.directionalLockEnabled = YES;
        _reviewTextView.delegate = self;
        _reviewTextView.contentInset = UIEdgeInsetsZero;
    }
    return _reviewTextView;
}

@end

