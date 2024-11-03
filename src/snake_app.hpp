/// @file snake_app.hpp

#ifndef SNAKE_APP_HPP
#define SNAKE_APP_HPP SNAKE_APP_HPP

#include "frame.hpp"

class SnakeApp :public wxApp{
  const unsigned int SIZE = 500;
  const unsigned int TITLE_HEIGHT = 20;
  
  bool OnInit();
  MyFrame* frame;
};

#endif //SNAKE_APP_HPP
