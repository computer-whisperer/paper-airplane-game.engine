library Utilities;
import 'dart:math';

class vector2{
  bool rot = false;
  num x,y,rindex = 0;
  vector2([this.x,this.y]){
  if(this.x == null){
    x = 0;
    y = 0;
  }
  }
  round() => new vector2(x.round(),y.round());
  void rotate(num radians){
    num oldx = x;
    num oldy = y;
    x = oldx*cos(-radians) - oldy*sin(-radians);
    y = oldx*sin(-radians) + oldy*cos(-radians);
    rindex += radians;
  }
  num getDistanceTo(vector2 f){
   return sqrt((f.y - y)*(f.y - y) + (f.x - x)*(f.x - x));
  }
  void rotateTo(num radians) => rotate(radians - rindex);
  vector2 operator +(vector2 v) => new vector2(x+v.x,y+v.y);
  vector2 operator /(num v) => new vector2(x/v,y/v);
  vector2 operator *(num v) => new vector2(x*v,y*v);
  vector2 operator -(vector2 v) => new vector2(x-v.x,y-v.y);
  num get magnitude => getDistanceTo(new vector2()).abs();
  num get angle{
    num r = atan(y/x);
    if(y<0)r += PI/2;
    return r;
  }
 // static vector2 dot(vector2 v1,vector2 v2) => cos(v1.angle-v2.angle);
}

class vector2R extends vector2{
  num r;
  vector2R([num x,num y,this.r]) : super(x,y){
  if(this.r == null)r = 0;
  rot = true;
  }
  vector2R operator +(var v){
    if(v.rot != false) return new vector2R(x+v.x,y+v.y,r+v.r);
    else return new vector2R(x+v.x,y+v.y,r);
  }
  vector2R operator /(num v) => new vector2R(x/v,y/v,r/v);
  vector2R operator *(num v) => new vector2R(x*v,y*v,r*v);
  vector2R operator -(var v){
    if(v.rot != false)return new vector2R(x-v.x,y-v.y,r-v.r);
    else return new vector2R(x-v.x,y-v.y,r);
  }
}

class force{
  vector2 forceVector;
  vector2 point;
  force([this.forceVector,this.point]){
    if(forceVector == null){
      forceVector = new vector2();
      point = new vector2();
    }
  }
  void rotateForce(num radians) =>forceVector.rotate(radians);
  void rotateForceTo(num radians) => forceVector.rotateTo(radians);

  static vector2R add(List<force> l){
    vector2R sum = new vector2R(0,0,0);
    for(int i = 0; i < l.length; i++){
      force f = l[i];
      if((f.point.x == 0 && f.point.y == 0)||(f.forceVector.x == 0 && f.forceVector.y == 0))sum += f.forceVector;
      else{
      if(f.point.x != 0)f.rotateForce(atan(f.point.y/f.point.x));
      else f.rotateForce(PI/2);
      if(f.point.x < 0)f.forceVector *= -1;
      vector2 directionalForce = new vector2(f.forceVector.x,0);
      num distance = sqrt(f.point.y*f.point.y + f.point.x*f.point.x);
      num rotationalForce = -f.forceVector.y/distance;
      if(rotationalForce.isInfinite())rotationalForce = 0;
      if(f.point.x != 0)f.rotateForce(-atan(f.point.y/f.point.x));
      else f.rotateForce(-PI/2);
      sum += new vector2R(directionalForce.x,directionalForce.y,rotationalForce);
      }
    }
    //l.forEach((force e){sum += e.forceVector;});
    return sum;
  }
}

class colors{
  static num black = -16777216;
  static num white = -1;
}

class RK4Derivative{
  vector2R dPos,dVel;
}

class State{
  vector2R pos,vel;
  num mass;
  State(this.mass, [this.pos, this.vel]){
    if(this.pos == null){
      pos = new vector2R();
      vel = new vector2R();
    }
  }
  vector2 translateToWorld(vector2 v){
    v.rotate(pos.r);
    v += new vector2(pos.x,pos.y);
    return v;
  }
  vector2 translateToState(vector2 v){
    v -= new vector2(pos.x,pos.y);
    v.rotate(pos.r);
    return v;
  }
}