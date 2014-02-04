/*
 NIBView.m
 
 Copyright 2014/01/01 Guillaume Bohr
 
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

#import "NIBView.h"
#import "NIBController.h"
#import "NIBChainedView.h"

@implementation NIBView

+ (instancetype)controllerWithParentController:(NIBController *)controller
{
    return [[[self class] alloc] initWithParentController:controller];
}

- (instancetype)initWithParentController:(NIBController *)controller
{
    NIBView *view = nil;
    
    // Get items in nib
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    NSArray *itemsInNib = [nib instantiateWithOwner:self options:nil];
    
    // Look for object of current class
    for (id item in itemsInNib)
    {
        if ([item isKindOfClass:[NIBView class]])
        {
            view = item;
        }
    }
    
    // Look for a controller
    for (id item in itemsInNib)
    {
        if ([item isKindOfClass:[UIViewController class]])
        {
            UIViewController *nestedController = (UIViewController *)item;
            view.selfController = nestedController;
            view.weakController = nestedController;
            [self setParentController:controller];
        }
    }
    
    return view;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    // Avoid init loop
    BOOL isPlaceholder = ([[self subviews] count] == 0 && ![self isMemberOfClass:[NIBChainedView class]]);
    
    if (isPlaceholder)
    {
        NIBView *nibView = [NIBView loadInstanceUsingPlaceholder:self];
        return nibView;
    }
    
    return self;
}

+ (NIBView *)loadInstanceUsingPlaceholder:(NIBView *)placeholder
{
    NIBView *view = nil;
    
    // Get items in nib
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([placeholder class]) bundle:nil];
    NSArray *itemsInNib = [nib instantiateWithOwner:self options:nil];
    
    // Look for object of current class
    for (id item in itemsInNib)
    {
        if ([item isMemberOfClass:[placeholder class]])
        {
            // Set found view
            view = item;
            
            // Pass placeholder content mode through
            view.contentMode = placeholder.contentMode;
            
            // Pass placeholder tag through
            view.tag = placeholder.tag;
            
            // Pass placeholder interaction properties through
            view.userInteractionEnabled = placeholder.userInteractionEnabled;
            view.multipleTouchEnabled = placeholder.multipleTouchEnabled;
            
            // Pass placeholder alpha through
            view.alpha = placeholder.alpha;
            
            // Pass placeholder background through
            view.backgroundColor = placeholder.backgroundColor;
            
            // Pass placeholder drawing properties through
            view.opaque = placeholder.opaque;
            view.hidden = placeholder.hidden;
            view.clearsContextBeforeDrawing = placeholder.clearsContextBeforeDrawing;
            view.clipsToBounds = placeholder.clipsToBounds;
            view.autoresizesSubviews = placeholder.autoresizesSubviews;
            
            // Pass placeholder frame properties through
            view.frame = placeholder.frame;
            view.autoresizingMask = placeholder.autoresizingMask;
        }
    }
    
    // Look for a controller
    for (id item in itemsInNib)
    {
        if ([item isKindOfClass:[UIViewController class]])
        {
            UIViewController *controller = (UIViewController *)item;
            view.selfController = controller;
            view.weakController = controller;
        }
    }
    
    return view;
}

- (void)setParentController:(NIBController *)controller
{
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:[NIBView class]])
        {
            NIBView *nibView = (NIBView *)subview;
            [nibView setParentController:controller];
        }
    }
    
    if (self.selfController)
    {
        [controller addChildViewController:self.selfController];
        self.selfController = nil;
    }
}

@end
