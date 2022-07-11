//
//  YXOrgAccountCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXOrgAccountCell.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXOrgAccountCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *subNameLabel;

@property (nonatomic, strong) UILabel *cardIdLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong) UILabel *forceLabel;
//@property (nonatomic, strong) UILabel *normalLabel;

@property (nonatomic, strong) UIView *section5View;

@end

@implementation YXOrgAccountCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionFillEqually;
    
    [self.contentView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    UIView *section1 = [self creatSingleViewWithTag:0];
    UIView *section2 = [self creatSingleViewWithTag:1];
    UIView *section3 = [self creatSingleViewWithTag:2];
    UIView *section4 = [self creatSingleViewWithTag:3];
    UIView *section5 = [self creatSingleViewWithTag:4];
    
    self.section5View = section5;
    
    [stackView addArrangedSubview:section1];
    [stackView addArrangedSubview:section2];
    [stackView addArrangedSubview:section3];
    [stackView addArrangedSubview:section4];
    [stackView addArrangedSubview:section5];
}


- (UIView *)creatSingleViewWithTag:(NSInteger)tag {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = QMUITheme.foregroundColor;
    
    
    UILabel *titleLabel = [UILabel labelWithText:@"" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16]];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = QMUITheme.separatorLineColor;
    
    UILabel *subLabel = [UILabel labelWithText:@"" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16]];
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_next"]];
    
    UIControl *click = [[UIControl alloc] init];
    click.tag = tag;
    [click addTarget:self action:@selector(clickControl:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:titleLabel];
    [view addSubview:lineView];
    [view addSubview:subLabel];
    [view addSubview:arrowImage];
    [view addSubview:click];
    
    if (tag == 0) {
        titleLabel.text = [YXLanguageUtility kLangWithKey:@"trade_name"];
        subLabel.hidden = YES;
        arrowImage.hidden = YES;
        
        UILabel *label1 = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"trade_sur_name"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:16]];
        UILabel *label2 = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"trade_first_name"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:16]];
        
        UILabel *name1 = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16]];
        UILabel *name2 = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16]];
        
        [view addSubview:name1];
        [view addSubview:name2];
        [view addSubview:label1];
        [view addSubview:label2];
        
        [name2 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(label2.mas_right).offset(10);
            make.right.equalTo(view).offset(-39);
            make.centerY.equalTo(view);
        }];
                
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(name2.mas_left).offset(-10);
            make.centerY.equalTo(view);
        }];
        
        [name1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(label2.mas_left).offset(-10);
            make.centerY.equalTo(view);
        }];
                
        
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(view).offset(-172);
            make.right.equalTo(name1.mas_left).offset(-10);
            make.centerY.equalTo(view);
        }];
//        
//        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(view).offset(-110);
//            make.centerY.equalTo(view);
//        }];
//        
//        [name1 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(label1.mas_right).offset(10);
//            make.centerY.equalTo(view);
//        }];
//        
//        [name2 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(label2.mas_right).offset(10);
//            make.centerY.equalTo(view);
//        }];
        
        self.nameLabel = name1;
        self.subNameLabel = name2;
        
    } else if (tag == 1) {
        titleLabel.text = [YXLanguageUtility kLangWithKey:@"trade_id"];
        arrowImage.hidden = YES;
        [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view);
            make.right.equalTo(view).offset(-39);
        }];
        
        self.cardIdLabel = subLabel;
    } else if (tag == 2) {
        titleLabel.text = [YXLanguageUtility kLangWithKey:@"trade_phone"];
        [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view);
            make.right.equalTo(view).offset(-39);
        }];
        self.phoneLabel = subLabel;
        
    } else if (tag == 3) {
        titleLabel.text = [YXLanguageUtility kLangWithKey:@"trade_email"];
        [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view);
            make.right.equalTo(view).offset(-39);
        }];
        self.emailLabel = subLabel;
    } else if (tag == 4) {
        titleLabel.text = [YXLanguageUtility kLangWithKey:@"trade_status"];
        [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view);
            make.right.equalTo(view).offset(-39);
        }];
        
        self.forceLabel = subLabel;
//        subLabel.hidden = YES;
        
//        UILabel *label1 = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"trade_disable"] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16]];
//        UILabel *label2 = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"trade_normal"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:16]];
//        [view addSubview:label1];
//        [view addSubview:label2];
//
//        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(view).offset(-79);
//            make.centerY.equalTo(view);
//        }];
//
//        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(view).offset(-30);
//            make.centerY.equalTo(view);
//        }];
//
//        self.forceLabel = label1;
//        self.normalLabel = label2;
    }
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(14);
        make.centerY.equalTo(view);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(0);
        make.right.equalTo(view).offset(-0);
        make.bottom.equalTo(view);
        make.height.mas_equalTo(1);
    }];
        
    [arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-14);
        make.centerY.equalTo(view);
    }];
    
    [click mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    return view;
}

- (void)setModel:(YXOrgAccountModel *)model {
    _model = model;
    self.nameLabel.text = model.lastName;
    self.subNameLabel.text = model.firstName;
    self.cardIdLabel.text = model.cardNumber;
    self.phoneLabel.text = model.traderPhone;
    self.emailLabel.text = model.traderEmail;
//    if (model.traderStatus) {
//        self.forceLabel.textColor = QMUITheme.textColorLevel3;
//        self.normalLabel.textColor = QMUITheme.textColorLevel1;
//    } else {
//        self.forceLabel.textColor = QMUITheme.textColorLevel1;
//        self.normalLabel.textColor = QMUITheme.textColorLevel3;
//    }
    
    self.forceLabel.text = model.traderStatus ? [YXLanguageUtility kLangWithKey:@"trade_normal"] : [YXLanguageUtility kLangWithKey:@"trade_disable"];
    
    if (model.isMain) {
        self.section5View.hidden = YES;
    } else {
        self.section5View.hidden = NO;
    }
}

- (void)clickControl:(UIControl *)sender {
    if (sender.tag == 2 || sender.tag == 3) {
        if (self.clickEmailOrPhoneCallBack) {
            self.clickEmailOrPhoneCallBack(self.model);
        }
    } else if (sender.tag == 4) {
        if (self.clickStatusCallBack) {
            self.clickStatusCallBack(self.model);
        }
    }
}

@end
