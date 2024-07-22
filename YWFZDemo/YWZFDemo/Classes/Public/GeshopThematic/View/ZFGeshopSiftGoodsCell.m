//
//  ZFGeshopSiftGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopSiftGoodsCell.h"
#import "SystemConfigUtils.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFNotificationDefiner.h"
#import "ZFGeshopSiftBarView.h"

@interface ZFGeshopSiftGoodsCell ()
@property (nonatomic, strong) ZFGeshopSiftBarView *siftBarView;
@end

@implementation ZFGeshopSiftGoodsCell

@synthesize sectionModel = _sectionModel;


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.siftBarView];
}

- (void)zfAutoLayoutView {
    [self.siftBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - Setter

- (void)setSectionModel:(ZFGeshopSectionModel *)sectionModel {
    _sectionModel = sectionModel;
    
    NSString *catgory = self.sectionModel.checkedCategorySiftModel.item_title;
    
    NSString *sort = self.sectionModel.checkedSortSiftModel.item_title;
    
    /// 首次默认用第一个排序标题
    if (ZFIsEmptyString(sort)) {
        ZFGeshopSiftItemModel *sortItem = sectionModel.component_data.sort_list.firstObject;
        if ([sortItem isKindOfClass:[ZFGeshopSiftItemModel class]]) {
            sort = sortItem.item_title;
        }
    }
    [self.siftBarView refreshCategoryTitle:catgory sortTitle:sort];
}

#pragma mark - Getter

- (ZFGeshopSiftBarView *)siftBarView {
    if (!_siftBarView) {
        _siftBarView = [[ZFGeshopSiftBarView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _siftBarView.itemButtonActionBlock = ^(NSInteger dataType, BOOL openList) {
            @strongify(self)
            if (self.sectionModel.clickSiftItemBlock) {
                self.sectionModel.clickSiftItemBlock(self.sectionModel, CGRectGetMinY(self.frame), dataType, openList);
            }
        };
    }
    return _siftBarView;
}


@end
