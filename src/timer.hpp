/// @file timer.hpp

#ifndef TIMER_HPP
#define TIMER_HPP TIMER_HPP

#include "snake.hpp"

class Loop :public wxTimer{
  Snake* snake;
public:
  Loop(Snake* snake);
  void start();
  void Notify() override;
};

#endif //TIMER_HPP
