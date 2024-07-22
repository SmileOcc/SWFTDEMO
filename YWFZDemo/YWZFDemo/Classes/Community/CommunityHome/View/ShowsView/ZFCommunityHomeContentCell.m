//
//  ZFCommunityHomeContentCell.m
//  ZZZZZ
//
//  Created by YW on 2018/11/20.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeContentCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFFrameDefiner.h"

#import "ZFCommunityHomeScrollView.h"
#import "ZFCommunityHomeShowView.h"
#import "ZFCommunityHomeOutfitsView.h"
#import "ZFCommunityHomePostCategoryView.h"
#import "CommunityEnumComm.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCommunityHomeContentCell()
<
ZFInitViewProtocol,
UIScrollViewDelegate
>


@property (nonatomic, strong) ZFCommunityHomeScrollView     *horizontalScrollView;
@property (nonatomic, strong) ZFCommunityHomeShowView       *firstShowView;
@property (nonatomic, strong) ZFCommunityHomeOutfitsView    *outfitsView;

@end


@implementation ZFCommunityHomeContentCell

+ (NSString *)queryReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)dealloc {
    ZFRemoveAllNotification(self);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)currentViewFirstRequest:(NSInteger)index{
    ZFCommunityHomeShowView *subShowView = [self.horizontalScrollView viewWithTag:(21200 + index)];
    if ([subShowView respondsToSelector:@selector(startFirstRequest)]) {
        [subShowView startFirstRequest];
    }
}

//第一第二 菜单是固定的
- (void)updateDatas:(NSArray *)datas {
    
    [self.datasArray removeAllObjects];
    [self.datasArray addObjectsFromArray:datas];
    
    CGFloat height = 0;
    if (IPHONE_X_5_15) {
        height = KScreenHeight - STATUSHEIGHT - 44 - 83 - 44;
    }else{
        height = KScreenHeight - STATUSHEIGHT - 44 - 49 - 44;
    }
    
    NSArray *subsView = [self.horizontalScrollView subviews];
    if (subsView.count > self.datasArray.count && self.datasArray.count >= 2) {
        for (NSInteger i = self.datasArray.count; i<subsView.count; i++) {
            UIView *showView = subsView[i];
            [showView removeFromSuperview];
        }
    }

    for (int i=0; i<self.datasArray.count; i++) {
        ZFCommunityChannelItemModel *itemModel = self.datasArray[i];

        BOOL startRequest = i < 3 ? YES : NO;        
        if (i == 0) {//firstShow
            if (!self.firstShowView) {
                self.firstShowView = [[ZFCommunityHomeShowView alloc] initWithFrame:CGRectMake(i * KScreenWidth, 0, KScreenWidth, height) itemModel:itemModel startRequest:startRequest];
                self.firstShowView.tag = 21200 + i;
                [self.horizontalScrollView addSubview:self.firstShowView];
                if ([SystemConfigUtils isRightToLeftShow]) {
                    self.firstShowView.transform = CGAffineTransformMakeScale(-1.0,1.0);
                }
            }
            
        } else if (i == 1) {//outfit
            if (!self.outfitsView) {
                self.outfitsView = [[ZFCommunityHomeOutfitsView alloc] initWithFrame:CGRectMake(i * KScreenWidth, 0, KScreenWidth, height) itemModel:itemModel startRequest:startRequest];
                self.outfitsView.tag = 21200 + i;
                [self.horizontalScrollView addSubview:self.outfitsView];
                if ([SystemConfigUtils isRightToLeftShow]) {
                    self.outfitsView.transform = CGAffineTransformMakeScale(-1.0,1.0);
                }
            }
            
            
        } else {
            
            ZFCommunityHomePostCategoryView *subShowView = [self.horizontalScrollView viewWithTag:(21200 + i)];
            if (subShowView) {
                NSString *catName = ZFToString(subShowView.itemModel.cat_name);
                NSString *catId = ZFToString(subShowView.itemModel.idx);
                
                if ([catName isEqualToString:ZFToString(itemModel.cat_name)] && [catId isEqualToString:ZFToString(itemModel.idx)]) {
                } else {
                    [subShowView updateItemModel:itemModel];
                }
            } else {
                
                ZFCommunityHomePostCategoryView *showView = [[ZFCommunityHomePostCategoryView alloc] initWithFrame:CGRectMake(i * KScreenWidth, 0, KScreenWidth, height) itemModel:itemModel startRequest:startRequest];
                showView.tag = 21200 + i;
                [self.horizontalScrollView addSubview:showView];
                if ([SystemConfigUtils isRightToLeftShow]) {
                    showView.transform = CGAffineTransformMakeScale(-1.0,1.0);
                }
            }
        }
    }
    
    self.horizontalScrollView.contentSize = CGSizeMake(KScreenWidth * self.datasArray.count, height);
}

-(ZFCommunityHomeSelectType)setSegmentIndex:(UIScrollView *)scrollView {
    int index = scrollView.contentOffset.x / KScreenWidth;
    if (index < 0) {
        index = 0;
    }
    return index;
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (selectIndex == -1) return;
    [self.horizontalScrollView setContentOffset:CGPointMake(selectIndex *KScreenWidth, 0) animated:NO];
    [self currentViewFirstRequest:selectIndex];
}

#pragma mark - UIScrollView

//快速滑动调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.horizontalScrollView]) {
        if (self.selectBlock) {
            self.selectBlock([self setSegmentIndex:scrollView]);
        }
    }
}

//手指 慢慢拖动时调用
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (!decelerate && [scrollView isEqual:self.horizontalScrollView]) {
        if (self.selectBlock) {
            self.selectBlock([self setSegmentIndex:scrollView]);
        }
    }
}


#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView{
    [self.contentView addSubview:self.horizontalScrollView];
}

- (void)zfAutoLayoutView{
    
    [self.horizontalScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsZero);
        make.width.mas_equalTo(KScreenWidth);
        if (IPHONE_X_5_15) {
            make.height.mas_equalTo(KScreenHeight - STATUSHEIGHT - 44 - 83 - 44);
        }else{
            make.height.mas_equalTo(KScreenHeight - STATUSHEIGHT - 44 - 49 - 44);
        }
    }];
}

#pragma mark - setter/getter

- (NSMutableArray *)datasArray {
    if (!_datasArray) {
        _datasArray = [[NSMutableArray alloc] init];
    }
    return _datasArray;
}

- (UITableView *)tableView {
    UIView *tableView = self.superview;
    while (![tableView isKindOfClass:[UITableView class]] && tableView) {
        tableView = tableView.superview;
    }
    return (UITableView *)tableView;
}

-(ZFCommunityHomeScrollView *)horizontalScrollView{
    if (!_horizontalScrollView) {
        
        CGFloat height = 0;
        if (IPHONE_X_5_15) {
            height = KScreenHeight - STATUSHEIGHT - 44 - 83 - 44;
        }else{
            height = KScreenHeight - STATUSHEIGHT - 44 - 49 - 44;
        }
        _horizontalScrollView = [[ZFCommunityHomeScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, height)];
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
