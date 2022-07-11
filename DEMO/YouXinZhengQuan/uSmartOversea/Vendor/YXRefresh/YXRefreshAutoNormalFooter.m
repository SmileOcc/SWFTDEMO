//
//  YXRefreshAutoNormalFooter.m
//  uSmartOversea
//
//  Created by ellison on 2019/1/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXRefreshAutoNormalFooter.h"
#import "uSmartOversea-Swift.h"

@implementation YXRefreshAutoNormalFooter

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)prepare {
    [super prepare];
    
    self.triggerAutomaticallyRefreshPercent = 0;
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.stateLabel.textColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.4];
    self.stateLabel.font = [UIFont systemFontOfSize:14];
    [self setTitle:@"" forState:MJRefreshStateIdle];
    
    [self setTitle:[YXLanguageUtility kLangWithKey:@"common_loading"] forState:MJRefreshStateRefreshing];
    [self setTitle:[YXLanguageUtility kLangWithKey:@"common_no_more_data"] forState:MJRefreshStateNoMoreData];
}

- (void)setStateTextColor:(UIColor *)textColor {
    self.stateLabel.textColor = textColor;
}

@end
