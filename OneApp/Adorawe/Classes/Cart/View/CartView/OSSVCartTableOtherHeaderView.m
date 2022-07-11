//
//  OSSVCartTableOtherHeaderView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartTableOtherHeaderView.h"

@implementation OSSVCartTableOtherHeaderView

+ (OSSVCartTableOtherHeaderView *)cartHeaderViewWithTableView:(UITableView *)tableView {
    [tableView registerClass:[OSSVCartTableOtherHeaderView class] forHeaderFooterViewReuseIdentifier:@"OSSVCartTableOtherHeaderView"];
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"OSSVCartTableOtherHeaderView"];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
//        [self addSubview:self.titleLabel];
//        [self addSubview:self.lineView];
//
//        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
//            make.centerY.mas_equalTo(self.mas_centerY);
//        }];
//        
//        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(self.mas_leading);
//            make.trailing.mas_equalTo(self.mas_trailing);
//            make.bottom.mas_equalTo(self.mas_bottom);
//            make.height.mas_equalTo(@(0.5));
//        }];
    }
    return self;
}

#pragma mark - LazyLoad

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont boldSystemFontOfSize:13];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.text = STLLocalizedString_(@"Other_Products",nil);
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (APP_TYPE == 3) {
        [self.contentView stlAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(0, 0)];
    } else {
        [self.contentView stlAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    }

}
@end
