//
//  OSSVSettingsTablesCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

/*
 *
 *  没用到这个类
 *
 */


#import "OSSVSettingsTablesCell.h"

@interface OSSVSettingsTablesCell ()

@end

@implementation OSSVSettingsTablesCell

+ (OSSVSettingsTablesCell *)settingCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [tableView registerClass:[OSSVSettingsTablesCell class] forCellReuseIdentifier:@"OSSVSettingsTablesCell"];
    return [tableView dequeueReusableCellWithIdentifier:@"OSSVSettingsTablesCell" forIndexPath:indexPath];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
  
        
        _contentTitleLabel = [[UILabel alloc] init];
        _contentTitleLabel.text = STLLocalizedString_(@"Currency", nil);
        _contentTitleLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_contentTitleLabel];
        
        [_contentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.mas_equalTo(self.contentView.mas_top).offset(5);
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(15);
            make.height.mas_equalTo(@40);
            
        }];
        
        _remarkDetailLabel = [[UILabel alloc] init];
        _remarkDetailLabel.text = @"";
        _remarkDetailLabel.textAlignment = NSTextAlignmentRight;
        _remarkDetailLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_remarkDetailLabel];
        
        [_remarkDetailLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_contentTitleLabel.mas_top);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-15);
            make.leading.equalTo(_contentTitleLabel.mas_trailing).offset(5);
            make.height.mas_equalTo(@40);
            make.width.mas_equalTo(@90);
            
        }];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.contentTitleLabel.text = nil;
    self.remarkDetailLabel.text = nil;
}

@end
