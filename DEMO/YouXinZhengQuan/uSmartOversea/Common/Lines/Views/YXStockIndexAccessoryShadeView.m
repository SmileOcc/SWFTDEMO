//
//  YXKlineStockIndexAccessoryShadeView.m
//  YouXinZhengQuan
//
//  Created by lennon on 2021/8/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXStockIndexAccessoryShadeView.h"
//#import "YXWebViewModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "UILabel+create.h"

@interface YXStockIndexAccessoryShadeView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) AccessoryButtonType type;

@end

@implementation YXStockIndexAccessoryShadeView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}


#pragma mark - 设置UI
- (void)setUI {
    
    self.titleLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"stock_index_real_detail_des"] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.button = [[UIButton alloc] init];
    [self.button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.button.titleLabel setTextColor:QMUITheme.textColorLevel1];
    self.button.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.button.titleLabel.minimumScaleFactor = 0.3;
    [self.button setTitle:[YXLanguageUtility kLangWithKey:@"open_Acct"] forState:UIControlStateNormal];
    if ([YXUserManager isLogin] == NO) {
        [self.button setTitle:[YXLanguageUtility kLangWithKey:@"login_goLogin"] forState:UIControlStateNormal];
    }
   
    [self.button setBackgroundColor:QMUITheme.themeTextColor];
    self.button.layer.cornerRadius = 4;
    self.button.layer.masksToBounds = YES;

    @weakify(self);
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        switch (self.type) {
            case KICKBUTTON:
                [YXQuoteKickTool.shared getUserQuoteLevelRequestWithActivateToken:YES resultBock:nil];
                break;
            case OPENACCOUNTBUTTON:
                if (![YXUserManager isLogin]) {
                    [YXToolUtility handleBusinessWithLogin:^{
                        if (![YXUserManager canTrade]) {
                            [YXWebViewModel pushToWebVC:[YXH5Urls YX_OPEN_ACCOUNT_URL]];
                        }
                    }];
                } else {
                    [YXWebViewModel pushToWebVC:[YXH5Urls YX_OPEN_ACCOUNT_URL]];
                }
                break;
            case QUOTESTATEMENTBUTTON:
            {
                [YXUSAuthStateWebViewModel pushToWebVCForOC];
                break;
            }
            default:
                break;
        }
        
    }];
    
    self.backgroundColor = [QMUITheme.foregroundColor colorWithAlphaComponent:0.8];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
//    self.imageView.layer.masksToBounds = true;
    
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.button];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(-16);
        make.centerX.equalTo(self);
        make.left.mas_equalTo(60);
        make.right.mas_offset(-60);
    }];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(16);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(115);
        make.height.mas_equalTo(40);
    }];
}

//-(void)setTitle:(NSString*)title isLandscape:(BOOL)isLandscape {
//
//    self.titleLabel.text = title;
//
//    NSString *imageName = @"";
//
//    if (isLandscape) {
//        imageName = @"no_authority_landscape_WhiteSkin";
//    } else {
//        imageName = @"no_authority_portrait_WhiteSkin";
//    }
//
//    self.imageView.image = [UIImage imageNamed:imageName];
//}
//
//-(void)setIsKick:(BOOL)isKick {
//    _isKick = isKick;
//    self.titleLabel.text = isKick? [YXLanguageUtility kLangWithKey:@"stock_index_other_login"] : [YXLanguageUtility kLangWithKey:@"stock_index_quote_vs"];
//    [self.button setTitle:isKick ? [YXLanguageUtility kLangWithKey:@"stock_index_get_authority"] : [YXLanguageUtility kLangWithKey:@"stock_index_prompt_open_account"] forState:UIControlStateNormal];
//}

-(void)setLandscape:(BOOL)isLandscape {

    NSString *imageName = @"";
    if (isLandscape) {
        imageName = @"no_authority_landscape";
    } else {
        imageName =  @"no_authority_portrait";
    }
    self.imageView.image = [UIImage imageNamed:imageName];
}


-(void)setButtonType:(AccessoryButtonType)type{
    _type = type;
    
    switch (type) {
        case KICKBUTTON:
            self.titleLabel.text = [YXLanguageUtility kLangWithKey:@"stock_index_other_login"];
            [self.button setTitle:  [YXLanguageUtility kLangWithKey:@"stock_index_get_authority"] forState:UIControlStateNormal];
            break;
        case OPENACCOUNTBUTTON:
            self.titleLabel.text = [YXLanguageUtility kLangWithKey:@"stock_index_real_detail_des"] ;
            [self.button setTitle: [YXLanguageUtility kLangWithKey:@"stock_index_prompt_open_account"] forState:UIControlStateNormal];
            break;
        case OPENACCOUNTVSBUTTON:
            self.titleLabel.text = [YXLanguageUtility kLangWithKey:@"stock_index_quote_vs"] ;
            [self.button setTitle: [YXLanguageUtility kLangWithKey:@"stock_index_prompt_open_account"] forState:UIControlStateNormal];
            break;
        case QUOTESTATEMENTBUTTON:
            self.titleLabel.text = [YXLanguageUtility kLangWithKey:@"optionQuoteStatement"];
            [self.button setTitle: [YXLanguageUtility kLangWithKey:@"optionQuoteStatementGo"] forState:UIControlStateNormal];
            self.imageView.image = [UIImage imageNamed:@"quote_tip"];
            break;
        default:
            break;
    }
}

@end





