//
//  OSSVShowErrorCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVShowErrorCell.h"

@interface OSSVShowErrorCell ()

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation OSSVShowErrorCell
@synthesize delegate = _delegate;
@synthesize model = _model;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *contentView = self.contentView;
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).priorityHigh();
        }];
        
        [contentView addSubview:self.contentLabel];
        contentView.backgroundColor = [OSSVThemesColors col_EC5E4F:0.1];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentView).mas_offset(12);
            make.bottom.mas_equalTo(contentView.mas_bottom).mas_offset(-20);
            make.leading.mas_equalTo(contentView.mas_leading).mas_offset(CheckOutCellLeftPadding);
            make.trailing.mas_equalTo(contentView.mas_trailing).mas_offset(-CheckOutCellLeftPadding);
        }];
        
        self.contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - CheckOutCellLeftPadding*2;
    }
    return self;
}

#pragma mark - setter and getter

-(void)setModel:(STLShowErrorCellModel *)model
{
    _model = model;
    
    self.contentLabel.text = model.errorMessage;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"testesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestt", nil);
            label.textColor = OSSVThemesColors.col_EB4D3D;
            label.font = [UIFont systemFontOfSize:12];
            label.numberOfLines = 0;
            label;
        });
    }
    return _contentLabel;
}

@end


#pragma mark - STLShowErrorCellModel

@implementation STLShowErrorCellModel
@synthesize indexPath = _indexPath;
@synthesize showSeparatorStyle = _showSeparatorStyle;

#pragma mark - protocol

+(NSString *)cellIdentifier
{
    return NSStringFromClass(self.class);
}

-(NSString *)cellIdentifier
{
    return NSStringFromClass(self.class);
}
@end
