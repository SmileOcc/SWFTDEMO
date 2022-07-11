//
//  YXAuthorityReminderTool.m
//  uSmartOversea
//
//  Created by youxin on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#define kYXRANKINDUSTRYALL @"INDUSTRY_ALL"
#define kYXRANKHKALL @"HK_ALL"
#define kYXRANKMAINALL @"MAIN_ALL"
#define kYXRANKGEMALL @"GEM_ALL"

#import "YXAuthorityReminderTool.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXAuthorityReminderTool ()
@property (nonatomic, strong) QMUILabel *reminderLabel;
@property (nonatomic, copy) LoginStatusChangeBlock loginStatusChangeBlock;

@end

@implementation YXAuthorityReminderTool

+ (QMUILabel *)reminderLabelWithAuthority:(YXUserLevel)authority {
    NSString *text;
    if (authority == YXUserLevelHkBMP) {
        
        text = [YXLanguageUtility kLangWithKey:@"common_bmptips"];
    }else if (authority == YXUserLevelUsDelay || authority == YXUserLevelHkDelay || authority == YXUserLevelCnDelay) {
        
        text = [YXLanguageUtility kLangWithKey:@"trading_delay_tips"];
    }
    QMUILabel *reminderLabel = [[QMUILabel alloc] init];
    reminderLabel.textColor = [QMUITheme textColorLevel4];
    reminderLabel.font = [UIFont systemFontOfSize:12];
    reminderLabel.numberOfLines = 0;
    reminderLabel.backgroundColor = [QMUITheme foregroundColor];
    reminderLabel.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 15, 10);
    reminderLabel.text = text;
    return reminderLabel;
}

- (instancetype)init {
    if (self = [super init]) {
        self.position = YXAuthorityReminderPositionTableViewFooter;
    }
    return self;
}

- (BOOL)isHKDelay {
    return [YXUserManager hkLevel] == YXUserLevelHkDelay;
}

- (BOOL)isUSDelay {
    return [YXUserManager usLevel] == YXUserLevelUsDelay;
}

- (BOOL)isHKBMP {
    return [YXUserManager hkLevel] == YXUserLevelHkBMP;
}

- (BOOL)isHKLevel1 {
    return [YXUserManager hkLevel] == YXUserLevelHkBMP;
}

- (BOOL)isUSLevel1 {
    return [YXUserManager usLevel] == YXUserLevelUsLevel1;
}

- (BOOL)isHKLevel2 {
    return [YXUserManager hkLevel] == YXUserLevelHkLevel2 || [YXUserManager hkLevel] == YXUserLevelHkWorldLevel2;
}

//- (BOOL)isShowReminderDelayText {
//    if ([self.market isEqualToString:kYXMarketHK] && self.)
//    return NO;
//}

//- (BOOL)isShowReminderBMPText {
//    if ([self.market isEqualToString:kYXMarketHK]
//        && [self.rankCode isEqualToString:kYXRANKHKALL] || [self.rankCode isEqualToString:kYXRANKHKALL]) {
//        
//    }
//    return NO;
//}

- (void)addLoginOutObserverWithOperationBlock:(LoginStatusChangeBlock)block {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusChange) name:YXUserManager.notiLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusChange) name:YXUserManager.notiLoginOut object:nil];
    _loginStatusChangeBlock = block;
}

- (void)removeLoginOutObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.loginStatusChangeBlock = nil;
}

- (void)loginStatusChange {
    if (_loginStatusChangeBlock) {
        _loginStatusChangeBlock();
    }
}

- (void)showReminderDelayText {
    [self showReminderWithText:[YXLanguageUtility kLangWithKey:@"trading_delay_tips"]];
}

- (void)showReminderBMPText {
    
    [self showReminderWithText:[YXLanguageUtility kLangWithKey:@"common_bmptips"]];
}

- (void)showReminderText:(NSString *)text {
    [self showReminderWithText:text];
}

- (void)showReminderWithText:(NSString *)text {
    [self.reminderLabel removeFromSuperview];
    
    self.reminderLabel = [self label];
    self.reminderLabel.text = text;
    
    if (self.position == YXAuthorityReminderPositionViewBottom) {
        UIView *superView = nil;
        if ([self.delegate respondsToSelector:@selector(reminderLabelSuperView)]) {
            superView = [self.delegate reminderLabelSuperView];
            [superView addSubview:self.reminderLabel];
            [self.reminderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(superView);
                make.right.equalTo(superView);
                make.bottom.equalTo(superView);
            }];
            
            UITableView *tableView = nil;
            if ([self.delegate respondsToSelector:@selector(needLayoutTableView)]) {
                tableView = [self.delegate needLayoutTableView];
                UIEdgeInsets insets = tableView.contentInset;
                insets.bottom = 35;
                tableView.contentInset = insets;
            }
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(needLayoutTableView)]) {
            UITableView *tableView = [self.delegate needLayoutTableView];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
//            view.backgroundColor = [UIColor redColor];
            view.backgroundColor = QMUITheme.foregroundColor;
            [view addSubview:self.reminderLabel];
//            self.reminderLabel.backgroundColor = [UIColor redColor];
            [self.reminderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(view);
                make.top.mas_equalTo(5);
            }];
            tableView.tableFooterView = view;
        }
    }
}

- (void)setAlignment:(NSTextAlignment)alignment {
    _alignment = alignment;
    self.reminderLabel.textAlignment = alignment;
}

- (void)removeReminderText {
    if (self.position == YXAuthorityReminderPositionViewBottom) {
        if (self.reminderLabel.superview) {
            [self.reminderLabel removeFromSuperview];
            self.reminderLabel = nil;
            UITableView *tableView = nil;
            if ([self.delegate respondsToSelector:@selector(needLayoutTableView)]) {
                tableView = [self.delegate needLayoutTableView];
            }
            UIEdgeInsets insets = tableView.contentInset;
            insets.bottom = insets.bottom - 35;
            tableView.contentInset = insets;
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(needLayoutTableView)]) {
            UITableView *tableView = [self.delegate needLayoutTableView];
            tableView.tableFooterView = nil;
        }
    }
}

- (QMUILabel *)label {
    QMUILabel *reminderLabel = [[QMUILabel alloc] init];
    reminderLabel.textColor = [QMUITheme textColorLevel4];
    reminderLabel.font = [UIFont systemFontOfSize:12];
    reminderLabel.numberOfLines = 0;
    reminderLabel.backgroundColor = QMUITheme.foregroundColor;
    reminderLabel.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 15, 10);

    return reminderLabel;
}

- (NSDictionary *)groupingWithArray:(NSArray<YXAuthorityReminderToolGroupingDelegate> *)array {
    NSMutableArray *bmp = [NSMutableArray array];
    NSMutableArray *delay = [NSMutableArray array];
    NSMutableArray *level1 = [NSMutableArray array];
    NSMutableArray *level2 = [NSMutableArray array];
    NSMutableArray *usnation = [NSMutableArray array];
    
    for (id object in array) {
        if ([object respondsToSelector:@selector(getMarketType)] && [object respondsToSelector:@selector(getSymbol)]) {
            NSString *market = [object getMarketType];
            QuoteLevel level = [[YXUserManager shared] getLevelWith:market];
            if (level == QuoteLevelBmp) {
                [bmp addObject:object];
            } else if (level == QuoteLevelDelay) {
                [delay addObject:object];
            } else if (level == QuoteLevelLevel1) {
                [level1 addObject:object];
            } else if (level == QuoteLevelLevel2) {
                [level2 addObject:object];
            } else if (level == QuoteLevelUsNational) {
                [usnation addObject:object];
            }
        }
    }
    
    return @{@"bmp": [bmp copy],
            @"delay": [delay copy],
            @"level1": [level1 copy],
            @"level2": [level2 copy],
            @"usnation": [usnation copy],
            };
}



@end
