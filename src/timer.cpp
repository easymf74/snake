// timer.cpp

#include "timer.hpp"

Loop::Loop(Snake* snake)
  :wxTimer(),snake(snake){}

void Loop::start(){
  wxTimer::Start(200);
}

void Loop::Notify(){
  // snake->Refresh();
  snake->on_loop();
}
