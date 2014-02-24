/*
 NIBChain.h
 
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol NIBChainProtocol <NSObject>

@property (nonatomic) CGSize savedSize;
@property (nonatomic, readonly) BOOL removedFromSuperview;
@property (nonatomic, weak) IBOutlet UIView<NIBChainProtocol> *nextView;

@end

@interface UIView (NIBChain)

- (void)checkAutoresizingMask:(UIViewAutoresizing *)autoresizingMask;
- (void)removeChainedViewFromSuperview;
- (void)setChainedViewHidden:(BOOL)hidden;
- (void)reframeNextChainedView;

@end
