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
  [self prepare];

  self.currentSelector = _cmd;
  
  [self.starter start];
  
  CustomTask *task = [CustomTask new];
  [self.starter addCJAStarterTask: task];
  [self.starter start];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2];
}

- (void)test2 {
  [self prepare];

  self.currentSelector = _cmd;

  [self.starter addCJAStarterTaskClass: [CustomTask class] ];
  [self.starter start];
  
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2];

}

- (void)customTaskNotification:(NSNotification *)notification {
  NSLog(@"%s", __FUNCTION__);
  [self notify:kGHUnitWaitStatusSuccess forSelector: self.currentSelector];
}

@end
