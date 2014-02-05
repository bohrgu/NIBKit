/*
 NIBChain.m
 
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

#import "NIBChain.h"

@implementation UIView (NIBChain)

- (void)removeChainedViewFromSuperview
{
    // Hide self instead of removing it from its superview (in order to preserve nib chain)
    [self setHidden:YES];
}

- (void)setChainedViewHidden:(BOOL)hidden savedFrame:(CGRect*)savedFrame
{
    CGRect newFrame;
    if (hidden)
    {
        *savedFrame = self.frame;
        newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0.0f);
    }
    else
    {
        newFrame = *savedFrame;
    }
    [self setFrame:newFrame];
}

- (void)reframeNextChainedView:(UIView *)nextView
{
    if (nextView)
    {
        CGRect nextFrame = nextView.frame;
        nextFrame.origin.y = CGRectGetMaxY(self.frame);
        [nextView setFrame:nextFrame];
    }
    else
    {
        if ([self.superview isMemberOfClass:[UIScrollView class]])
        {
            // Update content size
            UIScrollView *superScrollView = (UIScrollView *)self.superview;
            CGSize newContentSize = CGSizeMake(superScrollView.bounds.size.width, CGRectGetMaxY(self.frame));
            [superScrollView setContentSize:newContentSize];
        }
        else
        {
            // Reframe super view
            CGRect superFrame = self.superview.frame;
            superFrame.size.height = CGRectGetMaxY(self.frame);
            [self.superview setFrame:superFrame];
        }
    }
}

@end
