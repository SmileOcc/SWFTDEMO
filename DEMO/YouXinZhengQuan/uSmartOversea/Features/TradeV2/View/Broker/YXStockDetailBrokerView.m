//
//  YXStockDetailBrokerView.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2019/9/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXStockDetailBrokerView.h"
#import "ASPopover.h"
//#import "YXExpandAreaButton.h"

#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>

//MARK: =============== 1.YXStockDetailBrokerHeaderView
@interface YXStockDetailBrokerHeaderView : UIView
@property (nonatomic, strong) UILabel *bidTypeLabel;
@property (nonatomic, strong) UILabel *askTypeLabel;
@property (nonatomic, strong) YXStockDetailAskBidPopoverButton *typeButton;

@property (nonatomic, strong) RACCommand *gradeTypeShiftCommand;

@property (nonatomic, copy) void (^typeCallBack)(NSInteger num);

@end


@implementation YXStockDetailBrokerHeaderView


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
    self.backgroundColor = [QMUITheme foregroundColor];
    [self addSubview:self.bidTypeLabel];
    [self addSubview:self.askTypeLabel];
    [self addSubview:self.typeButton];
    
    [self.bidTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.mas_left).offset(8);
    }];
    [self.askTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(self.mas_right).offset(-8);
    }];
    [self.typeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.center);
        make.width.height.mas_equalTo(20);
    }];
}

- (UILabel *)bidTypeLabel {
    if (!_bidTypeLabel) {
        //@"买盘经纪"
        _bidTypeLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"stock_broker_buy"] textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:14]];
    }
    return _bidTypeLabel;
}

- (UILabel *)askTypeLabel {
    if (!_askTypeLabel) {
        //@"卖盘经纪"
        _askTypeLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"stock_broker_sell"] textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:14]];
    }
    return _askTypeLabel;
}

- (YXStockDetailAskBidPopoverButton *)typeButton {
    if (!_typeButton) {
        _typeButton = [[YXStockDetailAskBidPopoverButton alloc] initWithFrame:CGRectZero titles: @[@"5", @"10", @"40"]];
        
        @weakify(self)
        _typeButton.clickItemBlock = ^(NSInteger index) {
            @strongify(self)
            NSString *string;
            switch (index) {
                case 0:
                    string = @"5";
                    break;
                case 1:
                    string = @"10";
                    break;
                case 2:
                    string = @"40";
                    break;
                
                default:
                    break;
            }
            if (self.typeCallBack) {
                self.typeCallBack(string.integerValue);
            }
        };
    }
    return _typeButton;
}

@end

//MARK: =============== 2.YXStockDetailBrokerViewCell
@interface YXStockDetailBrokerViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *idLabel;

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation YXStockDetailBrokerViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
    
}

- (void)initUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.backgroundColor = UIColor.clearColor;
//    self.contentView.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.idLabel];
    [self.contentView addSubview:self.nameLabel];
    
    [self.idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(8);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(54);
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-2);
    }];
}


- (UILabel *)idLabel {
    if (!_idLabel) {
        _idLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:12]];
    }
    return _idLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:12]];
        _nameLabel.adjustsFontSizeToFitWidth = YES;
        _nameLabel.minimumScaleFactor = 0.3;
    }
    return _nameLabel;
}

@end

//MARK: =============== 3.YXStockDetailBrokerView
@interface YXStockDetailBrokerView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YXStockDetailBrokerHeaderView *headerView;

@property (nonatomic, strong) YXTableView *bidTableView;

@property (nonatomic, strong) YXTableView *askTableView;

@property (nonatomic, assign) NSInteger rowNum;

@end

@implementation YXStockDetailBrokerView


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
    self.rowNum = 5;
    [self addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(32);
    }];
    
    [self addSubview:self.bidTableView];
    [self addSubview:self.askTableView];
    
    [self.bidTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.equalTo(self);
        make.top.equalTo(self).offset(32);
        make.trailing.equalTo(self.mas_centerX);
    }];
    
    [self.askTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.equalTo(self);
        make.top.equalTo(self).offset(32);
        make.leading.equalTo(self.mas_centerX);
    }];
}

- (void)reloadData {
    
    [self.bidTableView reloadData];
    [self.askTableView reloadData];
}


- (void)setPosBroker:(PosBroker *)posBroker {
    _posBroker = posBroker;
    [self reloadData];
}

#pragma mark - delegate&datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YXStockDetailBrokerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YXStockDetailBrokerViewCell"];

    if (tableView == self.bidTableView) {
        if (indexPath.row < self.posBroker.brokerData.bidBroker.count) {
            BrokerDetail *model = self.posBroker.brokerData.bidBroker[indexPath.row];
            if ([model.Id containsString:@"s"]) {
                cell.idLabel.text = [model.Id stringByReplacingOccurrencesOfString:@"s" withString:@""];
            } else {
                cell.idLabel.text = model.Id;
            }
            cell.nameLabel.text = model.Name;
        } else {
            cell.idLabel.text = @"";
            cell.nameLabel.text = @"";
        }
        cell.backgroundColor = [[QMUITheme buyColor] colorWithAlphaComponent:0.05];
    } else {
        if (indexPath.row < self.posBroker.brokerData.askBroker.count) {
            BrokerDetail *model = self.posBroker.brokerData.askBroker[indexPath.row];
            if ([model.Id containsString:@"s"]) {
                cell.idLabel.text = [model.Id stringByReplacingOccurrencesOfString:@"s" withString:@""];
            } else {
                cell.idLabel.text = model.Id;
            } 
            cell.nameLabel.text = model.Name;
        } else {
            cell.idLabel.text = @"";
            cell.nameLabel.text = @"";
        }
        cell.backgroundColor = [[QMUITheme sellColor] colorWithAlphaComponent:0.05];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return [UIView new];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 22;
}


#pragma mark - 懒加载
- (YXStockDetailBrokerHeaderView *)headerView {
    if (_headerView == nil) {
        _headerView = [[YXStockDetailBrokerHeaderView alloc] init];
        @weakify(self);
        [_headerView setTypeCallBack:^(NSInteger num) {
            @strongify(self);
            self.rowNum = num;
            [self reloadData];
            if (self.gradeTypeShiftCommand) {
                [self.gradeTypeShiftCommand execute:@(num)];
            }
        }];
    }
    return _headerView;
}

#pragma mark - lazy
- (YXTableView *)bidTableView {
    if (!_bidTableView) {
        _bidTableView = [[YXTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_bidTableView registerClass:[YXStockDetailBrokerViewCell class] forCellReuseIdentifier:@"YXStockDetailBrokerViewCell"];
        _bidTableView.delegate = self;
        _bidTableView.dataSource = self;
        _bidTableView.backgroundColor = [QMUITheme foregroundColor];
        _bidTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _bidTableView.scrollEnabled = NO;
    }
    return _bidTableView;
}

- (YXTableView *)askTableView {
    if (!_askTableView) {
        _askTableView = [[YXTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_askTableView registerClass:[YXStockDetailBrokerViewCell class] forCellReuseIdentifier:@"YXStockDetailBrokerViewCell"];
        _askTableView.delegate = self;
        _askTableView.dataSource = self;
        _askTableView.backgroundColor = [QMUITheme foregroundColor];
        _askTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _askTableView.scrollEnabled = NO;
    }
    return _askTableView;
}

@end
