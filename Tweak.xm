#import "Macros.h"
#import "Vector3.hpp"
#import "esp.h"
#import "Obfuscate.h"
#import "Quaternion.hpp"
#import <string>

using namespace std;

int get_Health(void *_this){
  int (*hp)(void *instance) = (int (*)(void *))getRealOffset(0x1030ACDDC);
  return hp(_this);
}

bool get_isLiving(void *_this){
  return get_Health(_this) > 1;
}

bool IsCharacterDead(void *_this){
    return get_Health(_this) < 1;
}

void *GetLocalPlayer() {
    void *(*local)() = (void *(*)())getRealOffset(0x1027EB588);
    return (void *)local();
}

 Vector3 GetForward(void *player) {
    Vector3 (*_GetForward)(void *players) = (Vector3 (*)(void *))getRealOffset(0x1041610D0);
    return _GetForward(player);
}

void *(*Component$$get_transform)(void *component) = (void *(*)(void *))getRealOffset(0x10411F080);
void (*Transform$$get_position_Injected)(void *Transform, Vector3 *outPosition) = (void (*)(void *, Vector3 *))getRealOffset(0x104160870);

void *camera(){
void *(*get_main)() = (void *(*)())getRealOffset(0x10411D678);
return (void *) get_main();

}



Vector3 WorldToScreenPoint(void *cam, Vector3 test) {


    Vector3 (*Camera$$WorldToViewport_Injected)(void *, Vector3, int) = (Vector3 (*)(void *,Vector3, int))getRealOffset(0x10411CDC4);
    return Camera$$WorldToViewport_Injected(cam, test, 2);
}




Vector3 getPosition(void *component){
  Vector3 out;
  void *transform = Component$$get_transform(component);
  Transform$$get_position_Injected(transform, &out);
  return out;
}



struct enemy_t {
    void *object;
    Vector3 location;
    Vector3 worldtoscreen;
    bool enemy;
    float health;
    float distance;
};

struct me_t {
	void *object;
	Vector3 location;
	int team;
};

me_t *me;


class EntityManager {
public:
    std::vector<enemy_t *> *enemies;

    EntityManager() {
        enemies = new std::vector<enemy_t *>();
    }

    bool isEnemyPresent(void *enemyObject) {
        for (std::vector<enemy_t *>::iterator it = enemies->begin(); it != enemies->end(); it++) {
            if ((*it)->object == enemyObject) {
                return true;
            }
        }

        return false;
    }

    void removeEnemy(enemy_t *enemy) {
        for (int i = 0; i < enemies->size(); i++) {
            if ((*enemies)[i] == enemy) {
                enemies->erase(enemies->begin() + i);

                return;
            }
        }
    }
 
    void tryAddEnemy(void *enemyObject) {
        if (isEnemyPresent(enemyObject)) {
            return;
        }

        if (IsCharacterDead(enemyObject)) {
            return;
        }

        enemy_t *newEnemy = new enemy_t();

        newEnemy->object = enemyObject;

        enemies->push_back(newEnemy);
    }

    void updateEnemies(void *enemyObject) {
        for (int i = 0; i < enemies->size(); i++) {
            enemy_t *current = (*enemies)[i];

            if(IsCharacterDead(current->object)) {
                enemies->erase(enemies->begin() + i);
            }
            
        }
    }

    void removeEnemyGivenObject(void *enemyObject) {
        for (int i = 0; i < enemies->size(); i++) {
            if ((*enemies)[i]->object == enemyObject) {
                enemies->erase(enemies->begin() + i);

                return;
            }
        }
    }
    std::vector<enemy_t *> *GetAllEnemies() {
        return enemies;
    }
    void *getClosestEnemy(Vector3 myLocation){
			if(enemies->empty()){
				return NULL;
			}
			updateEnemies((*enemies)[0]);
			
			float shortestDistance = 99999999.0f;
			void *closestEnemy = NULL;
			
			for(int i = 0; i<enemies->size(); i++){
			if((*enemies)[i]->object != NULL){
				Vector3 currentLocation = (*enemies)[i]->location;
				float distanceToMe = Vector3::Distance(currentLocation, myLocation);
				
				if(distanceToMe < shortestDistance){
					shortestDistance = distanceToMe;
					closestEnemy = (*enemies)[i]->object;
				}
			}
			
			return closestEnemy;
		}
		}
};



static esp* es;
EntityManager *entityManager = new EntityManager();
int playerTeam = 0;



void (*LateUpdate)(void* _this);
void _LateUpdate(void* _this) 
{

if (_this != NULL) {
  entityManager->tryAddEnemy(_this);
  entityManager->updateEnemies(_this);
  
    std::vector<enemy_t *> *enemies = entityManager->GetAllEnemies();
    std::vector<player_t *> *pplayers = nullptr;
UIWindow *main = [UIApplication sharedApplication].keyWindow;
      void *mycam = camera();
      me->object = GetLocalPlayer();
      if(me->object != NULL) {
        me->location = getPosition(me->object);
          
            for(int i =0; i<entityManager->enemies->size(); i++){
                
                if(mycam != NULL) {

                  if((*enemies)[i]->object != NULL) {
               (*enemies)[i]->location = getPosition((*enemies)[i]->object);
               if((*enemies)[i]->location != Vector3(0,0,0)) {
              Vector3 orig = (*enemies)[i]->location;
              orig.Y += 1.3f;
              (*enemies)[i]->worldtoscreen = WorldToScreenPoint(mycam, orig);
              (*enemies)[i]->enemy = true;
              (*enemies)[i]->health = get_Health((*enemies)[i]->object);
            float xd = pow(me->location.X - (*enemies)[i]->location.X, 2);
            float xd1= pow(me->location.Y - (*enemies)[i]->location.Y, 2);
            float xd2 = pow(me->location.Z - (*enemies)[i]->location.Z, 2);
            float dist = sqrt(xd + xd1 + xd2);
              (*enemies)[i]->distance = dist;
            
           
              
                if(!pplayers){
                  pplayers = new std::vector<player_t *>();
                }
                
                  if(!enemies->empty()){
                    for(int i = 0; i < enemies->size(); i++) {
                      if([switches isSwitchOn:@"ESP"]){
                        if((*enemies)[i]->worldtoscreen.Z > 0){
                          player_t *newplayer = new player_t();
                          Vector3 newvec = (*enemies)[i]->worldtoscreen;
                          newvec.Y = fabsf(1-newvec.Y);
                          float dx = 100.0f/(newvec.Z/4);
                          float dy = 200.0f/(newvec.Z/4);
                          float xxxx = (main.frame.size.width*newvec.X)-dx/2;
                          float yyyy = (main.frame.size.height*newvec.Y)-dy/4;
                    
              newplayer->health = (*enemies)[i]->health;
              newplayer->enemy = (*enemies)[i]->enemy;
              newplayer->rect = CGRectMake(xxxx, yyyy, dx, dy);
              newplayer->healthbar = CGRectMake(xxxx, yyyy, 2, dy);
              newplayer->topofbox = CGPointMake(xxxx, yyyy);
              newplayer->distance = (*enemies)[i]->distance;
            pplayers->push_back(newplayer);
        }
      }
      es.players = pplayers;
    }
        if([switches isSwitchOn:@"ESP BOX"]){
          es.espboxes = true;  
        } else {
          es.espboxes = false;
        }

        if([switches isSwitchOn:@"ESP LINE"]) {
          es.esplines = true;
        } else {
          es.esplines = false;
        }

        if([switches isSwitchOn:@"ESP HEALTHBAR"]) {
          es.healthbarr = true;
        } else {
          es.healthbarr = false;
        }
      }
      }
      }
      }
     }
    }
      }
  LateUpdate(_this);
}



void (*Character$$Destroy)(void *_this);
void _Character$$Destroy(void *_this){
if(_this != NULL) {
  entityManager->removeEnemyGivenObject(_this);
  }
Character$$Destroy(_this);
}



void setup(){

me = new me_t();
entityManager= new EntityManager();

HOOK(0x1030A21BC, _LateUpdate, LateUpdate);

HOOK(0x103077254, _Character$$Destroy, Character$$Destroy);



  [switches addSwitch:@"ESP"
              description:@"ESP"];
			  
  [switches addSwitch:@"ESP BOX"
              description:@"ESP BOX"];

  [switches addSwitch:@"ESP LINE"
              description:@"ESP LINE"];
              
  [switches addSwitch:@"ESP HEALTHBAR"
              description:@"ESP HEALTHBAR"];
      

}



void setupMenu() {


[menu setFrameworkName:NULL];
menu = [[Menu alloc]              
initWithTitle: @"Free Fire ESP 34306"
titleColor: [UIColor whiteColor]
titleFont: @"San Francisco"
credits: @"This Mod Menu has been made by 34306.\n\nEnjoy!"
headerColor: UIColorFromHex(0xADD8E6)
switchOffColor: [UIColor colorWithRed: 0.00 green: 0.00 blue: 0.00 alpha: 0.30]
switchOnColor: [UIColor colorWithRed: 0.00 green: 0.68 blue: 0.95 alpha: 1.00]
switchTitleFont: @"San Francisco"
switchTitleColor: [UIColor whiteColor]
infoButtonColor: UIColorFromHex(0xBD0000)
maxVisibleSwitches: 4
menuWidth: 270

menuIcon: @"iVBORw0KGgoAAAANSUhEUgAAADcAAAA3CAYAAACo29JGAAAACXBIWXMAAC4jAAAuIwF4pT92AAAGmGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxNDIgNzkuMTYwOTI0LCAyMDE3LzA3LzEzLTAxOjA2OjM5ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOCAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIxLTA4LTI0VDA1OjAzOjM1KzA3OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDIxLTA4LTI0VDA1OjAzOjM1KzA3OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMS0wOC0yNFQwNTowMzozNSswNzowMCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDoyMjY1NzU5OC0wZWQ1LTUzNGYtODIzYy01YmEzMzY0Y2UxNjUiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDplNWIxYTgzOS02ZWJiLWJhNDEtODg1Zi1mNzEyOThjOThjMDciIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDozNDhlMTZhYS1mMmUyLWY1NGItOTM0MC05ZjA4ZTBmYWMzODciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiIHBob3Rvc2hvcDpJQ0NQcm9maWxlPSJzUkdCIElFQzYxOTY2LTIuMSIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjM0OGUxNmFhLWYyZTItZjU0Yi05MzQwLTlmMDhlMGZhYzM4NyIgc3RFdnQ6d2hlbj0iMjAyMS0wOC0yNFQwNTowMzozNSswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTggKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDoyMjY1NzU5OC0wZWQ1LTUzNGYtODIzYy01YmEzMzY0Y2UxNjUiIHN0RXZ0OndoZW49IjIwMjEtMDgtMjRUMDU6MDM6MzUrMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE4IChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPHBob3Rvc2hvcDpEb2N1bWVudEFuY2VzdG9ycz4gPHJkZjpCYWc+IDxyZGY6bGk+YWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjgxYjM3YjQ3LTBkMGQtZGY0YS1hNGY1LTM1ZTRlOGY5ZDJlYzwvcmRmOmxpPiA8L3JkZjpCYWc+IDwvcGhvdG9zaG9wOkRvY3VtZW50QW5jZXN0b3JzPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PhkuX2QAAB50SURBVGiBhZp5kF3Hdd5/3Xd9+2xv9sEMgMFOAARIARRBUiRl7ZatSIok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"
menuButton: @"iVBORw0KGgoAAAANSUhEUgAAADcAAAA3CAYAAACo29JGAAAACXBIWXMAAC4jAAAuIwF4pT92AAAGmGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxNDIgNzkuMTYwOTI0LCAyMDE3LzA3LzEzLTAxOjA2OjM5ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOCAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIxLTA4LTI0VDA1OjAzOjM1KzA3OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDIxLTA4LTI0VDA1OjAzOjM1KzA3OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMS0wOC0yNFQwNTowMzozNSswNzowMCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDoyMjY1NzU5OC0wZWQ1LTUzNGYtODIzYy01YmEzMzY0Y2UxNjUiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDplNWIxYTgzOS02ZWJiLWJhNDEtODg1Zi1mNzEyOThjOThjMDciIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDozNDhlMTZhYS1mMmUyLWY1NGItOTM0MC05ZjA4ZTBmYWMzODciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiIHBob3Rvc2hvcDpJQ0NQcm9maWxlPSJzUkdCIElFQzYxOTY2LTIuMSIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjM0OGUxNmFhLWYyZTItZjU0Yi05MzQwLTlmMDhlMGZhYzM4NyIgc3RFdnQ6d2hlbj0iMjAyMS0wOC0yNFQwNTowMzozNSswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTggKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDoyMjY1NzU5OC0wZWQ1LTUzNGYtODIzYy01YmEzMzY0Y2UxNjUiIHN0RXZ0OndoZW49IjIwMjEtMDgtMjRUMDU6MDM6MzUrMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE4IChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPHBob3Rvc2hvcDpEb2N1bWVudEFuY2VzdG9ycz4gPHJkZjpCYWc+IDxyZGY6bGk+YWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjgxYjM3YjQ3LTBkMGQtZGY0YS1hNGY1LTM1ZTRlOGY5ZDJlYzwvcmRmOmxpPiA8L3JkZjpCYWc+IDwvcGhvdG9zaG9wOkRvY3VtZW50QW5jZXN0b3JzPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PhkuX2QAAB50SURBVGiBhZp5kF3Hdd5/3Xd9+2xv9sEMgMFOAARIARRBUiRl7ZatSIok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"];

    setup();
}


static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
  timer(5) {
        UIWindow *main = [UIApplication sharedApplication].keyWindow;
es = [[esp alloc]initWithFrame:main];
        setupMenu();
      });     
}

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}