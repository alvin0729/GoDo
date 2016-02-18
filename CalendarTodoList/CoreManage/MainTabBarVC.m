//
//  MainTabBarVC.m
//  CalendarTodoList
//
//  Created by 牛严 on 15/12/25.
//  Copyright © 2015年 牛严. All rights reserved.
//

#import "MainTabBarVC.h"
#import "CalendarVC.h"
#import <Realm/Realm.h>
#import "RLMTodoList.h"
#import "RLMThing.h"
#import "RLMThingType.h"
#import "CalendarVC.h"
#import "BaseNavigationController.h"
#import "RLMThingType.h"
#import "UserDefaultManage.h"

@interface MainTabBarVC ()

@end

@implementation MainTabBarVC

#pragma mark 初始化方法
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews
{
//    [self simulateThingType];
//    [self simulateTodoList];
    
    CalendarVC *calendarVC = [[CalendarVC alloc]init];
    BaseNavigationController *calendarNavVC = [[BaseNavigationController alloc]initWithRootViewController:calendarVC];
    [calendarVC setTitle:@"日历"];
    
    UINavigationController *secondController = [[UINavigationController alloc]init];
    [secondController setTitle:@"second"];
    
    [self setViewControllers:@[calendarNavVC, secondController]];
    
}

- (void)simulateTodoList
{
    [UserDefaultManager setTodoMaxId:1];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMThing *thing = [[RLMThing alloc]init];
    RLMThingType *type = [[RLMThingType objectsWhere:@"typeId = 3"] firstObject];
    thing.thingType = type;
    thing.thingStr = @"开始创建你的任务吧！";
    RLMTodoList *todolistModel = [[RLMTodoList alloc]init];
    NSDate *startDate = [NSDate dateWithTimeInterval:60*10 sinceDate:[NSDate date]];
    todolistModel.startTime = [startDate timeIntervalSinceReferenceDate];
    todolistModel.endTime = todolistModel.startTime + 60 * 60;
    todolistModel.tableId = 1;
    todolistModel.thing = thing;
    todolistModel.doneType = NotStart;
    
    [realm beginWriteTransaction];
    [RLMTodoList createOrUpdateInRealm:realm withValue:todolistModel];
    [realm commitWriteTransaction];
    
}

- (void)simulateThingType
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMThingType *rlmThingType = [[RLMThingType alloc]init];
    
    rlmThingType.typeId = 1;
    rlmThingType.typeStr = @"学习";
    rlmThingType.red = 251;
    rlmThingType.green = 136;
    rlmThingType.blue = 110;
    [realm beginWriteTransaction];
    [RLMThingType createOrUpdateInRealm:realm withValue:rlmThingType];
    [realm commitWriteTransaction];
    
    rlmThingType.typeId = 2;
    rlmThingType.typeStr = @"社团";
    rlmThingType.red = 59;
    rlmThingType.green = 213;
    rlmThingType.blue = 251;
    [realm beginWriteTransaction];
    [RLMThingType createOrUpdateInRealm:realm withValue:rlmThingType];
    [realm commitWriteTransaction];
    
    rlmThingType.typeId = 3;
    rlmThingType.typeStr = @"个人";
    rlmThingType.red = 255;
    rlmThingType.green = 204;
    rlmThingType.blue = 0;
    
    [realm beginWriteTransaction];
    [RLMThingType createOrUpdateInRealm:realm withValue:rlmThingType];
    [realm commitWriteTransaction];
    
    rlmThingType.typeId = 4;
    rlmThingType.typeStr = @"工作";
    rlmThingType.red = 226;
    rlmThingType.green = 168;
    rlmThingType.blue = 228;
    
    [realm beginWriteTransaction];
    [RLMThingType createOrUpdateInRealm:realm withValue:rlmThingType];
    [realm commitWriteTransaction];
    
    rlmThingType.typeId = 5;
    rlmThingType.typeStr = @"休闲";
    rlmThingType.red = 210;
    rlmThingType.green = 184;
    rlmThingType.blue = 163;
    
    [realm beginWriteTransaction];
    [RLMThingType createOrUpdateInRealm:realm withValue:rlmThingType];
    [realm commitWriteTransaction];
}

@end
