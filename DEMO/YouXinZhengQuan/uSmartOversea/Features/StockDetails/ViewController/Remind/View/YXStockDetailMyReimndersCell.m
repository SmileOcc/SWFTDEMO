//
//  YXStockDetailMyReimndersCell.m
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/11/21.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXStockDetailMyReimndersCell.h"
#import "YXReminderModel.h"
//#import "YXShadowView.h"
#import "YXReminderSingleView.h"
#import <Masonry/Masonry.h>
#import "YXReminderStockView.h"

@interface YXStockDetailMyReimndersCell ()

@property (nonatomic, strong) YXExpandAreaButton *editButton; //编辑按钮
@property (nonatomic, strong) YXExpandAreaButton *deleteButton; //删除按钮
@property (nonatomic, strong) YXExpandAreaButton *foldButton; //折叠按钮
@property (nonatomic, strong) UIStackView *conditionContaintView;
@property (nonatomic, strong) YXReminderStockView *stockView;

@end

@implementation YXStockDetailMyReimndersCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
 
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
    
}

- (void)initUI{
    
    //1.1 股票名/股价/涨跌幅/涨跌额
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = QMUITheme.foregroundColor;
    
    [self.contentView addSubview:self.stockView];
    [self.contentView addSubview:self.deleteButton];
    [self.contentView addSubview:self.editButton];
    [self.contentView addSubview:self.conditionContaintView];
    [self.contentView addSubview:self.foldButton];
    
    [self.stockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.height.mas_equalTo(77);
    }];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
        make.width.height.mas_equalTo(18);
        make.centerY.equalTo(self.stockView);
    }];
    
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.stockView).offset(-58);
        make.width.height.mas_equalTo(18);
        make.centerY.equalTo(self.stockView);
    }];
                
    [self.conditionContaintView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(0);
        make.right.equalTo(self.contentView).offset(-0);
        make.top.equalTo(self.stockView.mas_bottom);
    }];
        
    [self.foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-16);
        make.width.height.mas_equalTo(15);
    }];
    self.foldButton.hidden = YES;
}

#pragma mark - lazy load

- (YXReminderStockView *)stockView {
    if (!_stockView) {
        _stockView = [[YXReminderStockView alloc] init];
    }
    return _stockView;
}

//编辑按钮
- (YXExpandAreaButton *)editButton{
    if (!_editButton) {
        _editButton = [YXExpandAreaButton buttonWithType:UIButtonTypeCustom image:[UIImage imageNamed:@"reminder_edit"] target:self action:@selector(editButtonEvent)];
        _editButton.expandX = 5;
        _editButton.expandY = 5;
    }
    return _editButton;
}

- (void)editButtonEvent{
    if (self.editRemindCommand) {
        [self.editRemindCommand execute:@{@"market" : [NSString stringWithFormat:@"%@", self.remindModel.quotaModel.market], @"symbol" : [NSString stringWithFormat:@"%@", self.remindModel.quotaModel.symbol], @"name" : self.remindModel.quotaModel.name}];
    }
}

//删除按钮
- (YXExpandAreaButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [YXExpandAreaButton buttonWithType:UIButtonTypeCustom image:[UIImage imageNamed:@"remind_delete"] target:self action:@selector(deleteButtonEvent)];
        _deleteButton.expandX = 5;
        _deleteButton.expandY = 5;
    }
    return _deleteButton;
}

- (void)deleteButtonEvent {
    if (self.deleteRemindCommand) {
        [self.deleteRemindCommand execute:@{@"market" : self.remindModel.quotaModel.market, @"symbol" : self.remindModel.quotaModel.symbol, @"name" : self.remindModel.quotaModel.name}];
    }
}

- (YXExpandAreaButton *)foldButton {
    if (!_foldButton) {
        _foldButton = [YXExpandAreaButton buttonWithType:UIButtonTypeCustom];
        [_foldButton setImage:[UIImage imageNamed:@"market_arrow_WhiteSkin"] forState:UIControlStateNormal];
        [_foldButton addTarget:self action:@selector(foldButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        _foldButton.expandX = (YXConstant.screenWidth - 20 - 15) * 0.5;
        _foldButton.expandY = 15;
    }
    return _foldButton;
}

- (void)foldButtonEvent:(UIButton *)sender {
    sender.selected = !sender.selected;
    _remindModel.isUnfold = sender.selected;
    if (sender.selected) {
        sender.imageView.transform =  CGAffineTransformMakeRotation(M_PI);
    } else {
        sender.imageView.transform =  CGAffineTransformIdentity;
    }
    if (self.foldRemindCommand) {
        [self.foldRemindCommand execute:@{@"isOpen" : @(sender.selected)}];
    }
}

- (UIStackView *)conditionContaintView {
    if (_conditionContaintView == nil) {
        _conditionContaintView = [[UIStackView alloc] init];
        _conditionContaintView.distribution = UIStackViewDistributionFillEqually;
        _conditionContaintView.axis = UILayoutConstraintAxisVertical;
    }
    return _conditionContaintView;
}

- (void)setFrame:(CGRect)frame {
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - 8);
    [super setFrame:rect];
}

#pragma mark - set

- (void)setRemindModel:(YXReminderListModel *)remindModel{
    
    _remindModel = remindModel;
    
    self.stockView.quote = remindModel.quotaModel;
    
    NSInteger count = remindModel.stockNtfs.count + remindModel.stockForms.count;
    if (count > kFolderCount) {
        self.foldButton.hidden = NO;
        self.foldButton.selected = remindModel.isUnfold;
        if (self.foldButton.selected == NO) {
            self.foldButton.imageView.transform = CGAffineTransformIdentity;
        }
    } else {
        self.foldButton.hidden = YES;
    }

    for (UIView *view in self.conditionContaintView.subviews) {
        [view removeFromSuperview];
    }
    for (YXReminderModel *model in remindModel.stockNtfs) {
        
        if (!remindModel.isUnfold && self.conditionContaintView.subviews.count >= kFolderCount) {
            break;
        }
        
        YXReminderSingleView *view = [[YXReminderSingleView alloc] init];
        view.isMyRemind = YES;
        view.model = model;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kSubTypeViewHeight);
        }];
        [self.conditionContaintView addArrangedSubview:view];
    }
    for (YXReminderModel *model in remindModel.stockForms) {
        if (!remindModel.isUnfold && self.conditionContaintView.subviews.count >= kFolderCount) {
            break;
        }
        YXReminderSingleView *view = [[YXReminderSingleView alloc] init];
        view.isMyRemind = YES;
        view.model = model;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kSubTypeViewHeight);
        }];
        [self.conditionContaintView addArrangedSubview:view];
    }
}

- (void)setEditRemindCommand:(RACCommand *)editRemindCommand{
    _editRemindCommand = editRemindCommand;
}

- (void)setDeleteRemindCommand:(RACCommand *)deleteRemindCommand{
    _deleteRemindCommand = deleteRemindCommand;
}

- (void)setFoldRemindCommand:(RACCommand *)foldRemindCommand {
    _foldRemindCommand = foldRemindCommand;
}


@end
