/// @file frame.hpp

#ifndef FRAME_HPP
#define FRAME_HPP FRAME_HPP
#include "timer.hpp"

class MyFrame : public wxFrame{
  Loop* timer;
  Snake* snake;
public:
  MyFrame(
    unsigned int size,
    unsigned int title_hight
    );
  ~MyFrame();
  void on_close(wxCloseEvent &evt);
};

#endif //FRAME_HPP
