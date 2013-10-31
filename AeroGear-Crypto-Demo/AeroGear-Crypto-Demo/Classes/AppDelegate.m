/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import "AGLoginViewController.h"
#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    self.viewController = [[AGLoginViewController alloc] init];
    self.window.rootViewController = self.viewController;
    
    // set background
    UIView *backgroundView = [[UIView alloc] initWithFrame: self.window.frame];
    backgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    [self.window addSubview:backgroundView];
    
    [self.window makeKeyAndVisible];
    
    return YES;

}
							


@end
