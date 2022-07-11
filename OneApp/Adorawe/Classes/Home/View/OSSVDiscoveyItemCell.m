//
//  DiscoveryItemCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDiscoveyItemCell.h"
#import "OSSVAdvsEventsModel.h"

// DiscoveryItemCell 高度, 和已经确定
const CGFloat kDiscoveryCellImageHeight = 200.0f;
// cell 之间的间距
const CGFloat kDiscoveryCellSpace = 7.0f;

@interface OSSVDiscoveyItemCell ()

@property (nonatomic, strong) YYAnimatedImageView    *backContentImageView;
@property (nonatomic, strong) UIButton               *leftTopButton;
@property (nonatomic, strong) NSIndexPath            *indexPath;
//@property (nonatomic, strong) UIButton               *rightDownButton;

@end

@implementation OSSVDiscoveyItemCell

+ (OSSVDiscoveyItemCell *)discoveryItemCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [tableView registerClass:[OSSVDiscoveyItemCell class] forCellReuseIdentifier:@"DiscoveryItemCell"];
    OSSVDiscoveyItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DiscoveryItemCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.backContentImageView];
        [self.backContentImageView addSubview:self.leftTopButton];

        CGFloat titleWidth = [self.leftTopButton.titleLabel.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 25)
                                                                              options: NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics
                                                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13] }
                                                                              context:nil].size.width;
        
        [self.backContentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(@(-kDiscoveryCellSpace));
        }];
        
        [self.leftTopButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(@(10)); // 原设计图是14，后磊要改为12 后磊改10；
            make.leading.mas_equalTo(@(10));
            make.size.mas_equalTo(CGSizeMake(titleWidth + 36, 25));
        }];
        

//        CGFloat titleWidth = [_rightDownButton.titleLabel.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 22) options: NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13] } context:nil].size.width;
//        [self.backContentImageView addSubview:self.rightDownButton];
//        [self.rightDownButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.mas_equalTo(@(-(10*DSCREEN_WIDTH_SCALE)));
//            make.trailing.mas_equalTo(@(-9));
//            make.size.mas_equalTo(CGSizeMake(titleWidth + 20, 22*DSCREEN_WIDTH_SCALE));
//        }];
       
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.backContentImageView yy_cancelCurrentImageRequest];
    self.backContentImageView.image = nil;
    //self.rightDownButton.hidden = YES;
    self.leftTopButton.hidden = YES;
}

#pragma mark -

- (void)setBannerModel:(OSSVAdvsEventsModel *)bannerModel {
    [self.backContentImageView yy_setImageWithURL:[NSURL URLWithString:bannerModel.imageURL]
                                      placeholder:[UIImage imageNamed:@"placeholder_banner_pdf"]
                                          options:kNilOptions
                                         progress:nil
                                        transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                                     image = [image yy_imageByResizeToSize:CGSizeMake(SCREEN_WIDTH,kDiscoveryCellImageHeight * DSCREEN_WIDTH_SCALE) contentMode:UIViewContentModeScaleAspectFill];
                                                     return image;
                                                 }
                                       completion:nil];
    
    // 将第一个Cell 的倒计时去掉
    if (self.indexPath.item == 0) {
        self.leftTopButton.hidden = YES;
    }
    else {
        self.leftTopButton.hidden = NO;
        NSString *time = [NSString stringWithFormat:@"%@ %@",STLLocalizedString_(@"endsIn", nil), [self timeLapse:[bannerModel.leftTime intValue]]];
        [self.leftTopButton setTitle:time forState:UIControlStateNormal];
        CGFloat titleWidth = [time boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 22) options: NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13] } context:nil].size.width;
        [self.leftTopButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@(titleWidth + 36));
        }];
    }
    
//    if (self.indexPath.item == 0) {
//        self.rightDownButton.hidden = YES;
//    }
//    else {
//        self.rightDownButton.hidden = NO;
//        NSString *time = [self timeLapse:[bannerModel.leftTime intValue]];
//        [self.rightDownButton setTitle:time forState:UIControlStateNormal];
//        CGFloat titleWidth = [time boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 22) options: NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13] } context:nil].size.width;
//        [self.rightDownButton mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(@(titleWidth + 20));
//        }];
//    }

    
}

- (NSString*)timeLapse:(int64_t)time
{
    int64_t oneDay = 24*60*60;
    int64_t oneHour = 1*60*60;
    int value = 0;
    NSString *title = @"";
    if (time > oneDay){
        value = (int)time/oneDay;
        title = @"d";
    }else{
        value = (int)time/oneHour;
        title = @"h";
    }
    
    return [[@(value) stringValue] stringByAppendingString:title];
}



#pragma mark - LazyLoad

- (YYAnimatedImageView *)backContentImageView {
    if (!_backContentImageView) {
        _backContentImageView = [[YYAnimatedImageView alloc] init];
        _backContentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backContentImageView.clipsToBounds = YES;
    }
    return _backContentImageView;
}

- (UIButton *)leftTopButton {
    if (!_leftTopButton) {
        _leftTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftTopButton setTitle:STLLocalizedString_(@"endsIn12d", nil) forState:UIControlStateNormal];
        _leftTopButton.backgroundColor = OSSVThemesColors.col_FFFFFF;
        _leftTopButton.alpha = 0.6;
        _leftTopButton.layer.cornerRadius = 4;
        _leftTopButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_leftTopButton setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateNormal];;
        [_leftTopButton setImage:[UIImage imageNamed:@"home_countdown"] forState:UIControlStateNormal];
        [_leftTopButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [_leftTopButton setImageEdgeInsets:UIEdgeInsetsMake(0, 8.5, 0, 0)];
        [_leftTopButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 14.5, 0, 0)];
    }
    return _leftTopButton;
}

//- (UIButton *)rightDownButton {
//    if (!_rightDownButton) {
//        _rightDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_rightDownButton setTitle:@"00d" forState:UIControlStateNormal];
//        _rightDownButton.titleLabel.font = [UIFont systemFontOfSize:13];
//        [_rightDownButton setTitleColor:OSSVThemesColors.col_999999 forState:UIControlStateNormal];;
//        [_rightDownButton setImage:[UIImage imageNamed:@"discovery_countdown"] forState:UIControlStateNormal];
//        [_rightDownButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//        [_rightDownButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
//
//    }
//    return _rightDownButton;
//}

@end
