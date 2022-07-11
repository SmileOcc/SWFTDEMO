//
//  OSSVHomeAdvBannerCCell.m
// OSSVHomeAdvBannerCCell
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeAdvBannerCCell.h"
#import "SDCycleScrollView.h"

@interface OSSVHomeAdvBannerCCell ()<SDCycleScrollViewDelegate>
@property (nonatomic, strong) SDCycleScrollView       *bannerView;

///只保存events
@property (nonatomic,strong) NSArray<OSSVAdvsEventsModel *> *events;
@end

@implementation OSSVHomeAdvBannerCCell
@synthesize model    = _model;
@synthesize delegate = _delegate;

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self.contentView addSubview:self.bannerView];
        
        [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
    return self;
}

// 点击图片
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    
    if ([self.model.dataSource isKindOfClass:[NSArray class]]) {
        NSArray *list = (NSArray *)self.model.dataSource;
        if (list.count > index) {
            OSSVAdvsEventsModel *model = list[index];
            [self eventBannerModel:model index:index];
        }
    }
    
    if (self.events && self.events.count > index) {
        OSSVAdvsEventsModel *model = self.events[index];
        [self eventBannerModel:model index:index];
    }
}

/** 图片滚动回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_HomeBannerCCell:advEventModel:showCellIndex:)]) {
        
        NSArray *list = (NSArray *)self.model.dataSource;
        if (list.count > index) {
            OSSVAdvsEventsModel *model = list[index];
            [self.delegate STL_HomeBannerCCell:self advEventModel:model showCellIndex:index];
        }
    }
}

- (void)eventBannerModel:(OSSVAdvsEventsModel *)model index:(NSInteger)index{
    if (!model) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_HomeBannerCCell:advEventModel:index:)]) {
        [self.delegate STL_HomeBannerCCell:self advEventModel:model index:index];
    }
}

-(void)setModel:(OSSVHomeCCellBanneModel *)model {
    if (model == _model) return;
    
    _model = model;
    if ([model.dataSource isKindOfClass:[NSArray class]]) {
        NSArray *list = (NSArray *)model.dataSource;
        
        NSMutableArray *imageUrls = [[NSMutableArray alloc] init];
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[OSSVAdvsEventsModel class]]) {*stop = YES;}
            OSSVAdvsEventsModel *model = obj;
            [imageUrls addObject:model.imageURL];
        }];
        self.bannerView.imageURLStringsGroup = [imageUrls copy];
        
        //为了触发第一次曝光
        if (self.delegate && [self.delegate respondsToSelector:@selector(STL_HomeBannerCCell:advEventModel:showCellIndex:)]) {
            NSArray *list = (NSArray *)self.model.dataSource;
            OSSVAdvsEventsModel *model = list.firstObject;
            [self.delegate STL_HomeBannerCCell:self advEventModel:model showCellIndex:0];
        }
    }
}

-(void)setEventArr:(NSArray<OSSVAdvsEventsModel *> *)items{
    _events = items;
    NSMutableArray *imageUrls = [[NSMutableArray alloc] init];
    for (OSSVAdvsEventsModel *model in items) {
        NSString *str = model.imageURL;
        [imageUrls addObject:str];
    }
    self.bannerView.imageURLStringsGroup = [imageUrls copy];
    //为了触发第一次曝光
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_HomeBannerCCell:advEventModel:showCellIndex:)]) {
        NSArray *list = (NSArray *)self.model.dataSource;
        OSSVAdvsEventsModel *model = list.firstObject;
        [self.delegate STL_HomeBannerCCell:self advEventModel:model showCellIndex:0];
    }
}

-(SDCycleScrollView *)bannerView {
    if (!_bannerView) {
        _bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[UIImage imageNamed:@"BannerPlaceholder"]];

        _bannerView.autoScrollTimeInterval = 3.0;
        _bannerView.currentPageDotColor = [OSSVThemesColors col_262626];
        _bannerView.pageDotColor = OSSVThemesColors.col_F1F1F1;
        _bannerView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _bannerView.pageControlBottomOffset = 10;
    }
    return _bannerView;
}

@end
