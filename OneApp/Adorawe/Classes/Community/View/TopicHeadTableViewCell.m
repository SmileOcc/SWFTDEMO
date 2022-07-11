//
//  TopicHeadTableViewCell.m
//  Zaful
//
//  Created by DBP on 16/11/23.
//  Copyright © 2016年 Y001. All rights reserved.
//

#import "TopicHeadTableViewCell.h"
#import "YYText.h"

@interface TopicHeadTableViewCell ()
@property (nonatomic, strong) YYAnimatedImageView *topicImg;
@property (nonatomic, strong) UILabel *topicTitleLabel;
@property (nonatomic, strong) UILabel *joinNumLabel;
@property (nonatomic, strong) UIButton *joinBtn;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) YYLabel *contentLabel;
@property (nonatomic, strong) UIButton *viewAllBtn;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic,strong) MASConstraint *viewAllHeight;//viewAll

@property (nonatomic, assign)  CGFloat baseFontSize;       //基准字体大小
@property (nonatomic, assign)  CGFloat topicHeadHeight;       //基准字体大小

@property (nonatomic, assign)CGFloat contentRealH;
@end

@implementation TopicHeadTableViewCell
+ (TopicHeadTableViewCell *)topicHeadTableViewCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [tableView registerClass:[TopicHeadTableViewCell class] forCellReuseIdentifier:TOPIC_HEAD_CELL_IDENTIFIER];
    return [tableView dequeueReusableCellWithIdentifier:TOPIC_HEAD_CELL_IDENTIFIER forIndexPath:indexPath];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.baseFontSize = 14;
        self.topicHeadHeight = 0;
        
        YYAnimatedImageView *topicImg = [YYAnimatedImageView new];
        topicImg.contentMode = UIViewContentModeScaleAspectFill;
        topicImg.clipsToBounds = YES;
        [self.contentView addSubview:topicImg];
        
        [topicImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.mas_equalTo(self.contentView);
            make.height.mas_equalTo(160);
        }];
        self.topicImg = topicImg;
        
        UILabel *topicTitleLabel = [UILabel new];
        topicTitleLabel.textAlignment = NSTextAlignmentLeft;
        topicTitleLabel.font = [UIFont systemFontOfSize:18];
        topicTitleLabel.textColor = YSCOLOR(51, 51, 51, 1.0);
        [self.contentView addSubview:topicTitleLabel];
        
        [topicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(topicImg.mas_bottom).offset(10);
            make.leading.mas_equalTo(self.contentView).offset(10);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_equalTo(-84);
            make.height.mas_equalTo(20);
            
        }];
        self.topicTitleLabel = topicTitleLabel;
        
        UILabel *joinNumLabel = [UILabel new];
        joinNumLabel.textAlignment = NSTextAlignmentLeft;
        joinNumLabel.font = [UIFont systemFontOfSize:12];
        joinNumLabel.textColor = YSCOLOR(153, 153, 153, 1.0);
        [self.contentView addSubview:joinNumLabel];
        
        [joinNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(topicTitleLabel.mas_bottom).offset(5);
            make.leading.mas_equalTo(self.contentView).offset(10);
            make.trailing.mas_equalTo(self.contentView).offset(-100);
            make.height.mas_equalTo(20);
            
        }];
        self.joinNumLabel = joinNumLabel;
        
        UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        joinBtn.backgroundColor = YSCOLOR(255, 168, 0, 1.0);
        [joinBtn setImage:[UIImage imageNamed:@"join_in"] forState:UIControlStateNormal];
        joinBtn.clipsToBounds = YES;
        joinBtn.layer.cornerRadius = 37;
        joinBtn.layer.masksToBounds = YES;
        [joinBtn addTarget:self action:@selector(joinBtnClickEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:joinBtn];
        
        [joinBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView).offset(- 10);
            make.centerY.mas_equalTo(topicTitleLabel.mas_centerY).mas_offset(-15);
            make.width.height.mas_equalTo(74);
        }];
        self.joinBtn = joinBtn;
        
        YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
        modifier.fixedLineHeight = 18;//行高
        YYLabel *contentLabel = [YYLabel new];
        contentLabel.numberOfLines = 4;
        contentLabel.linePositionModifier = modifier;
        contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 20;
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.textColor = YSCOLOR(102, 102, 102, 1.0);
        [self.contentView addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(joinNumLabel.mas_bottom).offset(5);
            make.leading.mas_equalTo(self.contentView).offset(10);
            make.trailing.mas_equalTo(self.contentView).offset(-10);
        }];
        self.contentLabel = contentLabel;
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = YSCOLOR(241, 241, 241, 1.0);
        [self.contentView addSubview:lineView];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentLabel.mas_bottom).offset(5);
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.height.mas_equalTo(@1);
        }];
        self.lineView = lineView;
        
        UIButton *viewAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        viewAllBtn.tag = 10;
        viewAllBtn.backgroundColor = [UIColor clearColor];
        viewAllBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
//        [viewAllBtn setTitle:@"VIEW ALL" forState:UIControlStateNormal];
        
        [viewAllBtn setImage:[UIImage imageNamed:@"view_up"] withTitle:@"VIEW ALL" forState:UIControlStateSelected];
        [viewAllBtn setImage:[UIImage imageNamed:@"view_down"] withTitle:@"VIEW ALL" forState:UIControlStateNormal];
        
        [viewAllBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [viewAllBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:viewAllBtn];
        
        [viewAllBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lineView.mas_bottom);
            make.leading.trailing.mas_equalTo(self.contentView);
            self.viewAllHeight = make.height.mas_equalTo(40);
        }];
        self.viewAllBtn = viewAllBtn;
        
        UIView *bottomView = [UIView new];
        bottomView.backgroundColor = YSCOLOR(241, 241, 241, 1.0);
        [self.contentView addSubview:bottomView];
        
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(viewAllBtn.mas_bottom).offset(5);
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.height.mas_equalTo(@10);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
        self.bottomView = bottomView;
    }
    return self;
}


- (void)setTopicDetailHeadModel:(TopicDetailHeadLabelModel *)topicDetailHeadModel {
    [self.topicImg yy_setImageWithURL:[NSURL URLWithString:topicDetailHeadModel.iosDetailpic]
                         processorKey:NSStringFromClass([self class])
                          placeholder:[UIImage imageNamed:@"placeholder_banner_pdf"]
                              options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             }
                            transform:^UIImage *(UIImage *image, NSURL *url) {
                                
                                return image;
                            }
                           completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                               if (from == YYWebImageFromDiskCache) {
                                   YSLog(@"load from disk cache");
                               }
                           }];
    
    self.topicTitleLabel.text = topicDetailHeadModel.title;
    
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",topicDetailHeadModel.topicLabel,topicDetailHeadModel.content]];
    content.yy_font = [UIFont systemFontOfSize:14];
    content.yy_color = YSCOLOR(102, 102, 102, 1.0);
    
    if(topicDetailHeadModel.topicLabel.length > 0) {
        [content yy_setColor:YSCOLOR(255, 168, 0, 1.0) range:NSMakeRange(0,topicDetailHeadModel.topicLabel.length)];
    }
//    if ([SystemConfigUtils isRightToLeftShow]) {
        // NSParagraphStyle
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment = NSTextAlignmentRight;
        [content addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, content.length)];
//    }
    self.contentLabel.attributedText = content;
    
//    if ([SystemConfigUtils isRightToLeftLanguage]) {
//        self.joinNumLabel.text = [NSString stringWithFormat:@"%@ %@",ZFLocalizedString(@"TopicHead_Cell_JoinedIn",nil),topicDetailHeadModel.joinNumber];
//    } else {
        self.joinNumLabel.text = [NSString stringWithFormat:@"%@",topicDetailHeadModel.joinNumber];
//    }
    
    
    
    self.contentRealH = [self TextHeight:self.contentLabel.text FontSize:self.baseFontSize Width:SCREEN_WIDTH - 20];
    if(self.contentRealH > 4 *self.baseFontSize){
        self.viewAllHeight.mas_equalTo(40);
        [self.viewAllBtn setImage:[UIImage imageNamed:@"view_down"] withTitle:@"ssss" forState:UIControlStateNormal];
        self.lineView.hidden = NO;
    }else {
        self.viewAllHeight.mas_equalTo(0);
        [self.viewAllBtn setImage:[UIImage imageNamed:@""] withTitle:@"" forState:UIControlStateNormal];
        self.lineView.hidden = YES;
    }
}

#pragma mark - Button Click Event

- (void)joinBtnClickEvent:(UIButton*)sender {
    if (self.joinInMyStyleBlock) {
        self.joinInMyStyleBlock(self.topicTitleLabel.text);
    }
}

- (void)clickEvent:(UIButton*)sender {
    if (sender.selected) {
        self.contentLabel.numberOfLines = 4;
        sender.selected = NO;
    }else {
        self.contentLabel.numberOfLines = 0;
        sender.selected = YES;
    }
    
    if (self.refreshHeadViewBlock) {
        self.refreshHeadViewBlock();
    }
}

//固定宽度，获取字符串的高度
- (CGFloat)TextHeight:(NSString *)str2 FontSize:(CGFloat)fontsize Width:(CGFloat)width{
    NSString *str=[NSString stringWithFormat:@"%@",str2];
    CGSize constraint = CGSizeMake(width, MAXFLOAT);
    UILabel *lbl = [[UILabel alloc]init];
    UIFont *font =[UIFont fontWithName:lbl.font.familyName size:fontsize];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    CGSize size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading  attributes:dic context:nil].size;
    
    return size.height;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
