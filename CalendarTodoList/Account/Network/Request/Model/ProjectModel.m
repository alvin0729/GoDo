//
//  ProjectModel.m
//  GoDo
//
//  Created by 牛严 on 16/4/6.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import "ProjectModel.h"
#import "ProjectMemberModel.h"

@implementation ProjectModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"members" : [ProjectMemberModel class],
             };
}


@end
