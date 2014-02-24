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

static NSMutableDictionary *nibSizes;

@implementation NIBView

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

+ (instancetype)loadInstanceUsingPlaceholder:(NIBView *)placeholder
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
            
            // Pass placeholder tag through
            view.tag = placeholder.tag;
            
            // Pass placeholder interaction properties through
            view.userInteractionEnabled = placeholder.userInteractionEnabled;
            
            // Pass placeholder alpha through
            view.alpha = placeholder.alpha;
            
            // Pass placeholder drawing properties through
            view.opaque = placeholder.opaque;
            view.hidden = placeholder.hidden;
            
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

+ (instancetype)loadInstanceUsingParentController:(NIBController *)controller
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
            [view setParentController:controller];
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

+ (CGSize)defaultNIBSize
{
    // Initialize sizes dictionary once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nibSizes = [NSMutableDictionary new];
    });
    
    @synchronized(nibSizes)
    {
        // Use nib name as a key
        NSString *nibName = NSStringFromClass([self class]);
        
        // Check if size already exists
        NSValue *sizeValue = [nibSizes objectForKey:nibName];
        if (sizeValue)
        {
            return [sizeValue CGSizeValue];
        }
        else
        {
            UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
            NSArray *itemsInNib = [nib instantiateWithOwner:self options:nil];
            for (UIView *item in itemsInNib)
            {
                if ([item isMemberOfClass:[self class]])
                {
                    [nibSizes setObject:[NSValue valueWithCGSize:item.frame.size] forKey:nibName];
                    return item.frame.size;
                }
            }
        }
    }
    
    return CGSizeZero;
}

@end
