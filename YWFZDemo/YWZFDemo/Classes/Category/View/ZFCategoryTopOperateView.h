//
//  ZFCategoryTopOperateView.h
//  ZZZZZ
//
//  Created by YW on 2018/12/3.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryDropDownMenu.h"
#import "ZFGoodsKeyWordsHeaderView.h"

static CGFloat const KMenuHeight    = 44;
static CGFloat const kKeywordHeight = 54;

typedef void(^SelectMenuHandler)(NSInteger tapIndex, BOOL isSelect);
typedef void(^SelectedKeywordHandle)(NSString *keyword);

NS_ASSUME_NONNULL_BEGIN

@interface ZFCategoryTopOperateView : UIView

@property (nonatomic, strong) CategoryDropDownMenu           *menuView;
@property (nonatomic, strong) ZFGoodsKeyWordsHeaderView      *keyworkHeaderView;

- (instancetype)initWithFrame:(CGRect)frame
              selectMenuBlock:(SelectMenuHandler)selectMenuBlock
         selectedKeywordBlock:(SelectedKeywordHandle)selectedKeywordBlock;

#pragma mark - 更新数据源

- (void)updateKeyworkData:(NSArray *)guideWordsArr;

@end

NS_ASSUME_NONNULL_END
