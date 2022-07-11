//
//  STLStrongFellCtrl.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/11.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLStrongFellCtrl.h"
#import "UIImage+STLCategory.h"
#import <iCarousel.h>
#import "TAPageControl.h"

@interface STLStrongFellCtrl ()< iCarouselDelegate, iCarouselDataSource>

@property (nonatomic, strong) UIButton          *bgBtn;
@property (nonatomic, strong) UIView            *mainView;
@property (nonatomic, strong) UIView            *scrollBgView;
@property (nonatomic, strong) UIButton          *sureBtn;
@property (nonatomic, assign) NSInteger         currentIndex;

@property (nonatomic, strong) iCarousel         *carouselScroll;
@property (nonatomic, strong) TAPageControl     *pageCtrl;

@end

@implementation STLStrongFellCtrl

- (instancetype)init{
    self = [super init];
    if (self) {
        // 设置半透明
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }else{
            self.modalPresentationStyle=UIModalPresentationCurrentContext;
        }
        //
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.051 green:0.051 blue:0.051 alpha:0];
    
    [self setUpView];
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
}

- (void)setUpView{
    [self.view addSubview:self.bgBtn];
    [self.view addSubview:self.mainView];
    [self.view addSubview:self.scrollBgView];
    [self.scrollBgView addSubview:self.carouselScroll];
    [self.scrollBgView addSubview:self.pageCtrl];
    [self.mainView addSubview:self.sureBtn];
    
    [self.bgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading).offset(24);
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-24);
        make.height.mas_equalTo(413);
    }];
    
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mainView.mas_bottom).offset(-24);
        make.centerX.mas_equalTo(self.mainView.mas_centerX);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(120);
    }];
    
    [self.sureBtn layoutIfNeeded];
    self.sureBtn.layer.cornerRadius = 22;
    
    [self.scrollBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mainView.mas_leading).offset(24);
        make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-24);
        make.top.mas_equalTo(self.mainView.mas_top).offset(24);
        make.bottom.mas_equalTo(self.sureBtn.mas_top).offset(-24);
    }];
    
    [self.pageCtrl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollBgView.mas_centerX).offset(-10);
        make.bottom.mas_equalTo(self.scrollBgView.mas_bottom);
        make.height.mas_equalTo(6);
    }];
    
    [self.carouselScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.scrollBgView);
        make.bottom.mas_equalTo(self.scrollBgView.mas_bottom).offset(-22);
    }];
    
    
    [self.mainView layoutIfNeeded];
    self.mainView.layer.cornerRadius = 6;
    
    [self loadImgs];
}

- (void)loadImgs{
    [self.carouselScroll reloadData];
    if (self.imgsArr.count > 1) {
        self.pageCtrl.numberOfPages = self.imgsArr.count;
        self.pageCtrl.currentPage = _currentIndex;
    }else{
        self.pageCtrl.hidden = YES;
    }
    [self changTheOpzationForImgS];
}

- (void)changTheOpzationForImgS{
    NSDictionary *dic = self.imgsObjestArr.firstObject;
    CGFloat w = [[dic objectForKey:@"width"] floatValue];
    CGFloat h = [[dic objectForKey:@"height"] floatValue];
    CGFloat width = SCREEN_WIDTH - 96;
    CGFloat ratio = h/w;
    ratio = ratio > 0 ? ratio : 1;
    [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(width *ratio + 48 +46+44);
    }];
    
}

/// lazy

- (UIView *)mainView{
    if (!_mainView) {
        _mainView = [UIView new];
        _mainView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _mainView;
}

- (UIView *)scrollBgView{
    if (!_scrollBgView) {
        _scrollBgView = [UIView new];
        _scrollBgView.backgroundColor = [UIColor clearColor];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _scrollBgView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
    }
    return _scrollBgView;
}

- (iCarousel *)carouselScroll{
    if (!_carouselScroll) {
        _carouselScroll = [[iCarousel alloc] init];
        _carouselScroll.autoscroll = NO;
        _carouselScroll.pagingEnabled = YES;
        _carouselScroll.delegate = self;
        _carouselScroll.dataSource = self;
        _carouselScroll.clipsToBounds = YES;
        _carouselScroll.bounceDistance = 0.1;
    
    }
    return _carouselScroll;
}

- (TAPageControl *)pageCtrl{
    if (!_pageCtrl) {
        _pageCtrl = [[TAPageControl alloc] init];
        _pageCtrl.dotImage = [UIImage imageNamed:@"share_pageUnSelected"];
        _pageCtrl.currentDotImage = [UIImage imageNamed:@"share_pageSelected"];
//        _pageCtrl.dotSize = CGSizeMake(32, 6);
    }
    return _pageCtrl;
}

-(UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton new];
        if (self.imgsArr.count > 1) {
            if (APP_TYPE == 3) {
                [_sureBtn setTitle:STLLocalizedString_(@"next", nil) forState:UIControlStateNormal];
            } else {
                [_sureBtn setTitle:STLLocalizedString_(@"next", nil).uppercaseString forState:UIControlStateNormal];
            }
        }else{
            if (APP_TYPE == 3) {
                [_sureBtn setTitle:STLLocalizedString_(@"ok", nil) forState:UIControlStateNormal];

            } else {
                [_sureBtn setTitle:STLLocalizedString_(@"ok", nil).uppercaseString forState:UIControlStateNormal];
            }
        }
        
        [_sureBtn setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        _sureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [_sureBtn setBackgroundColor:[OSSVThemesColors stlBlackColor]];
        [_sureBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

-(UIButton *)bgBtn{
    if (!_bgBtn) {
        _bgBtn = [UIButton new];
        [_bgBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
        [_bgBtn addTarget:self action:@selector(bgCloseAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgBtn;
}

- (void)bgCloseAction:(UIButton *)sender{
    if (self.closeblock) {
        self.closeblock();
    }
}

- (void)closeAction:(UIButton *)sender{
    if (_currentIndex == self.imgsArr.count - 1) {
        if (self.closeblock) {
            self.closeblock();
        }
    }else{
//        [self.cycyleScrollView makeScrollViewScrollToIndex:_currentIndex];
        [self.carouselScroll scrollToItemAtIndex:_currentIndex + 1 animated:YES];
    }
}

#pragma mark -- delegate
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return self.imgsArr.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIView *)view{
    NSString *imgStr = nil;
    if (STLJudgeNSArray(self.imgsArr)) {
        imgStr = self.imgsArr[index];
        if (view == nil) {
            view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, carousel.frame.size.width, carousel.frame.size.height)];
            [((UIImageView *)view) yy_setImageWithURL:[NSURL URLWithString:imgStr] placeholder:[UIImage imageNamed:@"share_place"]];
        }else{
            [((UIImageView *)view) yy_setImageWithURL:[NSURL URLWithString:imgStr] placeholder:[UIImage imageNamed:@"share_place"]];
        }
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            view.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
        
        return view;
    }else{
        return [UIView new];
    }
}


- (void)carouselDidScroll:(iCarousel *)carousel{
    if (carousel.currentItemIndex == self.imgsArr.count - 1) {
        if (APP_TYPE == 3) {
            [_sureBtn setTitle:STLLocalizedString_(@"ok", nil) forState:UIControlStateNormal];
        } else {
            [_sureBtn setTitle:STLLocalizedString_(@"ok", nil).uppercaseString forState:UIControlStateNormal];
        }
    }else{
        if (APP_TYPE == 3) {
            [_sureBtn setTitle:STLLocalizedString_(@"next", nil) forState:UIControlStateNormal];
        } else {
            [_sureBtn setTitle:STLLocalizedString_(@"next", nil).uppercaseString forState:UIControlStateNormal];
        }
    }
    _currentIndex = carousel.currentItemIndex;
    
    _pageCtrl.currentPage = _currentIndex;
}

@end
