//
//  ZMAssistView.m
//  ZMAssist
//
//  Created by Yuri Boyka on 2019/1/17.
//  Copyright © 2019 Yuri Boyka. All rights reserved.
//

#import "ZMAssistView.h"

@interface ZMAssistView ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *assistSegment;
@property (weak, nonatomic) IBOutlet UITextView *logView;
@property (weak, nonatomic) IBOutlet UITableView *fileListView;
@end

@implementation ZMAssistView

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

@end
