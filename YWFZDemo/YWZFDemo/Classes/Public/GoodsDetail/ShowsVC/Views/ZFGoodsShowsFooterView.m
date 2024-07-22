//
//  ZFGoodsShowsFooterView.m
//  ZZZZZ
//
//  Created by YW on 2019/3/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsShowsFooterView.h"
#import "ZFCommunityHomeScrollView.h"
#import "ZFGoodsShowsRelatedView.h"
#import "ZFGoodsShowsItemsView.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "Masonry.h"
#import "SystemConfigUtils.h"

@interface ZFGoodsShowsFooterScrollView : UIScrollView<UIGestureRecognizerDelegate>
@end

@implementation ZFGoodsShowsFooterScrollView

///此方法是支持多手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isKindOfClass:[UICollectionView class]]) {
        return NO;
    }
    return YES;
}
@end

@interface ZFGoodsShowsFooterView() <UIScrollViewDelegate >
@property (nonatomic, strong) ZFGoodsShowsFooterScrollView  *horizontalScrollView;
@property (nonatomic, strong) ZFGoodsShowsItemsView         *showItemsView;
@property (nonatomic, strong) ZFGoodsShowsRelatedView       *relatedItemsView;
@property (nonatomic, assign) BOOL                          canScroll;
@property (nonatomic, copy) NSString                        *goods_sn;
@end

@implementation ZFGoodsShowsFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)showDataWithSku:(NSString *)goods_sn {
    self.goods_sn = goods_sn;
    [self.showItemsView showDataWithGoods_sn:goods_sn];
    [self.relatedItemsView relatedDataWithGoods_sn:goods_sn];
}

- (void)selectCustomIndex:(NSInteger)index {
    [self.horizontalScrollView scrollRectToVisible:CGRectMake(index * KScreenWidth , 0, KScreenWidth, self.frame.size.height) animated:NO];
}

- (BOOL)fetchRelatedCollectionStatuss {
    if (self.horizontalScrollView.contentOffset.x / KScreenWidth == 0) {
        return [self.showItemsView fetchScrollStatus];
    } else {
        return [self.relatedItemsView fetchScrollStatus];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger curreentPage = scrollView.contentOffset.x / KScreenWidth;
    if (self.selectIndexCompletion) {
        self.selectIndexCompletion(curreentPage);
    }
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView{
    [self addSubview:self.horizontalScrollView];
    
    CGFloat height = self.frame.size.height;
    NSInteger typeCount = 2;
    for (int i=0; i< typeCount; i++) {
        CGRect rect = CGRectMake(i * KScreenWidth, 0, KScreenWidth, height);
        if (i == 0) { // Show
            if (!self.showItemsView) {
                self.showItemsView = [[ZFGoodsShowsItemsView alloc] initWithFrame:rect];
                self.showItemsView.tag = 2019 + i;
                [self.horizontalScrollView addSubview:self.showItemsView];
                if ([SystemConfigUtils isRightToLeftShow]) {
                    self.showItemsView.transform = CGAffineTransformMakeScale(-1.0,1.0);
                }
            }
        } else if (i == 1) { //related
            if (!self.relatedItemsView) {
                self.relatedItemsView = [[ZFGoodsShowsRelatedView alloc] initWithFrame:rect];
                self.relatedItemsView.tag = 2019 + i;
                [self.horizontalScrollView addSubview:self.relatedItemsView];
                if ([SystemConfigUtils isRightToLeftShow]) {
                    self.relatedItemsView.transform = CGAffineTransformMakeScale(-1.0,1.0);
                }
            }
        }
    }
    self.horizontalScrollView.contentSize = CGSizeMake(KScreenWidth * typeCount, height);
}

- (void)zfAutoLayoutView {
    [self.horizontalScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(self.mas_height);
    }];
}

-(ZFGoodsShowsFooterScrollView *)horizontalScrollView {
    if (!_horizontalScrollView) {
        CGFloat height = KScreenHeight - STATUSHEIGHT - 44 - 44 - (IPHONE_X_5_15 ? 83 : 49);
        _horizontalScrollView = [[ZFGoodsShowsFooterScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, height)];
        _horizontalScrollView.showsVerticalScrollIndicator = NO;
        _horizontalScrollView.showsHorizontalScrollIndicator = NO;
        _horizontalScrollView.delegate = self;
        _horizontalScrollView.pagingEnabled = YES;
        _horizontalScrollView.bounces = NO;
        _horizontalScrollView.backgroundColor = [UIColor whiteColor];
        if ([SystemConfigUtils isRightToLeftShow]) {
            _horizontalScrollView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _horizontalScrollView;
}
@end
