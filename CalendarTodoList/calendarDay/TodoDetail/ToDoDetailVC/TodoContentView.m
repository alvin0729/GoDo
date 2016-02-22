//
//  TodoContentView.m
//  CalendarTodoList
//
//  Created by 牛严 on 16/2/2.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import "TodoContentView.h"

@implementation TodoContentView
{
    UIImageView *_addImageView;
}

#pragma mark KVO Texfield
- (void)textFieldChanged:(UITextField *)textField
{
    [self.delegate getTodoContentWith:textField.text];
}

#pragma mark 点击添加图片
- (void)addImageViewClicked
{
    [self.delegate pickImageWithCurrentImageCount:0];
}

#pragma mark 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    UIView *lineView1 = [[UIView alloc]init];
    lineView1.backgroundColor = RGBA(220, 219, 224, 1.0);
    [self addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(@1);
    }];
    
    _todoContentField = [[UITextField alloc]init];
    _todoContentField.placeholder = @"内容";
    _todoContentField.delegate = self;
    [_todoContentField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    _todoContentField.font = [UIFont systemFontOfSize:18];
    [self addSubview:_todoContentField];
    [_todoContentField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(27);
        make.bottom.equalTo(self).offset(-96);
        make.left.equalTo(self).offset(25);
        make.right.equalTo(self).offset(-25);
    }];
    
    _addImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"AlbumAddBtn.png"]];
    _addImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *addImageRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addImageViewClicked)];
    [_addImageView addGestureRecognizer:addImageRecognizer];
    [self addSubview:_addImageView];
    [_addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_todoContentField.mas_bottom).offset(20);
        make.left.equalTo(_todoContentField);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    UIView *lineView2 = [[UIView alloc]init];
    lineView2.backgroundColor = RGBA(220, 219, 224, 1.0);
    [self addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.mas_equalTo(@1);
    }];
}

@end
