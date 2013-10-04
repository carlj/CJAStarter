//
//  CustomTask.m
//  Initializer
//
//  Created by Carl Jahn on 12.07.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import "CustomTask.h"

NSString *const kTestNotificationName = @"kTestNotificationName";

@implementation CustomTask

- (BOOL)isAsync {
  return YES;
}

- (void)run {
  [super run];
  
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
  dispatch_async(queue, ^{
    sleep(1);
    dispatch_sync(dispatch_get_main_queue(), ^{
      [[NSNotificationCenter defaultCenter] postNotificationName:kTestNotificationName object:nil];
      self.finished = YES;
    });
    
  });
  
}

@end
