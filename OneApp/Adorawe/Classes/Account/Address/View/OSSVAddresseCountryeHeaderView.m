//
//  OSSVAddresseCountryeHeaderView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAddresseCountryeHeaderView.h"

@interface OSSVAddresseCountryeHeaderView ()

@property (nonatomic, copy) UILabel *titleLabel;

@end

@implementation OSSVAddresseCountryeHeaderView

+ (OSSVAddresseCountryeHeaderView *)addressCountryHeaderViewWithTableView:(UITableView *)tableView section:(NSInteger)section {
    
    [tableView registerClass:[OSSVAddresseCountryeHeaderView class]  forHeaderFooterViewReuseIdentifier:@"OSSVAddresseCountryeHeaderView"];
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"OSSVAddresseCountryeHeaderView"];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = OSSVThemesColors.col_F1F1F1;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textColor = OSSVThemesColors.col_999999;
        [self.contentView addSubview:_titleLabel];
        /**
         *  在Frame 中的布局中注意 ，用 make.top.bottom.equalTo(@0),这样然后就有警告
         */
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(@0);
            make.leading.mas_equalTo(@15);
            make.width.mas_equalTo(@(SCREEN_WIDTH - 15));
            make.height.mas_equalTo(@(28));
        }];
      
    }
    return self;
}

- (void)setTitleText:(NSString *)titleText {
    
    _titleText = [titleText copy];
    self.titleLabel.text = titleText;
}


@end
