//
//  ZFFullLiveGoodsAttributesListView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveGoodsAttributesListView.h"

@interface ZFFullLiveGoodsAttributesListView()<ZFLiveFullGoodsAttributePageScrollViewDelegate>

@end

@implementation ZFFullLiveGoodsAttributesListView

- (instancetype)initWithFrame:(CGRect)frame contentHeight:(CGFloat)contentHeight {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ZFCClearColor();
        self.pageScrollView = [[ZFLiveFullGoodsAttributePageScrollView alloc] initWithFrame:CGRectZero];
        self.pageScrollView.backgroundColor = ZFCClearColor();
        self.pageScrollView.contentH = contentHeight;
        self.pageScrollView.delegate = self;
        self.pageScrollView.showPageControl = NO;
        
        [self addSubview:self.pageScrollView];
        
        [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)setLiveVideoId:(NSString *)liveVideoId {
    _liveVideoId = liveVideoId;
    self.pageScrollView.liveVideoId = liveVideoId;
}

- (void)setGoodsArray:(NSArray<ZFGoodsModel *> *)goodsArray {
    _goodsArray = goodsArray;
    if (_goodsArray.count > 0) {
        self.pageScrollView.goodsArray = goodsArray;
    }
}

- (void)setRecommendGoodsId:(NSString *)recommendGoodsId {
    if (recommendGoodsId) {
        
        if (!_recommendGoodsId) {
            _recommendGoodsId = recommendGoodsId;
            [self.pageScrollView refreshTopMarkIndex:recommendGoodsId];
            
        } else if (_recommendGoodsId && ![_recommendGoodsId isEqualToString:recommendGoodsId]) {
            _recommendGoodsId = recommendGoodsId;
            [self.pageScrollView refreshTopMarkIndex:recommendGoodsId];
        }
    }
}

- (void)didShowScrollView:(ZFFullLiveGoodsAttributesItemView *)itemView pageAtIndex:(NSInteger)index {
    YWLog(@"--------- did: %li",(long)index);
    if (itemView) {
        [itemView zfWillViewAppear];
    }
}

- (void)willShowScrollView:(ZFFullLiveGoodsAttributesItemView *)itemView pageAtIndex:(NSInteger)index {
    YWLog(@"--------- will: %li",(long)index);
    if (itemView) {
        [itemView zfWillViewAppear];
    }
}

- (void)liveFullGoodsAttributePage:(ZFFullLiveGoodsAttributesItemView *)itemView eventType:(LiveGoodsAttributesOperateType)eventType {
    if (eventType == LiveGoodsAttributesOperateTypeGuideSize) {
        if (self.attributeGuideSizeBlock) {
            self.attributeGuideSizeBlock(itemView.currentGuideSizeUrl);
        }
    } else if(eventType == LiveGoodsAttributesOperateTypeCart) {
        if (self.cartBlock) {
            self.cartBlock();
        }
    }
}

- (void)liveFullGoodsAttributePage:(ZFFullLiveGoodsAttributesItemView *)itemView eventType:(LiveGoodsAttributesOperateType)eventType goodsDetailModel:(GoodsDetailModel *)goodsDetailModel {
    if (self.commentListBlock) {
        self.commentListBlock(goodsDetailModel);
    }
}
@end
