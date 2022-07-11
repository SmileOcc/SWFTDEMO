//
//  YXSDWeavesDetailHeaderView.h
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXSDWeavesDetailHeaderView : UIView //QMUITableViewHeaderFooterView
@property (copy, nonatomic) dispatch_block_t directionMoreInfoBlock;

- (instancetype)initWithFrame:(CGRect)frame andIsUsNation: (BOOL)isUsNation;


@end

NS_ASSUME_NONNULL_END
