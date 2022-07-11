//
//  YXBrokerAnalyzeView.m
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2022/5/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "YXBrokerAnalyzeView.h"
#import "YXHkVolumnSectionHeaderView.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@interface YXBrokerAnalyzeView ()
@property (nonatomic, assign) YXBrokerLineType type;
@end

@implementation YXBrokerAnalyzeView

- (instancetype)initWithFrame:(CGRect)frame andType:(YXBrokerLineType)type {
    if (self = [super initWithFrame:frame]) {
        self.type = type;
        
        [self initUI];
    }
    
    return self;
}

- (void)initUI {
    
    UIView *headerView = [self creatTitleViewWithType:self.type];
    
    self.lineView = [[YXBrokerLineView alloc] initWithFrame:CGRectMake(0, 16, self.mj_w - 32, self.lineHeight) andType:self.type];
    
    [self addSubview:headerView];
    [self addSubview:self.lineView];
    
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(75);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.right.equalTo(self).offset(-16);
        make.height.mas_equalTo(self.lineHeight);
        make.top.equalTo(headerView.mas_bottom);
    }];
    
    if (self.type == YXBrokerLineTypeHkwolun) {
        self.volumnChangeView = [[YXHkVolumnSectionHeaderView alloc] init];
        self.volumnChangeView.hidden = YES;
        
        [self addSubview:self.volumnChangeView];
        [self.volumnChangeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lineView.mas_bottom);
            make.left.right.equalTo(self);
            make.bottom.equalTo(self);
        }];
    }
}

- (UIView *)creatTitleViewWithType:(YXBrokerLineType)type {
    NSString *str = @"";
    if (type == YXBrokerLineTypeSell) {
        // 卖空
        str = [YXLanguageUtility kLangWithKey:@"sales_and_ratio"];
    } else {
        // 港股通
        str = [YXLanguageUtility kLangWithKey:@"ggt_hold_ratio"];
    }
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = QMUITheme.foregroundColor;
    
    UILabel *label = [UILabel labelWithText:str textColor:QMUITheme.textColorLevel1 textFont:[UIFont mediumFont14]];
    label.numberOfLines = 0;
    
    NSMutableAttributedString *mutAttrString = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:20 weight:UIFontWeightMedium], NSForegroundColorAttributeName : QMUITheme.textColorLevel1}];
    
    CGFloat offset = 0;
    if (type == 1 && YXUserManager.isENMode) {
        offset = 3;
    }
    
    [mutAttrString appendAttributedString:[NSAttributedString qmui_attributedStringWithImage:[UIImage imageNamed:@"stock_about"] margins:UIEdgeInsetsMake(offset, 5, 0, 0)]];

    label.attributedText = mutAttrString;
    [view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view).offset(16);
        make.trailing.equalTo(view).offset(-16);
        make.height.mas_greaterThanOrEqualTo(24);
        make.centerY.equalTo(view);
    }];
    
    @weakify(self)
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        
        @strongify(self)
        [self showInfoAlert:type];
         
    }];
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:tapGes];

    
    return view;
}

- (void)showInfoAlert:(NSInteger)type {
    NSString *str = @"";
    if (type == 0) {
        str = [YXLanguageUtility kLangWithKey:@"sales_ratio_msg"];
    } else {
        str = [YXLanguageUtility kLangWithKey:@"ggt_hold_msg"];
    }
    YXAlertView *alertView = [YXAlertView alertViewWithMessage:str];
    alertView.messageLabel.font = [UIFont systemFontOfSize:16];
    alertView.messageLabel.textAlignment = NSTextAlignmentLeft;
    YXAlertAction *sure = [[YXAlertAction alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"common_iknow"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {

    }];
    [alertView addAction:sure];
    [alertView showInWindow];
}


- (CGFloat)lineHeight {
    return 290;
}

@end
