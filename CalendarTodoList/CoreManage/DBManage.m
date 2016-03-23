//
//  DBManage.h
//  CalendarTodoList
//
//  Created by 牛严 on 16/1/27.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import "DBManage.h"
#import "UserDefaultManage.h"

#import "FMDayList.h"
#import "FMTodoImage.h"

#import "NSString+ZZExtends.h"
#import "NSObject+NYExtends.h"

@implementation DBManage

+ (id)sharedInstance
{
    static DBManage *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark 根据dayId获取todo数组
- (NSArray *)getDayInfoFromDateList:(NSInteger)dayId
{
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    
    FMDayList *dayList = [[[FMDayList getUsingLKDBHelper] searchWithSQL:[NSString stringWithFormat:@"select * from @t where dayID = '%ld'",(long)dayId] toClass:[FMDayList class]] firstObject];
    for (NSNumber *idNumber in dayList.tableIDs)
    {
        NSInteger tableID = [idNumber integerValue];
        FMTodoModel *todoModel = [[[FMTodoModel getUsingLKDBHelper] searchWithSQL:[NSString stringWithFormat:@"select * from @t where tableId = '%ld'",(long)tableID] toClass:[FMTodoModel class]] firstObject];
        if (todoModel.isAllDay) {
            todoModel.startTime = [self changeStartDateWith:todoModel.startTime];
        }
        NSMutableArray *fmTodoimageArray = [FMTodoImage searchWithSQL:[NSString stringWithFormat:@"select * from @t where tableId = '%ld'",(long)tableID]];
        NSMutableArray *imageArray = [[NSMutableArray alloc]init];
        for(FMTodoImage *todoImage in fmTodoimageArray)
        {
            UIImage *image = todoImage.image;
            [imageArray addObject:image];
        }
        todoModel.images = imageArray;
        [resultArray addObject:todoModel];
    }
    return [self sortArrayByStartTimeWithArray:resultArray];
}

#pragma mark 根据全天的开始时间设置当天0点
- (long long)changeStartDateWith:(long long)startDate
{
    NSDate * oriDate = [NSDate dateWithTimeIntervalSinceReferenceDate:startDate];
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute |NSCalendarUnitHour |NSCalendarUnitDay | NSCalendarUnitMonth |NSCalendarUnitYear fromDate:oriDate];
    comps.hour = 0;
    comps.minute = 0;
    NSDate * date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    long long timeStamp = [date timeIntervalSinceReferenceDate];
    return timeStamp;
}

#pragma mark 根据开始时间进行排序
- (NSArray *)sortArrayByStartTimeWithArray:(NSArray *)array
{
    NSComparator cmptr = ^(FMTodoModel *todo1, FMTodoModel *todo2){
        if (todo1.startTime > todo2.startTime) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (todo1.startTime < todo2.startTime) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *finalArray = [array sortedArrayUsingComparator:cmptr];
    return finalArray;
}


#pragma mark 创建RLMTodo
- (void)createTodoWithProject:(FMProject *)project contentStr:(NSString *)contentStr contentImages:(NSArray *)images startDate:(NSDate *)startDate oldStartDate:(NSDate *)oldStartDate isAllDay:(BOOL)isAllDay tableId:(NSInteger)tableId repeatMode:(RepeatMode)repeatMode
{
    FMTodoModel *todoModel = [[FMTodoModel alloc]init];
    todoModel.startTime = [startDate timeIntervalSinceReferenceDate];
    todoModel.isAllDay = isAllDay;
    FMProject *fmProject = [[FMProject alloc]init];
    fmProject.projectId = project.projectId;
    fmProject.projectStr = project.projectStr;
    fmProject.red = project.red;
    fmProject.green = project.green;
    fmProject.blue = project.blue;
    todoModel.project = fmProject;
    todoModel.projectId = project.projectId;
    todoModel.thingStr = contentStr;
    
    if (!tableId) {
        todoModel.tableId = [UserDefaultManager todoMaxId] + 1;
        [UserDefaultManager setTodoMaxId:todoModel.tableId];
    }else{
        todoModel.tableId = tableId;
    }
    todoModel.repeatMode = repeatMode;
    [self saveImageWith:todoModel images:images];
    
    [self CreateOrUpdateDateListWithStartDate:startDate oldStartDate:oldStartDate repeatMode:repeatMode FMTodo:todoModel];
    [[FMTodoModel getUsingLKDBHelper] insertToDB:todoModel];

    [self saveClockWithDate:startDate tableID:todoModel.tableId];
}

#pragma mark 保存闹钟
- (void)saveClockWithDate:(NSDate *)startDate tableID:(NSInteger)tableID
{
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        
        notification.fireDate=[startDate dateByAddingTimeInterval:-10];//10秒前通知

        notification.repeatInterval=kCFCalendarUnitDay;//循环次数，kCFCalendarUnitWeekday一周一次
        
        notification.timeZone=[NSTimeZone defaultTimeZone];
        
        notification.applicationIconBadgeNumber=1; //应用的红色数字
        
        notification.soundName= UILocalNotificationDefaultSoundName;//声音，可以换成alarm.soundName = @"myMusic.caf"
        
        //去掉下面2行就不会弹出提示框
        
        notification.alertBody=@"通知内容";//提示信息 弹出提示框
        
        notification.alertAction = @"打开";  //提示框按钮
        
        //notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
        
        
        
        // NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
        
        //notification.userInfo = infoDict; //添加额外的信息
        
        
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

#pragma mark 保存图片及对应ID
- (void)saveImageWith:(FMTodoModel *)todoModel images:(NSArray *)images
{
    NSInteger tableID = todoModel.tableId;
    
    NSMutableArray *lastImages = [FMTodoImage searchWithSQL:[NSString stringWithFormat:@"select * from @t where tableID = '%ld'",(long)tableID]];
    for(FMTodoImage *todoImage in lastImages)
    {
        [[FMTodoImage getUsingLKDBHelper] deleteToDB:todoImage];
    }
    
    for(UIImage *image in images)
    {
        FMTodoImage *todoImage = [[FMTodoImage alloc]init];
        todoImage.tableID = todoModel.tableId;
        todoImage.image = image;
        [[FMTodoImage getUsingLKDBHelper] insertToDB:todoImage];
    }
}

#pragma mark 新建更新day与tableId关系数据
- (void)CreateOrUpdateDateListWithStartDate:(NSDate *)startDate oldStartDate:(NSDate *)oldStartDate repeatMode:(RepeatMode)repeatMode FMTodo:(FMTodoModel *)fmTodo
{
    NSInteger dayID = [NSObject getDayIdWithDate:startDate];
    
    if (repeatMode == Never)
    {
        if (oldStartDate) {
            //存在表示修改过时间，删除之前的记录
            [self deleteOldTodoWithOldStartDate:oldStartDate tableID:fmTodo.tableId];
        }
        [self updateDayListWithDayID:dayID tableID:fmTodo.tableId];
    }
    else if (repeatMode == EveryDay)
    {
        if (!oldStartDate) {
            //新建的todo，进行表维护操作
            NSArray *dayIDs = [self dayIDsForEveryDayRepeatWithStartDate:startDate];
            for(NSNumber *dayIDNumber in dayIDs)
            {
                NSInteger dayId = [dayIDNumber integerValue];
                [self updateDayListWithDayID:dayId tableID:fmTodo.tableId];
            }
        }
    }
    else if (repeatMode == EveryMonth)
    {
//        if (!oldStartDate) {
            NSArray *dayIDs = [self dayIDsForEveryMonthRepeatWithStartDate:startDate];
            for(NSNumber *dayIDNumber in dayIDs)
            {
                NSInteger dayId = [dayIDNumber integerValue];
                [self updateDayListWithDayID:dayId tableID:fmTodo.tableId];
            }
//        }
    }
    else if (repeatMode == EveryWeek)
    {
//        if (!oldStartDate) {
            NSArray *dayIDs = [self dayIDsForEveryWeekRepeatWithStartDate:startDate];
            for(NSNumber *dayIDNumber in dayIDs)
            {
                NSInteger dayId = [dayIDNumber integerValue];
                [self updateDayListWithDayID:dayId tableID:fmTodo.tableId];
            }
//        }
    }
    else if (repeatMode == EveryWorkDay)
    {
//        if (!oldStartDate) {
            NSArray *dayIDs = [self dayIDsForEveryworkdayRepeatWithStartDate:startDate];
            for(NSNumber *dayIDNumber in dayIDs)
            {
                NSInteger dayId = [dayIDNumber integerValue];
                [self updateDayListWithDayID:dayId tableID:fmTodo.tableId];
            }
        }
//    }
}

#pragma mark 根据dayID和tableID维护日期-任务关系表
- (void)updateDayListWithDayID:(NSInteger)dayID tableID:(NSInteger)tableID
{
    FMDayList *dayList = [[FMDayList searchWithSQL:[NSString stringWithFormat:@"select * from @t where dayID = '%ld'",(long)dayID]] firstObject];
    NSMutableArray *tableIDs = [NSMutableArray arrayWithArray:dayList.tableIDs];
    if (dayList.dayID > 0) {
        dayList.dayID = dayID;
        if (![tableIDs containsObject:[NSNumber numberWithInteger:tableID]]) {
            [tableIDs addObject:[NSNumber numberWithInteger:tableID]];
        }
        dayList.tableIDs = [NSMutableArray arrayWithArray:tableIDs];
        [[FMDayList getUsingLKDBHelper] updateToDB:dayList where:nil];
    }else{
        dayList = [[FMDayList alloc]init];
        dayList.dayID = dayID;
        dayList.tableIDs = [[NSMutableArray alloc]init];
        [dayList.tableIDs addObject:[NSNumber numberWithInteger:tableID]];
        [[FMDayList getUsingLKDBHelper] insertToDB:dayList];
    }
}

#pragma mark 根据当前日期返回repeatMode为EveryDay的DayID
- (NSArray *)dayIDsForEveryDayRepeatWithStartDate:(NSDate *)startDate
{
    NSMutableArray *dayIDs = [[NSMutableArray alloc]initWithCapacity:0];
    NSInteger repeatTimes = [NSObject numberOfDaysInThisYear];
    long long  currentDayTimeStamp = [startDate timeIntervalSinceReferenceDate];
    for (int i = 0; i < repeatTimes; i ++) {
        long long timeStamp = currentDayTimeStamp + 60 * 60 * 24 * i ;
        NSInteger dayID = [NSObject getDayIdWithDateStamp:timeStamp];
        [dayIDs addObject:[NSNumber numberWithInteger:dayID]];
    }
    return dayIDs;
}

#pragma mark 根据当前日期返回repeatMode为EveryMonth的DayID
- (NSArray *)dayIDsForEveryMonthRepeatWithStartDate:(NSDate *)startDate
{
    NSMutableArray *dayIDs = [[NSMutableArray alloc]initWithCapacity:0];
    for (int i = 0; i < 12; i ++ ) {
        NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitHour |NSCalendarUnitMinute fromDate:startDate];
        comps.month = comps.month + i;
        if (comps.month > 12) {
            comps.month -= 12;
            comps.year += 1;
        }
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
        NSInteger dayID = [NSObject getDayIdWithDate:date];
        [dayIDs addObject:[NSNumber numberWithInteger:dayID]];
    }
    return dayIDs;
}

#pragma mark 根据当前日期返回repeatMode为EveryWeek的DayID
- (NSArray *)dayIDsForEveryWeekRepeatWithStartDate:(NSDate *)startDate
{
    NSMutableArray *dayIDs = [[NSMutableArray alloc]initWithCapacity:0];
    long long  currentDayTimeStamp = [startDate timeIntervalSinceReferenceDate];

    for(int i = 0; i < 52; i ++)
    {
        long long timeStamp = currentDayTimeStamp + 60 * 60 * 24 * 7 * i ;
        NSInteger dayID = [NSObject getDayIdWithDateStamp:timeStamp];
        [dayIDs addObject:[NSNumber numberWithInteger:dayID]];
    }
    return dayIDs;
}

#pragma mark 根据当前日期返回repeatMode为EveryWorkday的DayID
- (NSArray *)dayIDsForEveryworkdayRepeatWithStartDate:(NSDate *)startDate
{
    NSMutableArray *dayIDs = [[NSMutableArray alloc]initWithCapacity:0];
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfYear|NSCalendarUnitWeekday|NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitHour |NSCalendarUnitMinute fromDate:startDate];
    long long  currentDayTimeStamp = [startDate timeIntervalSinceReferenceDate];
    //第一周的dayIDs
    long long timeStamp = 0;
    NSInteger firstWeekNum = comps.weekday > 1 ? 9-comps.weekday:1;
    for(int i = 0 ; i < firstWeekNum; i ++)
    {
        timeStamp = currentDayTimeStamp + 60 * 60 * 24 * i;
        if (i < 5) {
            NSInteger dayID = [NSObject getDayIdWithDateStamp:timeStamp];
            [dayIDs addObject:[NSNumber numberWithInteger:dayID]];
        }
    }
    //中间周的dayIDs
    NSInteger otherDayNum = 365 - firstWeekNum;
    NSInteger midWeekNum = floorf(otherDayNum/7);//去头去尾，中间有多少个周
    for(int i = 0 ;i < midWeekNum; i ++)
    {
        for(int j = 0;j < 7;j ++)
        {
            timeStamp = timeStamp + 60 * 60 * 24;
            if (j < 5) {
                NSInteger dayID = [NSObject getDayIdWithDateStamp:timeStamp];
                [dayIDs addObject:[NSNumber numberWithInteger:dayID]];
            }
        }
    }
    //最后一周
    for(int i = 0; i < otherDayNum - 7*midWeekNum; i ++)
    {
        if (i < 5) {
            timeStamp = timeStamp + 60 * 60 * 24;
            NSInteger dayID = [NSObject getDayIdWithDateStamp:timeStamp];
            [dayIDs addObject:[NSNumber numberWithInteger:dayID]];
        }
    }
    return dayIDs;
}

#pragma mark 根据老时间和todo.tableID 删除那天对应的任务
- (void)deleteOldTodoWithOldStartDate:(NSDate *)oldStartDate tableID:(NSInteger)tableID
{
    NSInteger dayID = [NSObject getDayIdWithDate:oldStartDate];
    LKDBHelper *helper = [FMDayList getUsingLKDBHelper];
    FMDayList *dayList = [[FMDayList searchWithSQL:[NSString stringWithFormat:@"select * from @t where dayID = '%ld'",(long)dayID]] firstObject];
    NSMutableArray *tableIDs = [NSMutableArray arrayWithArray:dayList.tableIDs];
    if ([tableIDs containsObject:[NSNumber numberWithInteger:tableID]]) {
        [tableIDs removeObject:[NSNumber numberWithInteger:tableID]];
    }
    dayList.tableIDs = [NSMutableArray arrayWithArray:tableIDs];
    [helper updateToDB:dayList where:nil];
}

#pragma mark 根据todo tableID 修改todo 的doneType完成情况
- (void)changeTodoDoneTypeWithTableId:(NSInteger)tableId doneType:(DoneType)doneType
{
    FMTodoModel *todoModel = [[FMTodoModel searchWithSQL:[NSString stringWithFormat:@"select * from @t where tableId = '%ld'",(long)tableId]] firstObject];
    todoModel.doneType = doneType;
    [[FMTodoModel getUsingLKDBHelper] updateToDB:todoModel where:nil];
}

#pragma mark 根据projectId返回project
- (FMProject *)getProjectWithId:(NSInteger)projectId
{
    FMProject *project = [[FMProject searchWithSQL:[NSString stringWithFormat:@"select * from @t where projectId = '%ld'",(long)projectId]] firstObject];
    
    return project;
}
#pragma mark 获取project数组
- (NSMutableArray *)getProjectArray
{
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    resultArray = [FMProject searchWithSQL:@"select * from @t"];
    if (resultArray) return resultArray;
    return nil;
}

#pragma mark 删除todo
- (void)deleteTodoWithTableId:(NSInteger)tableId
{
    FMTodoModel *todoModel = [[FMTodoModel searchWithSQL:[NSString stringWithFormat:@"select * from @t where tableId = '%ld'",(long)tableId]] firstObject];
    [[FMTodoModel getUsingLKDBHelper] deleteToDB:todoModel];
    
    NSNumber *idNumber = [NSNumber numberWithInteger:tableId];
    NSMutableArray *dayListArray = [FMDayList searchWithSQL:@"select * from @t"];
    for(FMDayList *dayList in dayListArray)
    {
        NSMutableArray *tableIDs = [NSMutableArray arrayWithArray:dayList.tableIDs];
        if ([tableIDs containsObject:idNumber]) {
            [tableIDs removeObject:idNumber];
        }
        dayList.tableIDs = [NSMutableArray arrayWithArray:tableIDs];
        [[FMDayList getUsingLKDBHelper] updateToDB:dayList where:nil];
    }
}

@end
