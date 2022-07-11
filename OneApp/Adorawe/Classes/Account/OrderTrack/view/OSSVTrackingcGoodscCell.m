//
//  OSSVTrackingcGoodscCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTrackingcGoodscCell.h"
#import "OSSVTrackingcGoodListcModel.h"

@interface OSSVTrackingcGoodscCell ()

@property (nonatomic, strong) YYAnimatedImageView *picImageView;
@property (nonatomic, strong) UILabel *contentTitleLabel;
@property (nonatomic, strong) UILabel *typeAndSizeLabel;
@property (nonatomic, strong) UILabel *numberLabel;


@end


@implementation OSSVTrackingcGoodscCell

+ (OSSVTrackingcGoodscCell*)trackingGoodsCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    
    [tableView registerClass:[OSSVTrackingcGoodscCell class] forCellReuseIdentifier:NSStringFromClass(OSSVTrackingcGoodscCell.class)];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVTrackingcGoodscCell.class) forIndexPath:indexPath];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        _picImageView = [[YYAnimatedImageView alloc] init];
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds = YES;
        [self.contentView addSubview:_picImageView];
        [_picImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.mas_equalTo(self.contentView.mas_top).offset(15);
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(15);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
            make.width.mas_equalTo(@(70));
        }];
        
        _contentTitleLabel = [[UILabel alloc] init];
        _contentTitleLabel.numberOfLines = 0;
        _contentTitleLabel.textColor = OSSVThemesColors.col_333333;
        _contentTitleLabel.font = [UIFont systemFontOfSize:13];
        [_contentTitleLabel sizeToFit];
        [self.contentView addSubview:_contentTitleLabel];
        [_contentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_picImageView.mas_top);
            make.leading.equalTo(_picImageView.mas_trailing).offset(15);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-10);
            
        }];
        
        _typeAndSizeLabel = [[UILabel alloc] init];
        _typeAndSizeLabel.textColor = OSSVThemesColors.col_999999;
        _typeAndSizeLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_typeAndSizeLabel];
        [_typeAndSizeLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_contentTitleLabel.mas_bottom).offset(5);
            make.leading.equalTo(_contentTitleLabel.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-10);
            make.height.mas_equalTo(@18);
        }];
        
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.textColor =  OSSVThemesColors.col_999999;
        _numberLabel.font =  [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_numberLabel];
        [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_typeAndSizeLabel.mas_bottom).offset(5);
            make.leading.equalTo(_contentTitleLabel.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-10);
            make.height.mas_equalTo(@18);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-15);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = OSSVThemesColors.col_F1F1F1;
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.trailing.leading.mas_equalTo(self.contentView);
            make.height.mas_equalTo(@1);
        }];
    }
    return self;
}


- (void)setGoodListModel:(OSSVTrackingcGoodListcModel *)goodListModel {
    [self.picImageView yy_setImageWithURL:[NSURL URLWithString:goodListModel.goodThumpImageURL]
                              placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                  options:kNilOptions
                                 progress:nil
                                transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                            image = [image yy_imageByResizeToSize:CGSizeMake(70,70) contentMode:UIViewContentModeScaleAspectFill];
                                            return image;
                                        }
                               completion:nil];
    self.contentTitleLabel.text = goodListModel.goodTitle;
    self.typeAndSizeLabel.text = goodListModel.attr;
    self.numberLabel.text = [NSString stringWithFormat:@"X %@",goodListModel.goodNumber];
}

// 其实一般来说，这里也很少会被调用，客户不可能有那么多买的东东吧
- (void)prepareForReuse
{
    [self.picImageView yy_cancelCurrentImageRequest];
    self.picImageView.image = nil;
    self.contentTitleLabel.text = nil;
    self.typeAndSizeLabel.text = nil;
    self.numberLabel.text = nil;
    [super prepareForReuse];
}


@end
