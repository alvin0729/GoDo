//
//  TodoTableViewCell.m
//  CalendarTodoList
//
//  Created by 牛严 on 16/1/19.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import "TodoTableViewCell.h"

#import "DBManage.h"

#import "NSObject+NYExtends.h"
#import "NSString+ZZExtends.h"
#import "ZoomImageView.h"
#import "FMTodoModel.h"

@implementation TodoTableViewCell
{
    UILabel *_textLabel;
    UILabel *_timeLabel;
    
    UIView *_topLine;
    UIImageView *_cicleView;
    UIView *_bottomLine;
    
    FMTodoModel *_todo;
}

static NSInteger CircleRadius = 13;
static NSInteger LineWidth = 2;

- (void)loadTodo:(FMTodoModel *)todo
{
    _todo = todo;
    _textLabel.text = todo.thingStr;
    NSString *timeStr = [NSString getHourMinuteDateFromTimeInterval:todo.startTime];
    _timeLabel.text = timeStr;
    
    NSInteger R = todo.project.red;
    NSInteger G = todo.project.green;
    NSInteger B = todo.project.blue;
    _cicleView.backgroundColor = RGBA(R, G, B, 1.0);
    _cicleView.layer.borderWidth = 2;
    _cicleView.layer.borderColor = [RGBA(R, G, B, 1.0) CGColor];
    
    
    todo.doneType == Done?  _cicleView.highlighted = YES:NO;
    if (todo.images.count) {
        NSInteger imageCount = todo.images.count;
        NSInteger imageEdge = 10;
        [_textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-70);
        }];
        //创建imageView
        for (int i = 0; i < 4; i ++) {
            UIImageView *todoImageView = [_imageViews objectAtIndex:i];
            if (i < imageCount) {
                todoImageView.userInteractionEnabled = YES;
                todoImageView.contentMode= UIViewContentModeScaleAspectFill;
                todoImageView.clipsToBounds = YES;
                todoImageView.tag = todo.tableId *4 + i;
                todoImageView.image = todo.images[i];
                UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enlargeImageWithImageView:)];
                [todoImageView addGestureRecognizer:recognizer];
            }else{
                todoImageView.image = nil;
            }
            
            [self.contentView addSubview:todoImageView];
            [todoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(98 + i*(50+imageEdge));
                make.size.mas_equalTo(CGSizeMake(50, 50));
                make.top.equalTo(_textLabel.mas_bottom).offset(15);
            }];
            [_imageViews addObject:todoImageView];
        }
    }else{
        [_textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-15);
        }];
    }
    
}

- (void)circleViewClicked
{
    _cicleView.highlighted = !_cicleView.highlighted;
    DoneType doneType;
    if (_cicleView.highlighted)   doneType = Done;
    else doneType = NotDone;
    
    dispatch_async(kBgQueue, ^{
        [DBManager changeTodoDoneTypeWithTableId:_todo.tableId doneType:doneType];
    });
}

#pragma mark 放大ImageView中的图片
- (void)enlargeImageWithImageView:(id)sender
{
    UITapGestureRecognizer * singleTap = (UITapGestureRecognizer *)sender;
    ZoomImageView *zoomImageView = [[ZoomImageView alloc]initWithImageView:(UIImageView *)[singleTap view]];
    [zoomImageView showBigImageView];
}

#pragma mark 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier                                                                             
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _imageViews = [NSMutableArray arrayWithCapacity:4];
        for(int i = 0 ;i < 4 ; i ++)
        {
            UIImageView *imageView = [[UIImageView alloc]init];
            [_imageViews addObject:imageView];
        }
        [self initView];
    }
    return self;
}

- (void)initView
{
    _timeLabel = [[UILabel alloc]init];
    _timeLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.top.equalTo(self.contentView).offset(15);
        make.width.mas_equalTo(@50);
    }];
    
    _topLine = [[UIView alloc]init];
    _topLine.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_topLine];
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.left.equalTo(_timeLabel.mas_right).offset(16);
        make.size.mas_equalTo(CGSizeMake(LineWidth, 22));
    }];
    
    _bottomLine = [[UIView alloc]init];
    _bottomLine.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_bottomLine];
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(25);
        make.centerX.equalTo(_topLine);
        make.width.mas_equalTo(LineWidth);
        make.bottom.equalTo(self.contentView);
    }];
    
    _cicleView = [[UIImageView alloc]init];
    _cicleView.userInteractionEnabled = YES;
    _cicleView.highlightedImage = [UIImage imageNamed:@"check.png"];
    _cicleView.layer.masksToBounds = YES;
    _cicleView.layer.cornerRadius = CircleRadius;
    _cicleView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_cicleView];
    [_cicleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_timeLabel);
        make.centerX.equalTo(_topLine);
        make.size.mas_equalTo(CGSizeMake(CircleRadius*2, CircleRadius*2));
    }];
    
    UIView *circleButtonView = [[UIView alloc]init];
    circleButtonView.backgroundColor =[UIColor clearColor];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(circleViewClicked)];
    [circleButtonView addGestureRecognizer:recognizer];
    [self.contentView addSubview:circleButtonView];
    [circleButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_cicleView);
        make.size.mas_equalTo(CGSizeMake(CircleRadius*2 + 8, CircleRadius*2 + 8));
    }];
    

    _textLabel = [[UILabel alloc]init];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.textAlignment = NSTextAlignmentLeft;
    _textLabel.numberOfLines = 0;
    [self.contentView addSubview:_textLabel];
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(15);
        make.bottom.equalTo(self.contentView).offset(-15);
        make.left.equalTo(_topLine.mas_right).offset(18);
        make.right.equalTo(self.contentView).offset(-15);
    }];
}

@end
