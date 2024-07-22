//
//  ZFOrderQuestionItemCell.m
//  ZZZZZ
//
//  Created by YW on 2019/3/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderQuestionItemCell.h"
#import "ZFFrameDefiner.h"
#import <Masonry/Masonry.h>
#import "UIImage+ZFExtended.h"
#import "ZFThemeManager.h"

@interface ZFOrderQuestionItemCell ()

@property (nonatomic, strong) UIImageView *selectImage;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation ZFOrderQuestionItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.selectImage];
        [self.contentView addSubview:self.contentLabel];
        
        [self.selectImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.size.mas_equalTo(CGSizeMake(18, 18));
        }];
        
        self.contentLabel.preferredMaxLayoutWidth = KScreenWidth - 16 - 18 - 5 - 13;
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.selectImage.mas_trailing).mas_offset(5);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-23);
            make.top.mas_equalTo(self.contentView).mas_offset(12);
            make.bottom.mas_equalTo(self.contentView).mas_offset(-12);
        }];
    }
    return self;
}

#pragma mark - Property

-(void)setModel:(ZFOrderQuestionModel *)model
{
    _model = model;
    
    self.contentLabel.text = _model.content;
    if (_model.isSelect) {
        self.selectImage.image = [UIImage imageNamed:@"default_ok"];
    } else {
        self.selectImage.image = [UIImage imageNamed:@"default_no"];
    }
}

- (UIImageView *)selectImage
{
    if (!_selectImage) {
        _selectImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = [UIImage imageNamed:@"order_coupontag_unselected"];
            img;
        });
    }
    return _selectImage;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = @"I don't want to buy (don’t need/don’t like etc.) the item(s) anymore.";
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _contentLabel;
}

@end
