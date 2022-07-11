//
//  YXTradeGreyListView.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/4/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTradeGreyListView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>


@implementation YXTradeGreyShapeView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectEdgeBottom | UIRectEdgeRight) cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    shape.path = path.CGPath;
    self.layer.mask = shape;
}

@end

@interface YXTradeGreyListHeaderView ()




@end


@implementation YXTradeGreyListHeaderView


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
    self.numberLabel = [UILabel labelWithText:@"(--)：" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];
    self.nameLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14]];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"market_arrow_WhiteSkin"]];
    
    UILabel *label = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"all_grey"] textColor:QMUITheme.themeTextColor textFont:[UIFont systemFontOfSize:14]];
    
    [self addSubview:icon];
    [self addSubview:label];
    [self addSubview:self.numberLabel];
    [self addSubview:self.nameLabel];
    
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-8);
        make.height.width.mas_equalTo(15);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(icon.mas_leading).offset(-10);
    }];
    
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(18);
        make.top.equalTo(self).offset(7);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(18);
        make.bottom.equalTo(self).offset(-7);
        make.trailing.lessThanOrEqualTo(label.mas_leading).offset(-10);
    }];
    

    UIControl *click = [[UIControl alloc] init];
    [click addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:click];
    
    [click mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.clipsToBounds = YES;
}

- (void)click:(UIControl *)sender {
    if (self.clickCallBack) {
        self.clickCallBack();
    }
}

@end


@interface YXTradeGreyListCell: UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *symbolLabel;

@property (nonatomic, strong) UILabel *rocLabel;

@property (nonatomic, strong) YXV2Quote *quote;

@end

@implementation YXTradeGreyListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.backgroundColor = QMUITheme.popupLayerColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.nameLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16]];
    self.symbolLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];
    self.priceLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.stockGrayColor textFont:[UIFont systemFontOfSize:16]];
    self.rocLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.stockGrayColor textFont:[UIFont systemFontOfSize:16]];
    
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.rocLabel];
    [self.contentView addSubview:self.symbolLabel];
    [self.contentView addSubview:self.nameLabel];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-92);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.rocLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-12);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.lessThanOrEqualTo(self.priceLabel.mas_leading).offset(-10);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(18);
        make.centerY.equalTo(self.contentView);
        make.trailing.lessThanOrEqualTo(self.symbolLabel.mas_leading).offset(-10);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = QMUITheme.separatorLineColor;
    
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(8);
        make.trailing.equalTo(self.contentView).offset(-8);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    
}

- (void)setQuote:(YXV2Quote *)quote {
    _quote = quote;
    NSInteger priceBase = quote.priceBase.value;
    self.nameLabel.text = [NSString stringWithFormat:@"%@", quote.name];
    self.symbolLabel.text = quote.symbol;
    self.priceLabel.text = [YXToolUtility stockPriceData:quote.latestPrice.value deciPoint:priceBase priceBase:priceBase];
    //涨跌幅
    NSString *roc= [YXToolUtility stockPercentData:quote.pctchng.value priceBasic:2 deciPoint:2];
    self.rocLabel.text = quote.pctchng ? (quote.pctchng.value > 0 ? [NSString stringWithFormat:@"%@", roc] : [NSString stringWithFormat:@"%@", roc]) : @"--";
    UIColor *color = [YXToolUtility stockColorWithData:quote.pctchng.value compareData:0];
    
    self.priceLabel.textColor = color;
    self.rocLabel.textColor = color;
    
}


@end


@interface YXTradeGreyListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YXTradeGreyShapeView *bgView;
@property (nonatomic, strong) UITableView *tableView;

@end


@implementation YXTradeGreyListView


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

- (void)setArr:(NSArray *)arr {
    _arr = arr;
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50 + arr.count * 50);
    }];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YXTradeGreyListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YXTradeGreyListCell" forIndexPath:indexPath];
    cell.quote = self.arr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YXV2Quote *quote = self.arr[indexPath.row];
    if (self.selectStockCallBack) {
        self.selectStockCallBack(quote);
    }
}

#pragma mark - 设置UI
- (void)setUI {
    self.clipsToBounds = YES;
    self.bgView.backgroundColor = UIColor.whiteColor;
    [self.tableView registerClass:[YXTradeGreyListCell class] forCellReuseIdentifier:@"YXTradeGreyListCell"];
    
    UIControl *tapControl = [[UIControl alloc] init];
    [tapControl addTarget:self action:@selector(tapClick:) forControlEvents:UIControlEventTouchUpInside];
    tapControl.backgroundColor = QMUITheme.shadeLayerColor;
    
    [self addSubview:self.bgView];
    [self addSubview:tapControl];
    [self.bgView addSubview:self.tableView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self).offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    [tapControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self);
        make.top.equalTo(self.bgView.mas_bottom).offset(-20);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView).offset(20);
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self.bgView).offset(-30);
    }];

    [self bringSubviewToFront:self.bgView];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)tapClick:(UIControl *)sender {
    [self dismiss];
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.scrollEnabled = false;
    }
    return _tableView;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[YXTradeGreyShapeView alloc] init];
    }
    return _bgView;
}

@end
