#import <SenTestingKit/SenTestingKit.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import "AGOTPViewController.h"

@interface AGOTPViewControllerTest : SenTestCase
@end

@implementation AGOTPViewControllerTest
{
    AGOTPViewController  *otpViewController;
}

- (void)setUp
{
    [super setUp];
    otpViewController = [[AGOTPViewController alloc] init];
    [otpViewController view];
}

- (void)testStatusLabelShouldBeConnected
{
    assertThat([otpViewController status], is(notNilValue()));
}

- (void)testTimerLabelShouldBeConnected
{
    assertThat([otpViewController timer], is(notNilValue()));
}

- (void)testOtpTextFieldShouldBeConnected
{
    assertThat([otpViewController otp], is(notNilValue()));
}

@end
