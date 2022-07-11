//
//  OSSVFeedBakReplaQuestiCell.m
// XStarlinkProject
//
//  Created by odd on 2021/4/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVFeedBakReplaQuestiCell.h"
#import "CYAnyCornerRadiusUtil.h"

@implementation OSSVFeedBakReplaQuestiCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [STLThemeColor stlClearColor];
        self.bgView.backgroundColor = [STLThemeColor stlWhiteColor];
        
        [self.contentView addSubview:self.bgColorView];
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.iconImg];
        [self.contentView addSubview:self.questionTypeDesc];
        [self.contentView addSubview:self.replyLabel];
        [self.contentView addSubview:self.pictureContentView];
        
        [self.bgColorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.top.mas_equalTo(self.contentView.mas_top);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.top.mas_equalTo(self.contentView.mas_top);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
        
        [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bgView.mas_leading).offset(12);
            make.top.mas_equalTo(self.bgView.mas_top).offset(12);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        [self.questionTypeDesc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconImg.mas_top);
            make.leading.mas_equalTo(self.iconImg.mas_trailing).offset(8);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-12);
        }];
        
        [self.replyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.questionTypeDesc.mas_leading);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-12);
            make.top.mas_equalTo(self.questionTypeDesc.mas_bottom).offset(2);
        }];
        
        [self.pictureContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.replyLabel.mas_bottom).offset(4);
            make.bottom.mas_equalTo(self.bgView.mas_bottom).mas_offset(-12);
            make.leading.mas_equalTo(self.questionTypeDesc.mas_leading);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-12);
            make.height.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
     //切圆角
     CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CornerRadii cornerRadii = CornerRadiiMake(4, 4, 0, 15);
    if ([SystemConfigUtils isRightToLeftShow]) {
        cornerRadii = CornerRadiiMake(4, 4, 15, 0);
    }
     CGPathRef path = CYPathCreateWithRoundedRect(self.bgView.bounds,cornerRadii);
     shapeLayer.path = path;
     CGPathRelease(path);
     self.bgView.layer.mask = shapeLayer;
    
}

- (void)setModel:(OSSVFeedbacksReplaysModel *)model {
    
    _model = model;
    
//    [self.layoutArray removeAllObjects];
//    [self.picArray removeAllObjects];
    
    self.questionTypeDesc.text = STLToString(model.feedbackTypeName);
    self.replyLabel.text = STLToString(model.feedbackContents);

    NSMutableArray *pictureMutableArray = [NSMutableArray array];
    [self.pictureContentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
        }];
        [obj removeFromSuperview];
    }];
        
    /*用户上传的图片*/
    if (STLJudgeNSArray(model.feedbackImg) && model.feedbackImg.count > 0) {
        
        [self.pictureContentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.replyLabel.mas_bottom).offset(4);
            make.height.mas_equalTo(60);
        }];
        
        
        if (model.feedbackImg.count  == 1) {
            
            STLFeedbackReplayImageModel *firstModel = model.feedbackImg.firstObject;
           
            YYAnimatedImageView *imageView = [self createPictureImgView:STLToString(firstModel.img_thumb) tag:0];

            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.pictureContentView.mas_leading);
                make.width.mas_equalTo(60);
                make.height.mas_equalTo(60);
                make.centerY.mas_equalTo(self.pictureContentView.mas_centerY);
            }];
            
        } else {
            
        
            [model.feedbackImg enumerateObjectsUsingBlock:^(STLFeedbackReplayImageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                YYAnimatedImageView *imageView = [self createPictureImgView:STLToString(obj.img_thumb) tag:idx];
                [pictureMutableArray addObject:imageView];
                if (idx == 3) {
                    *stop = YES;
                }
                
            }];
            
            [pictureMutableArray mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:8 leadSpacing:0 tailSpacing:10];
            [pictureMutableArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.pictureContentView.mas_top);
                make.bottom.mas_equalTo(self.pictureContentView.mas_bottom);
                make.width.mas_equalTo(60);
            }];
            
        }
        
    } else {
        [self.pictureContentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.replyLabel.mas_bottom).offset(0);
            make.height.mas_equalTo(0);
        }];
    }
    
    [self setNeedsDisplay];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.questionTypeDesc.text = nil;
    self.replyLabel.text = nil;
}

#pragma mark - 创建图片
- (YYAnimatedImageView *)createPictureImgView:(NSString *)imgUrl tag:(NSInteger)tag {
    
    NSURL *url = [NSURL URLWithString:imgUrl];

    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.tag = tag;

    [imageView yy_setImageWithURL:url
                      placeholder:[UIImage imageNamed:@"placeholder_pdf"]
                          options:YYWebImageOptionShowNetworkActivity
                       completion:nil];
    
    [self.pictureContentView addSubview:imageView];
//    [self.layoutArray addObject:imageView];
    
//    YYPhotoGroupItem *item = [YYPhotoGroupItem new];
//    item.thumbView = imageView;
//    item.largeImageURL = url;
//    [self.picArray addObject:item];
    
    return imageView;
}


- (UIView *)bgColorView {
    if (!_bgColorView) {
        _bgColorView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgColorView.backgroundColor = [STLThemeColor col_EEEEEE];
    }
    return _bgColorView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _bgView;
}

- (UIView *)pictureContentView {
    if (!_pictureContentView) {
        _pictureContentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _pictureContentView;
}

- (YYAnimatedImageView *)iconImg {
    if (!_iconImg) {
        _iconImg = [[YYAnimatedImageView alloc] init];
        if ([SystemConfigUtils isRightToLeftShow]) {
            _iconImg.image = [UIImage imageNamed:@"replay_me_ar"];
        } else {
            _iconImg.image = [UIImage imageNamed:@"replay_me"];
        }
    }
    return _iconImg;
}


- (UILabel *)questionTypeDesc {
    if (!_questionTypeDesc) {
        _questionTypeDesc = [[UILabel alloc] initWithFrame:CGRectZero];
        _questionTypeDesc.textColor = [STLThemeColor col_0D0D0D];
        _questionTypeDesc.font = [UIFont boldSystemFontOfSize:13];
    }
    return _questionTypeDesc;
}

- (UILabel *)replyLabel {
    if (!_replyLabel) {
        _replyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _replyLabel.textColor = [STLThemeColor col_0D0D0D];
        _replyLabel.font = [UIFont systemFontOfSize:13];
        _replyLabel.numberOfLines = 0;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _replyLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _replyLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _replyLabel;
}
@end
