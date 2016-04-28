//
//  AcceptInvitationCell.m
//  GoDo
//
//  Created by 牛严 on 16/4/28.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import "AcceptInvitationCell.h"

@implementation AcceptInvitationCell
{
    UIImageView *_headImageView;
    UILabel *_titleLabel;
    UILabel *_timeLabel;
    UILabel *_contentLabel;
    
}

#pragma mark 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initView];
    }
    return self;
}

- (void)initView
{
    _headImageView = [[UIImageView alloc]init];
    _headImageView.layer.cornerRadius = 19;
    _headImageView.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:_headImageView];
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(14);
        make.left.equalTo(self.contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(38, 38));
    }];
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = [UIFont systemFontOfSize:12];
    _titleLabel.text = @"甘少聪 邀请你加入项目:";
    _titleLabel.textColor = RGBA(134, 134, 134, 1.0);
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_headImageView);
        make.left.equalTo(_headImageView.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-77);
    }];
    
    _timeLabel = [[UILabel alloc]init];
    _timeLabel.text = @"4月30日";
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = RGBA(134, 134, 134, 1.0);
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel);
        make.right.equalTo(self.contentView).offset(-39);
    }];
    
    _contentLabel = [[UILabel alloc]init];
    _contentLabel.font = [UIFont systemFontOfSize:16];
    _contentLabel.text = @"2016毕设项目组";
    [self.contentView addSubview:_contentLabel];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(10);
        make.left.equalTo(_titleLabel);
        make.right.equalTo(self.contentView).offset(-18);
        make.bottom.equalTo(self.contentView).offset(-67);
    }];
    
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = RGBA(200, 200, 200, 1.0);
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@1);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView);
        make.top.equalTo(_contentLabel.mas_bottom).offset(14);
    }];
    
    UILabel *acceptLabel = [[UILabel alloc]init];
    acceptLabel.font = [UIFont systemFontOfSize:14];
    acceptLabel.textAlignment = NSTextAlignmentCenter;
    acceptLabel.userInteractionEnabled = YES;
    acceptLabel.text = @"领取";
    acceptLabel.textColor = RGBA(146, 146, 146, 1.0);
    [self.contentView addSubview:acceptLabel];
    [acceptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView);
        make.left.right.bottom.equalTo(self.contentView);
    }];
    
}

@end