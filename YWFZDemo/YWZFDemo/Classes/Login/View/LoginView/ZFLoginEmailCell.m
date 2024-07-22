//
//  YWLoginEmailCell.m
//  ZZZZZ
//
//  Created by YW on 2018/8/20.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "YWLoginEmailCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "Constants.h"

@interface YWLoginEmailCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel   *emailLabel;
@property (nonatomic, strong) UIView    *lineView;
@end

@implementation YWLoginEmailCell
+ (YWLoginEmailCell *)loginEmailCellWith:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[self class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.emailLabel];
    [self.contentView addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - Setter
- (void)setEmail:(NSString *)email {
    _email = email;
    self.emailLabel.text = email;
}

#pragma mark - Getter
- (UILabel *)emailLabel {
    if (!_emailLabel) {
        _emailLabel = [[UILabel alloc] init];
        _emailLabel.backgroundColor = ZFCOLOR_WHITE;
        _emailLabel.font = ZFFontSystemSize(16);
        _emailLabel.textColor = ZFCOLOR(45, 45, 45, 1);
    }
    return _emailLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    }
    return _lineView;
}

@end
