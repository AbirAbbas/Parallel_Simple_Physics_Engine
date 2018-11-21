// used to slow curses animation
#define DELAY 50000

// number of balls
#define POPSIZE 50
// ball radius, all circles have the same radius
#define RADIUS 1.0
// indicate if balls collide or not
#define COLLIDE 1
#define NOCOLLIDE 0
// restitution controls how bounce the objects will be
#define RESTITUTION 0.5
// object mass
#define MASS 1.0

// maximum screen size, both height and width
#define SCREENSIZE 100

// ball location (x,y,z) and velocity (vx,vy,vz) in ballArray[][]
#define BX 0
#define BY 1
#define VX 2
#define VY 3

//calculate effects of collision between ballArray[i][] and
//ballArray[j][] where i and j are the parameters to the function
void resolveCollision(int i, int j, float * ballArray, float * ballUpdate) {
    
    float rvx, rvy;
    float nx, ny;
    float distance;
    float vnormal;
    float impulse;
    float ix, iy;
    
    // calculate relative velocity
    rvx = ballArray[j][VX] - ballArray[i][VX];
    rvy = ballArray[j][VY] - ballArray[i][VY];
    
    // calculate collision normal
    nx = ballArray[j][BX] - ballArray[i][BX];
    ny = ballArray[j][BY] - ballArray[i][BY];
    
    // Pythagorean distance
    distance = sqrtf(powf((ballArray[j][BX]-ballArray[i][BX]),2)
                     + powf((ballArray[j][BY]-ballArray[i][BY]),2));
    if (distance == 0) return;
    
    nx = nx / distance;
    ny = ny / distance;
    
    // Calculate relative velocity in terms of the normal direction
    vnormal = dotProduct(rvx, rvy, nx, ny);
    
    // Do not resolve if velocities are separating
    if(vnormal > 0)
        return;
    
    // Calculate impulse scalar
    impulse = -(1 + RESTITUTION) * vnormal;
    impulse /= ((1 / MASS) + (1 / MASS));
    
    // Apply impulse
    ix = impulse * nx;
    iy = impulse * ny;
    ballUpdate[i][BX] = ballArray[i][VX] - ((1/MASS) * impulse);
    ballUpdate[i][BY] = ballArray[i][VY] - ((1/MASS) * impulse);
    ballUpdate[j][BX] = ballArray[j][VX] + ((1/MASS) * impulse);
    ballUpdate[j][BY] = ballArray[j][VY] + ((1/MASS) * impulse);
    
}

__kernel void moveBalls(__global float4 * ballArray,
      __global float2 * ballUpdate, int i) {

    int i,j;
    
    // update velocity of balls based upon collisions
    // compare all balls to all other circles using two loops
    
    for (j=i+1; j<POPSIZE; j++) {
        if (ballCollision(i, j) == COLLIDE){
            resolveCollision(i, j, ballArray, ballUpdate);
        }
    }
    
    // move balls by calculating updating velocity and position
    // update velocity for each ball
    if (ballUpdate[i][BX] != 0.0) {
        ballArray[i][VX] = ballUpdate[i][BX];
        ballUpdate[i][BX] = 0.0;
    }
    if (ballUpdate[i][BY] != 0.0) {
        ballArray[i][VY] = ballUpdate[i][BY];
        ballUpdate[i][BY] = 0.0;
    }
    
    // enforce maximum velocity of 2.0 in each axis
    // done to make it easier to see collisions
    if (ballArray[i][VX] > 2.0) ballArray[i][VX] = 2.0;
    if (ballArray[i][VY] > 2.0) ballArray[i][VY] = 2.0;
    
    // update position for each ball
    ballArray[i][BX] += ballArray[i][VX];
    ballArray[i][BY] += ballArray[i][VY];
    
    // if ball moves off the screen then reverse velocity so it bounces
    // back onto the screen, and move it onto the screen
    if (ballArray[i][BX] > (SCREENSIZE-1)) {
        ballArray[i][VX] *= -1.0;
        ballArray[i][BX] = SCREENSIZE - 1.5;
    }
    if (ballArray[i][BX] < 0.0) {
        ballArray[i][VX] *= -1.0;
        ballArray[i][BX] = 0.5;
    }
    if (ballArray[i][BY] > (SCREENSIZE-1)) {
        ballArray[i][VY] *= -1.0;
        ballArray[i][BY] = SCREENSIZE - 1.5;
    }
    if (ballArray[i][BY] < 0.0) {
        ballArray[i][VY] *= -1.0;
        ballArray[i][BY] = 0.5;
    }
        
}
