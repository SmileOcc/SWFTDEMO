//
//  ZFCategoryTopOperateView.m
//  ZZZZZ
//
//  Created by YW on 2018/12/3.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCategoryTopOperateView.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFCategoryTopOperateView ()
@property (nonatomic, copy) SelectMenuHandler selectMenuBlock;
@property (nonatomic, copy) SelectedKeywordHandle selectedKeywordBlock;
@end

@implementation ZFCategoryTopOperateView

- (instancetype)initWithFrame:(CGRect)frame
              selectMenuBlock:(SelectMenuHandler)selectMenuBlock
         selectedKeywordBlock:(SelectedKeywordHandle)selectedKeywordBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectMenuBlock = selectMenuBlock;
        self.selectedKeywordBlock = selectedKeywordBlock;
        
        [self configureSubViews];
        [self autoLayoutSubViews];
    }
    return self;
}

#pragma mark - 更新数据源

- (void)updateKeyworkData:(NSArray *)guideWordsArr {
    self.keyworkHeaderView.kerwordArray = guideWordsArr;
    self.keyworkHeaderView.hidden = guideWordsArr.count>0 ? NO : YES;
}

#pragma mark - UI Layoyt Methods

- (void)configureSubViews {
    [self addSubview:self.menuView];
    [self addSubview:self.keyworkHeaderView];
}

- (void)autoLayoutSubViews {
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self);
        make.height.mas_equalTo(KMenuHeight);
    }];
    
    [self.keyworkHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.menuView.mas_bottom);
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(kKeywordHeight);
    }];
}

- (CategoryDropDownMenu *)menuView {
    if (!_menuView) {
        _menuView = [[CategoryDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:KMenuHeight];
        _menuView.chooseCompletionHandler = self.selectMenuBlock;
        _menuView.isHideTopLine = YES;
        _menuView.isHideSpaceLine = YES;
    }
    return _menuView;
}

- (ZFGoodsKeyWordsHeaderView *)keyworkHeaderView {
    if (!_keyworkHeaderView) {
        _keyworkHeaderView = [[ZFGoodsKeyWordsHeaderView alloc] init];
        _keyworkHeaderView.frame = CGRectMake(0.0, KMenuHeight, KScreenWidth, kKeywordHeight);
        _keyworkHeaderView.selectedKeywordHandle = self.selectedKeywordBlock;
    }
    return _keyworkHeaderView;
}

@end
