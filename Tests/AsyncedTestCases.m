//
//  AsyncedTestCases.m
//  Initializer
//
//  Created by Carl Jahn on 11.07.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import "AsyncedTestCases.h"
#import "CJAStarter.h"

@interface AsyncedTestCases ()

@property (nonatomic, strong) CJAStarter *starter;
@property (nonatomic, assign) SEL currentSelector;
@end


@implementation AsyncedTestCases

- (void)setUp {
  
  self.starter = [CJAStarter new];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(booterFinished:) name:CJAStarterFinishedNotificationName object:nil];
}

- (void)tearDown {
  [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)booterFinished:(NSNotification *)notification {
  
  [self notify:kGHUnitWaitStatusSuccess forSelector: self.currentSelector];
}

- (void)test1 {
  [self prepare];
  
  self.currentSelector = _cmd;
  
  __block int index = 0;
  [self.starter addAsyncCJAStarterTaskBlock:^(CJAStarterTask *task){
    
      index = 1;
      task.finished = YES;
  }];
  
  
  [self.starter start];
  
  
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5];
  GHAssertEquals(1, index, nil);
  
}

- (void)test2 {
  [self prepare];
  
  self.currentSelector = _cmd;

  __block int index = 0;

  [self.starter addAsyncCJAStarterTaskBlock:^(CJAStarterTask *task){
    
    sleep(1);
    index = 1;
    task.finished = YES;
  }];
  
  [self.starter addAsyncCJAStarterTaskBlock:^(CJAStarterTask *task){
    
    sleep(2);
    index = 2;
    task.finished = YES;
  }];
  
  
  [self.starter start];
  
  
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5];
  GHAssertEquals(2, index, nil);
}

- (void)test3 {
  [self prepare];

  self.currentSelector = _cmd;
  
  __block int index = 0;

  CJAStarterTask *task1 = [self.starter addAsyncCJAStarterTaskBlock:^(CJAStarterTask *task){
    
      index = 1;
      task.finished = YES;
  }];
  
  CJAStarterTask *task2 = [self.starter addAsyncCJAStarterTaskBlock:^(CJAStarterTask *task){
    
      sleep(1);
      index = 2;
      task.finished = YES;
  }];
  
  task1.dependencieTask = task2;
  [self.starter start];
  
  
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5];
  GHAssertEquals(1, index, nil);
}

@end
