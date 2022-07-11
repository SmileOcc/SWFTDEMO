//
//  OSSVHomeTopiicCCell.m
// OSSVHomeTopiicCCell
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeTopiicCCell.h"

@interface OSSVHomeTopiicCCell ()

@property (nonatomic, strong) STLProductImagePlaceholder    *imageView;
@property (nonatomic, strong) UILabel                *textLabel;

@end

@implementation OSSVHomeTopiicCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self addSubview:self.imageView];
        [self addSubview:self.textLabel];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(@(10* DSCREEN_WIDTH_SCALE ));
            make.centerX.mas_equalTo(self.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(41* DSCREEN_WIDTH_SCALE, 41* DSCREEN_WIDTH_SCALE));
        }];
        
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(@(-5* DSCREEN_WIDTH_SCALE));
            make.leading.mas_equalTo(@5);
            make.trailing.mas_equalTo(@(-5));
            make.top.equalTo(self.imageView.mas_bottom).mas_equalTo(3* DSCREEN_WIDTH_SCALE);
        }];
    }
    return self;
}

#pragma mark - setter and getter

-(void)setModel:(OSSVTopicCCellModel *)model {
    
    _model = model;
    if ([_model.dataSource isKindOfClass:[OSSVAdvsEventsModel class]]) {
//        @weakify(self)
        OSSVAdvsEventsModel *model = (OSSVAdvsEventsModel *)_model.dataSource;
        [self.imageView.imageView yy_setImageWithURL:[NSURL URLWithString:model.imageURL]
                                  placeholder:nil
                                      options:kNilOptions
                                          completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
//            @strongify(self)
//            self.imageView.grayView.hidden = YES;
        }];
        self.textLabel.text = model.name;
    }
}

- (STLProductImagePlaceholder *)imageView {
    if (!_imageView) {
        _imageView = [[STLProductImagePlaceholder alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.text = STLLocalizedString_(@"test", nil);
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = OSSVThemesColors.col_333333;
        _textLabel.font = [UIFont systemFontOfSize:11];
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

@end
