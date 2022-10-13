#import <Foundation/Foundation.h>
#import "esp.h"
#import <UIKit/UIKit.h>

@implementation esp : UIView
@synthesize players;
@synthesize espboxes;
@synthesize esplines;
@synthesize healthbarr;
@synthesize distanceesp;

- (id)initWithFrame:(UIWindow*)main
{
    self = [super initWithFrame:main.frame];
    self.userInteractionEnabled = false;
    self.hidden = false;
    self.backgroundColor = [UIColor clearColor];
    if(!players){
        players = new std::vector<player_t *>();
    }
    [main addSubview:self];
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    return self;
}

- (void)callupdate {
        [NSTimer scheduledTimerWithTimeInterval:0.01
        target:self
            selector:@selector(update)
            userInfo:nil
            repeats:YES];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextClearRect(contextRef,self.bounds);
    CGContextSetLineWidth(contextRef, 0.5);
    CGColor *colour;
    UIColor *Ucolour;
    for(int i = 0; i < players->size(); i++) {
        if((*players)[i]->enemy){
            colour = [UIColor redColor].CGColor;
            Ucolour = [UIColor redColor];
        }else{
            colour = [UIColor blueColor].CGColor;
            Ucolour = [UIColor blueColor];
        }
if((*players)[i]->enemy){
CGFloat floatx = (*players)[i]->rect.origin.x + (*players)[i]->rect.size.width/2;
        CGFloat floaty = (*players)[i]->rect.origin.y;
        CGContextSetStrokeColorWithColor(contextRef, colour);
           
  if(espboxes){
CGContextStrokeRect(contextRef, (*players)[i]->rect);
}
        if(esplines){
            if((*players)[i]->enemy){
                CGContextMoveToPoint(contextRef,self.frame.size.width/2, 0.0f);
                CGContextAddLineToPoint(contextRef, (*players)[i]->topofbox.x, (*players)[i]->topofbox.y);
            }else{
                CGContextMoveToPoint(contextRef,self.frame.size.width/2, self.frame.size.height);
                CGContextAddLineToPoint(contextRef, (*players)[i]->bottomofbox.x, (*players)[i]->bottomofbox.y);
            }
            CGContextStrokePath(contextRef);
        }
        if(healthbarr){
            [[UIColor redColor] setFill];
            CGContextFillRect(contextRef, (*players)[i]->healthbar);
            [[UIColor greenColor] setFill];
            float cc = (*players)[i]->health/100;
            CGRect healthbar = CGRectMake((*players)[i]->healthbar.origin.x, (*players)[i]->healthbar.origin.y, (*players)[i]->healthbar.size.width, (*players)[i]->healthbar.size.height*cc);
            CGContextFillRect(contextRef, healthbar);
        }
        if(distanceesp){
            NSString *text = [NSString stringWithFormat:@"%.0f", (*players)[i]->distance];
            float xd = 30 / ((*players)[i]->distance/10);
            if(xd>25){
                xd = 25.0f;
            }
            xd = (*players)[i]->rect.size.width/2;
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:xd], NSForegroundColorAttributeName:Ucolour};
            [text drawAtPoint:CGPointMake(((*players)[i]->rect.origin.x), ((*players)[i]->bottomofbox.y)) withAttributes:attributes];
        }

}
   }

}
- (void)update {
    if(esplines || espboxes || healthbarr || distanceesp ){
        [self setNeedsDisplay];
    }
}

@end