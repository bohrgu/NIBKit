/*
 NIBChainedImageView.m
 
 Copyright 2014/02/03 Guillaume Bohr
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "NIBChainedImageView.h"

@implementation NIBChainedImageView

@synthesize savedFrame;
@synthesize previousView;
@synthesize nextView;

#pragma mark - Appearance Management

- (void)removeFromSuperview
{
    if (!removedFromSuperview)
    {
        // Bind previous and next views
        self.nextView.previousView = self.previousView;
        self.previousView.nextView = self.nextView;
        
        // Reframe chained views
        if (self.nextView)
        {
            CGRect nextFrame = self.nextView.frame;
            nextFrame.origin.y = self.frame.origin.y;
            [self.nextView setFrame:nextFrame];
        }
        else
        {
            [self reframeSuperviewUsingFrame:self.previousView.frame];
        }
        
        // Call super method
        [super removeFromSuperview];
        
        // Update status
        removedFromSuperview = YES;
    }
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    if (alreadyAppeared)
    {
        CGRect newFrame = hidden ? CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0.0f) : savedFrame;
        [self setFrame:newFrame];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if (!alreadyAppeared)
    {
        alreadyAppeared = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self reframeChainedViews];
    }
}

#pragma mark - Frame Management

- (void)reframeChainedViews
{
    if (self.previousView)
    {
        [self.previousView reframeChainedViews];
    }
    else
    {
        [self reframeNextView];
    }
}

- (void)reframeNextView
{
    CGRect nextFrame = self.nextView.frame;
    nextFrame.origin.y = CGRectGetMaxY(self.frame);
    [self.nextView setFrame:nextFrame];
}

- (void)reframeSuperviewUsingFrame:(CGRect)rect
{
    if ([self.superview isMemberOfClass:[UIScrollView class]])
    {
        // Update content size
        UIScrollView *superScrollView = (UIScrollView *)self.superview;
        CGSize newContentSize = CGSizeMake(superScrollView.bounds.size.width, CGRectGetMaxY(rect));
        [superScrollView setContentSize:newContentSize];
    }
    else
    {
        // Reframe super view
        CGRect superFrame = self.superview.frame;
        superFrame.size.height = CGRectGetMaxY(rect);
        [self.superview setFrame:superFrame];
    }
}

- (void)setFrame:(CGRect)frame
{
    @synchronized(self)
    {
        // Save previous frame
        if (frame.size.height > 0.0f)
        {
            savedFrame = frame;
        }
        
        [super setFrame:frame];
        
        if (alreadyAppeared)
        {
            if (self.nextView)
            {
                [self reframeNextView];
            }
            else
            {
                [self reframeSuperviewUsingFrame:self.frame];
            }
        }
    }
}

@end
