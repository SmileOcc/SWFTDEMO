

//
//  ZFSearchResultMatchTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/12/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchResultMatchTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "Masonry.h"

@interface ZFSearchResultMatchTableViewCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *matchLabel;
@property (nonatomic, strong) UIImageView       *iconImageView;
@property (nonatomic, strong) UIView            *lineView;
@end

@implementation ZFSearchResultMatchTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - private methods
- (void)hightLightMatchKeyForUserInterface {
    NSInteger first = 0, second = 0;
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:self.matchKey];
    while (first < self.searchKey.length && second < self.matchKey.length) {
        NSString *matchStr = [self.matchKey substringWithRange:NSMakeRange(second, 1)];
        NSString *searchStr = [self.searchKey substringWithRange:NSMakeRange(first, 1)];
        if ([[matchStr lowercaseString] isEqualToString:[searchStr lowercaseString]]) {
            if ([matchStr isEqualToString:@" "]) {
                ++first;
                ++second;
                continue;
            }
            [attributeStr addAttribute:NSForegroundColorAttributeName value: ZFC0x2D2D2D() range:NSMakeRange(second, 1)];
            [attributeStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(second, 1)];
            
            ++first;
            ++second;
        } else {
            ++second;
        }
    }
    self.matchLabel.attributedText = attributeStr;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.matchLabel];
    [self.contentView addSubview:self.iconImageView];
//    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.historySearchImageView];
}

- (void)zfAutoLayoutView {
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(12, 12));
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-18);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.matchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
    }];
    
    [self.historySearchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.centerY.mas_equalTo(self.matchLabel.mas_centerY);
        make.leading.mas_equalTo(self.matchLabel.mas_trailing).offset(5);
    }];
    
//    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.trailing.bottom.mas_equalTo(self.contentView);
//        make.height.mas_equalTo(.5f);
//        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
//    }];
}


#pragma mark - setter
- (void)setSearchKey:(NSString *)searchKey {
    _searchKey = searchKey;
    [self hightLightMatchKeyForUserInterface];
}

- (void)setMatchKey:(NSString *)matchKey {
    _matchKey = matchKey;
//    self.matchLabel.text = _matchKey;
}

#pragma mark - getter
- (UILabel *)matchLabel {
    if (!_matchLabel) {
        _matchLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _matchLabel.textColor = ZFC0x666666();
        _matchLabel.font = [UIFont systemFontOfSize:14];
        _matchLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _matchLabel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.image = [UIImage imageNamed:@"match_search_icon"];
    }
    return _iconImageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _lineView;
}

- (UIImageView *)historySearchImageView {
    if (!_historySearchImageView) {
        _historySearchImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _historySearchImageView.image = [UIImage imageNamed:@"historysearch"];
        _historySearchImageView.hidden = YES;
    }
    return _historySearchImageView;
}

@end
