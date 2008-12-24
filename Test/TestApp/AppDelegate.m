#import "AppDelegate.h"
#import <EDMessage/EDMessage.h>

@implementation AppDelegate

- (IBAction) buttonSend:(id)sender
{
    NSLog(@"button start");

	[NSThread detachNewThreadSelector:@selector(sendMail) toTarget:self withObject:nil];		

    NSLog(@"button stop");
}

- (void) sendMail
{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    BOOL err = NO;

    @try { 

        NSMutableDictionary	*headerFields = [NSMutableDictionary dictionary];

        [headerFields setObject:@"Testing EdMessage" forKey:EDMailSubject];
        [headerFields setObject:@"from@domain.org" forKey:EDMailTo];
        [headerFields setObject:@"to@domain.org" forKey:EDMailFrom];

        EDMailAgent	*mailAgent = [EDMailAgent mailAgentForRelayHostWithName:@"smtp.gmail.com" port:587]; 

        [mailAgent setUsesSecureConnections:YES];
                    
        NSMutableDictionary *authInfo = [NSMutableDictionary dictionary];
        [authInfo setObject:@"username" forKey:EDSMTPUserName];
        [authInfo setObject:@"xxxx" forKey:EDSMTPPassword];

        [mailAgent setAuthInfo:authInfo];

        NSLog(@"Sending mail...");

        [mailAgent sendMailWithHeaders:headerFields andBody:@"body"];


    }
    @catch (NSException *theException) { 
        err = YES;
    }
    
    if (err) {
        [self performSelectorOnMainThread:@selector(mailFailed) withObject:nil waitUntilDone:NO];
    } else {
        [self performSelectorOnMainThread:@selector(mailFinshed) withObject:nil waitUntilDone:NO];
    }

    [pool release];
}

- (void) mailFinshed
{
    NSLog(@"Mail sending finished successfully");
}

- (void) mailFailed
{
    NSLog(@"Mail sending failed");
}


@end
