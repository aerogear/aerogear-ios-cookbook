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

-(void)testLoginButtonAction
{
    UIButton *loginButton = [loginViewController login];
    NSArray *actions = [loginButton actionsForTarget:loginViewController forControlEvent:UIControlEventTouchUpInside];
    assertThat(actions, contains(@"buttonPressed:", nil));
}

@end
