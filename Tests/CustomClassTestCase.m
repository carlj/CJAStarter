//
//  CustomClassTestCase.m
//  Initializer
//
//  Created by Carl Jahn on 12.07.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import "CustomClassTestCase.h"
#import "CJAStarter.h"
#import "CustomTask.h"

@interface CustomClassTestCase ()

@property (nonatomic, strong) CJAStarter *starter;
@property (nonatomic, assign) SEL currentSelector;
@property (nonatomic, strong) NSConditionLock *lock;
@end

@implementation CustomClassTestCase

- (void)setUp {
  self.starter = [CJAStarter new];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customTaskNotification:) name:kTestNotificationName object:nil];
}

- (void)tearDown {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)test1 {

  self.currentSelector = _cmd;
  
  [self.starter start];
  
  CustomTask *task = [CustomTask new];
  [self.starter addTask: task];
  [self.starter start];


  [self.lock lockWhenCondition: 1];
}

- (void)test2 {

  self.currentSelector = _cmd;

  [self.starter addTaskClass: [CustomTask class] ];
  [self.starter start];
  
  [self.lock lockWhenCondition: 1];
}

- (void)customTaskNotification:(NSNotification *)notification {
  NSLog(@"%s", __FUNCTION__);
  [self.lock unlockWithCondition: 1];
}

@end
