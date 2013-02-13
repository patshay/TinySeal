//
//  HelloWorldLayer.h
//  TinySeal
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "Terrain.h"

#define PTM_RATIO 32.0

@interface HelloWorldLayer : CCLayer
{
	CCSprite * _background;
    Terrain * _terrain;
    b2World * _world;
}

+(CCScene *) scene;

@end
