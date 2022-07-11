//
//  OSSVTipView.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/20.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVTipView.h"

@interface OSSVTipView ()
@end

@implementation OSSVTipView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"tip_close"] forState:UIControlStateNormal];
    [self addSubview:closeBtn];
    _closeButton = closeBtn;
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(24);
        make.trailing.mas_equalTo(-4);
        make.top.mas_equalTo(8);
    }];
    
    UILabel *tipMsgLbl = [UILabel new];
    _tipMsgLbl = tipMsgLbl;
    [self addSubview:tipMsgLbl];
    [tipMsgLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-32);
        make.top.mas_equalTo(8);
        make.bottom.mas_equalTo(-8);
        make.width.mas_lessThanOrEqualTo(SCREEN_WIDTH * 0.5);
    }];
    tipMsgLbl.numberOfLines = 0;
//    [tipMsgLbl setContentCompressionResistancePriority:UILayoutPriorityRequired
//                                                    forAxis:UILayoutConstraintAxisHorizontal];
//    [tipMsgLbl setContentHuggingPriority:UILayoutPriorityRequired
//                                      forAxis:UILayoutConstraintAxisHorizontal];
    tipMsgLbl.font = [UIFont systemFontOfSize:11];
    tipMsgLbl.textColor = OSSVThemesColors.col_FFFFFF;
}

@end
