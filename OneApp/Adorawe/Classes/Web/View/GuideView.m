//
//  GuideView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import "GuideView.h"
#import "GuideViewPage.h"

@interface GuideView () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collect;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, strong) UIButton *signBtn;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) NSArray *imgArray;
@property (nonatomic, strong) GuideViewPage *pageControl;

@end

@implementation GuideView

+ (instancetype)sharedInstance {
    static GuideView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GuideView new];
    });
    return instance;
}

- (NSArray *)imgArray {
    if (!_imgArray) {
//        NSString *curLanguage = [STLLocalizationString shareLocalizable].curLanguage;  // 当前语言
//        if ([curLanguage isEqualToString:@"es"]) {
//            _imgArray = @[@"arrivals_en",@"Servic_en",@"Free",@"guarantee_en"];
//        }else if ([curLanguage isEqualToString:@"ar"]) {
//            _imgArray = @[@"arrivals_ar",@"Servic_ar",@"Free_ar",@"guarantee_ar"];
//        }else {
//            _imgArray = @[@"arrivals_en",@"Servic_en",@"Free",@"guarantee_en"];
//        }
        if (kIS_IPHONEX) {
            _imgArray = @[@"arrivals_ar_x",@"Servic_ar_x",@"Free_ar_x",@"guarantee_ar_x"];
        } else {
            _imgArray = @[@"arrivals_ar",@"Servic_ar",@"Free_ar",@"guarantee_ar"];

        }
    }
    return _imgArray;
}

- (UICollectionView *)collect {
    if (!_collect) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT-49);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collect = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collect.bounces = NO;
        _collect.backgroundColor = [UIColor whiteColor];
        _collect.showsHorizontalScrollIndicator = NO;
        _collect.showsVerticalScrollIndicator = NO;
        _collect.pagingEnabled = YES;
        _collect.dataSource = self;
        _collect.delegate = self;
    }
    return _collect;
}

- (GuideViewPage *)pageControl {
    if (!_pageControl) {
        _pageControl = [[GuideViewPage alloc] init];
        _pageControl.numberOfPages = 4;
        [_pageControl sizeForNumberOfPages:20];
        _pageControl.pageIndicatorTintColor = OSSVThemesColors.col_E5E5E5;
        _pageControl.currentPageIndicatorTintColor = OSSVThemesColors.col_2E536B;
        _pageControl.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 60);
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _pageControl.transform = CGAffineTransformMakeRotation(M_PI);
            _pageControl.currentPage = 5;
        }
    }
    return _pageControl;
}

- (UIButton *)stopBtn {
    if (!_stopBtn) {
        _stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stopBtn setTitle:STLLocalizedString_(@"shopNow", nil) forState:UIControlStateNormal];
        [_stopBtn setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateNormal];
        [_stopBtn addTarget:self action:@selector(shoppingNow) forControlEvents:UIControlEventTouchUpInside];
        _stopBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _stopBtn.backgroundColor = OSSVThemesColors.col_FFFFFF;
    }
    return _stopBtn;
}

- (UIButton *)signBtn {
    if (!_signBtn) {
        _signBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signBtn setTitle:STLLocalizedString_(@"signUp", nil) forState:UIControlStateNormal];
        [_signBtn setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateNormal];
        [_signBtn addTarget:self action:@selector(signUp) forControlEvents:UIControlEventTouchUpInside];
        _signBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _signBtn.backgroundColor = OSSVThemesColors.col_FF9522;
    }
    return _signBtn;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = OSSVThemesColors.col_F1F1F1;
    }
    return _line;
}

- (void)show {    
    [self.window addSubview:self.collect];
    [self.collect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.leading.mas_equalTo(self.window);
    }];
    
    [self.window addSubview:self.stopBtn];
    [self.stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collect.mas_bottom);
        make.leading.mas_equalTo(self.window);
        make.height.mas_equalTo(49);
        make.width.mas_equalTo(SCREEN_WIDTH/2);
        if (kIS_IPHONEX) {
            make.bottom.mas_equalTo(self.window.mas_bottom).offset(-STL_TABBAR_IPHONEX_H);
        } else {
            make.bottom.mas_equalTo(self.window);
        }
    }];
    
    [self.window addSubview:self.signBtn];
    [self.signBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collect.mas_bottom);
        make.trailing.mas_equalTo(self.window);
        make.height.mas_equalTo(49);
        make.width.mas_equalTo(SCREEN_WIDTH/2);
        if (kIS_IPHONEX) {
            make.bottom.mas_equalTo(self.window.mas_bottom).offset(-STL_TABBAR_IPHONEX_H);
        } else {
            make.bottom.mas_equalTo(self.window);
        }
    }];
    
    [self.window addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.stopBtn.mas_top);
        make.leading.trailing.mas_equalTo(self.stopBtn);
        make.height.mas_equalTo(1);
    }];
    
     [self.window addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.collect.mas_bottom).mas_offset(-35);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(10);
    }];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imgArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GuideViewCell *cell = [GuideViewCell guideViewCellWithCollectionView:collectionView forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:self.imgArray[indexPath.item]];
    return cell;
}

- (void)shoppingNow {
    
    [self stopNow];
    if (_shoppingCallBack) {
        _shoppingCallBack();
    }
}

- (void)stopNow {
    [self.collect removeFromSuperview];
    [self.stopBtn removeFromSuperview];
    [self.signBtn removeFromSuperview];
    [self.line removeFromSuperview];
    [self.pageControl removeFromSuperview];
    
    [self setWindow:nil];
    [self setCollect:nil];
    [self setStopBtn:nil];
    [self setSignBtn:nil];
    [self setLine:nil];
    [self setPageControl:nil];
}

- (void)signUp {
    [self stopNow];
    if (self.signUpBlock) {
        self.signUpBlock();
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = (scrollView.contentOffset.x / SCREEN_WIDTH);
}

@end

///////////////////////////////////////////////////////////////

@implementation GuideViewCell

+ (GuideViewCell *)guideViewCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[GuideViewCell class] forCellWithReuseIdentifier:@"GuideViewCell"];
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"GuideViewCell" forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[YYAnimatedImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.contentView.size);
        }];
    }
    return self;
}

@end
