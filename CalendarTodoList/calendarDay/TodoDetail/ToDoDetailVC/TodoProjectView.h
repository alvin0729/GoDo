//
//  TodoProjectView.h
//  CalendarTodoList
//
//  Created by 牛严 on 16/2/2.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FMProject;

@protocol TodoProjectViewDelegate <NSObject>

- (void)chooseTodoProject;

@end

@interface TodoProjectView : UIView

@property (nonatomic, strong)FMProject *project;
@property (nonatomic, weak)id<TodoProjectViewDelegate> delegate;

@end
