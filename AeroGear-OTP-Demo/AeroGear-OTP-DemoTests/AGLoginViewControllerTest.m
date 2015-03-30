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

#import <SenTestingKit/SenTestingKit.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import "AGLoginViewControler.h"

@interface AGLoginViewControllerTest : SenTestCase
@end

@implementation AGLoginViewControllerTest
{
    AGLoginViewControler *loginViewController;
}

- (void)setUp
{
    [super setUp];
    loginViewController = [[AGLoginViewControler alloc] init];
    [loginViewController view];
}

- (void)testUsernameTextFieldShouldBeConnected
{
    assertThat([loginViewController username], is(notNilValue()));
}

- (void)testPasswordTextFieldShouldBeConnected
{
    assertThat([loginViewController password], is(notNilValue()));
}

- (void)testLoginButtonShouldBeConnected
{
    assertThat([loginViewController login], is(notNilValue()));
}

- (void)testUsernameTextFieldShouldBeJohn
{
    assertThat([[loginViewController username] text], is(@"john"));
}

- (void)testPasswordTextFieldShouldBe123
{
    assertThat([[loginViewController password] text], is(@"123"));
}

-(void)testLoginButtonActionIsConnected
{
    UIButton *loginButton = [loginViewController login];
    NSArray *actions = [loginButton actionsForTarget:loginViewController forControlEvent:UIControlEventTouchUpInside];
    assertThat(actions, contains(@"buttonPressed:", nil));
}

@end
