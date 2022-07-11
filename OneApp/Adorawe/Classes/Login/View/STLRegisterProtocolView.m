//
//  STLRegisterProtocolView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLRegisterProtocolView.h"

@interface STLRegisterProtocolView()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation STLRegisterProtocolView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
        self.backgroundColor = [OSSVThemesColors col_000000:0.3];;
        
        NSArray *datas = @[@{@"state":@0,
                             @"title":STLLocalizedString_(@"I_agree_Term_Use_Privacy_Policy", nil),
                             @"msg":STLLocalizedString_(@"registration_agree_App_Terms_Use", nil)},
                           
                           @{@"state":@0,
                             @"title":STLLocalizedString_(@"submitting_confirm_information_understand_agree_App_Privacy_Policy", nil),
                             @"msg":STLLocalizedString_(@"registration_must_agree_consent_above", nil)}];
        self.serviceDatas = [[NSMutableArray alloc] initWithArray:datas];
        
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.protocolTable];
        [self.contentView addSubview:self.cancelButton];
        [self.contentView addSubview:self.sureButton];
        [self.contentView addSubview:self.lineView];
        [self.contentView addSubview:self.verLineView];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(20);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-20);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(300);
        }];
        
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_centerX);
            make.bottom.mas_equalTo(self.contentView);
            make.height.mas_equalTo(44);
        }];
        
        [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.leading.mas_equalTo(self.contentView.mas_centerX);
            make.bottom.mas_equalTo(self.contentView);
            make.height.mas_equalTo(self.cancelButton.mas_height);
        }];
        
        [self.protocolTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(10);
            make.bottom.mas_equalTo(self.cancelButton.mas_top).mas_offset(-10);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.bottom.mas_equalTo(self.cancelButton.mas_top);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.verLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.top.bottom.mas_equalTo(self.cancelButton);
            make.width.mas_equalTo(0.5);
        }];
    }
    return self;
}

- (void)show:(UIView *)superView{
    if (self.superview) {
        [self removeFromSuperview];
        self.hidden = YES;
    } else {
        if (superView) {
            self.hidden = NO;
            [superView addSubview:self];
        }
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.serviceDatas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STLRegisterProtocolCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(STLRegisterProtocolCell.class)];
    [cell updateCellDic:self.serviceDatas[indexPath.row] isSure:self.isSure];
    @weakify(self)
    cell.protocolBlock = ^(STLRegisterProtocolCell *cell, RegisterProtocolEvent event) {
      @strongify(self)
        if (event == RegisterProtocolEventSelected) {
            [self updateSelectState:cell];
            
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(registerProtocol:event:)]) {
                [self.delegate registerProtocol:self event:event];
            }
        }
    };
    return cell;
}

#pragma mark - Action

- (void)updateSelectState:(STLRegisterProtocolCell *)cell {
    
    NSIndexPath *indexPath = [self.protocolTable indexPathForCell:cell];
    if (self.serviceDatas.count > 0) {
        NSMutableDictionary *serviceDic = [[NSMutableDictionary alloc] initWithDictionary:self.serviceDatas[indexPath.row]];
        serviceDic[@"state"] = [serviceDic[@"state"] integerValue] == 1 ? @0 : @1;
        [self.serviceDatas replaceObjectAtIndex:indexPath.row withObject:serviceDic];
        [self.protocolTable reloadData];
    }
}

- (void)actionCancel:(UIButton *)sender {
    [self show:nil];
}

- (void)actionSure:(UIButton *)sender {
    
    __block BOOL isAllSelected = YES;
    [self.serviceDatas enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"state"] integerValue] == 0) {
            isAllSelected = NO;
            *stop = YES;
        }
    }];
    
    self.isSure = YES;
    if (isAllSelected) {
        self.isAllSelected = YES;
        [self show:nil];
        if (self.delegate && [self.delegate respondsToSelector:@selector(registerProtocol:event:)]) {
            [self.delegate registerProtocol:self event:RegisterProtocolEventSure];
        }
    } else {
        [self.protocolTable reloadData];
    }
}

#pragma mark - LazyLoad

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = OSSVThemesColors.col_FFFFFF;
    }
    return _contentView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (APP_TYPE == 3) {
            [_cancelButton setTitle:STLLocalizedString_(@"cancel", nil) forState:UIControlStateNormal];
        } else {
            [_cancelButton setTitle:STLLocalizedString_(@"cancel", nil).uppercaseString forState:UIControlStateNormal];
        }
        [_cancelButton setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _cancelButton;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (APP_TYPE == 3) {
            [_sureButton setTitle:STLLocalizedString_(@"sure", nil) forState:UIControlStateNormal];
        } else {
            [_sureButton setTitle:STLLocalizedString_(@"sure", nil).uppercaseString forState:UIControlStateNormal];
        }
        [_sureButton setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(actionSure:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

- (UITableView *)protocolTable {
    if (!_protocolTable) {
        _protocolTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _protocolTable.delegate = self;
        _protocolTable.dataSource = self;
        [_protocolTable registerClass:[STLRegisterProtocolCell class] forCellReuseIdentifier:NSStringFromClass(STLRegisterProtocolCell.class)];
        _protocolTable.estimatedRowHeight = 140.0;
        _protocolTable.rowHeight = UITableViewAutomaticDimension;
        _protocolTable.bounces = NO;
        _protocolTable.showsVerticalScrollIndicator = NO;
        _protocolTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _protocolTable.backgroundColor = [UIColor clearColor];
    }
    return _protocolTable;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [OSSVThemesColors col_CCCCCC];
    }
    return _lineView;
}

- (UIView *)verLineView {
    if (!_verLineView) {
        _verLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _verLineView.backgroundColor = [OSSVThemesColors col_CCCCCC];
    }
    return _verLineView;
}

@end






@implementation STLRegisterProtocolCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.selectButton];
        [self.contentView addSubview:self.conditionLabel];
        [self.contentView addSubview:self.msgLabel];
        
        self.iconImageView.backgroundColor = STLCOLOR_RANDOM;
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(16);
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(10);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.centerY.mas_equalTo(self.iconImageView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [self.conditionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.iconImageView.mas_trailing).mas_offset(5);
            make.top.mas_equalTo(self.iconImageView.mas_top);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-16);
        }];
        
        [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.iconImageView.mas_leading);
            make.top.mas_equalTo(self.conditionLabel.mas_bottom).mas_offset(10);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-16);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-10);
        }];
      
    }
    return self;
}

- (void)updateCellDic:(NSDictionary *)contentDic isSure:(BOOL)sure {
    
    self.iconImageView.image = [contentDic[@"state"] integerValue] == 1 ?  [UIImage imageNamed:@"address_isDefault"] :  [UIImage imageNamed:@"address_notDefault"];
    
    NSMutableParagraphStyle *paragraphStyle  =[[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;//连字符
    NSDictionary *attrDict =@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                              NSForegroundColorAttributeName:OSSVThemesColors.col_333333,
                              NSParagraphStyleAttributeName:paragraphStyle};
    
    NSMutableAttributedString *conditionAtt = [[NSMutableAttributedString alloc] initWithString:contentDic[@"title"] attributes:attrDict];
    NSRange termUsRange = [conditionAtt.string rangeOfString:STLLocalizedString_(@"Term_of_Use", nil)];
    NSRange privacyRange = [conditionAtt.string rangeOfString:STLLocalizedString_(@"PrivacyPolicy", nil)];
    
    YYTextDecoration *decoration = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle
                                                                   width:@(0.5)
                                                                   color:OSSVThemesColors.col_333333];
    
    if (termUsRange.location != NSNotFound) {
        [conditionAtt yy_setTextHighlightRange:termUsRange
                                         color:OSSVThemesColors.col_333333
                               backgroundColor:[UIColor clearColor]
                                     tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                                         [self toucheEvent:RegisterProtocolEventTerm];
                                         
                                     }];
        
        [conditionAtt yy_setTextUnderline:decoration range:termUsRange];
    }
    
    if (privacyRange.location != NSNotFound) {
        [conditionAtt yy_setTextHighlightRange:privacyRange
                                         color:OSSVThemesColors.col_333333
                               backgroundColor:[UIColor clearColor]
                                     tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                                         
                                         [self toucheEvent:RegisterProtocolEventPolicy];
                                         
                                     }];
        [conditionAtt yy_setTextUnderline:decoration range:privacyRange];
    }
    
    self.conditionLabel.attributedText = conditionAtt;
    
    
    self.msgLabel.text = contentDic[@"msg"];

    //确认过
    if (sure) {
        self.msgLabel.textColor = [contentDic[@"state"] integerValue] == 1 ? OSSVThemesColors.col_999999 : [UIColor redColor];
    } else {
        self.msgLabel.textColor = OSSVThemesColors.col_999999;
    }
}


#pragma mark - Action

- (void)toucheEvent:(RegisterProtocolEvent)event {
    if (self.protocolBlock) {
        self.protocolBlock(self,event);
    }
}

- (void)actionSelect:(UIButton *)sender {
    [self toucheEvent:RegisterProtocolEventSelected];
}

#pragma mark - LazyLoad

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _iconImageView;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton addTarget:self action:@selector(actionSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (YYLabel *)conditionLabel {
    if (!_conditionLabel) {
        _conditionLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        _conditionLabel.textColor = OSSVThemesColors.col_333333;
        _conditionLabel.font = [UIFont systemFontOfSize:14];
        _conditionLabel.numberOfLines = 0;
        _conditionLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 57 - 32;
    }
    return _conditionLabel;
}

- (YYLabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        _msgLabel.textColor = OSSVThemesColors.col_666666;
        _msgLabel.font = [UIFont systemFontOfSize:12];
        _msgLabel.numberOfLines = 0;
        _msgLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 32 - 32;
    }
    return _msgLabel;
}


@end
