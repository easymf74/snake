/// @file snake.hpp

#ifndef SNAKE_HPP
#define SNAKE_HPP SNAKE_HPP

#include "wx/wx.h"

class Snake :public wxPanel{
public:
  Snake(wxFrame* parent, unsigned int size);
  void on_loop();
private:
  const unsigned int number_of_boxes = 15;
  const int LEFT   = -1;
  const int RIGHT  =  1;
  const int UP     = -1;
  const int DOWN   =  1;
  unsigned int size;
  unsigned int box_size;
  unsigned int head_x;
  unsigned int head_y;
  int dir_x =0;
  int dir_y =0;
  void adjust_size();
  void on_resize(wxSizeEvent &evt);
  void init();
  void on_paint(wxPaintEvent &evt);
  void on_key(wxKeyEvent &evt);
  void show();
  void render(wxDC &dc);
};

#endif //SNAKE_HPP
