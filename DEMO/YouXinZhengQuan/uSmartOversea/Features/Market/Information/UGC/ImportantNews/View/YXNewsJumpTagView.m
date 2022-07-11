//
//  YXNewsJumpTagView.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2021/1/22.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXNewsJumpTagView.h"
#import "YXListNewsModel.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"


@interface YXNewsJumpTagButton : UIButton
@property (nonatomic, strong) YXListNewsJumpTagModel *model;
@end

@implementation YXNewsJumpTagButton

@end

@interface YXNewsJumpTagView ()

@property (nonatomic, strong) UIStackView *stackView;

@end

@implementation YXNewsJumpTagView


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
    self.stackView = [[UIStackView alloc] init];
    self.stackView.axis = UILayoutConstraintAxisHorizontal;
    self.stackView.distribution = UIStackViewDistributionEqualSpacing;
    self.stackView.spacing = 4;
    self.stackView.alignment = UIStackViewAlignmentLeading;
    [self addSubview:self.stackView];
    
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
    }];
}

- (void)setList:(NSArray *)list {
    
    _list = list;
    
    for (UIView *view in self.stackView.subviews) {
        [view removeFromSuperview];
    }
    
    for (YXListNewsJumpTagModel *model in list) {
        if (model.jump_type > 0) {
            YXNewsJumpTagButton *btn = [[YXNewsJumpTagButton alloc] init];
            btn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
            UIColor *color = [UIColor qmui_colorWithHexString:@"#FF7127"];
            [btn setTitle:[NSString stringWithFormat:@" #%@ ", model.content] forState:UIControlStateNormal];
            [btn setTitleColor:color forState:UIControlStateNormal];
            btn.layer.cornerRadius = 1;
            btn.layer.borderColor = color.CGColor;
            btn.layer.borderWidth = 0.5;
            btn.clipsToBounds = YES;
            btn.model = model;
            [btn addTarget:self action:@selector(jumpClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.stackView addArrangedSubview:btn];
        }
    }
}

- (void)jumpClick:(YXNewsJumpTagButton *)sender {
    if (self.tagJumpCallBack) {
        self.tagJumpCallBack(sender.model);
    }
}

@end
