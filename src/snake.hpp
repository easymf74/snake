/// @file snake.hpp

#ifndef SNAKE_HPP
#define SNAKE_HPP SNAKE_HPP

#include "wx/wx.h"
#include <deque>

class Snake :public wxPanel{
public:
  Snake(wxFrame* parent, unsigned int size);
  void on_loop();
private:
  struct Position{
    unsigned int x;
    unsigned int y;
  };
  const unsigned int number_of_boxes = 15;
  const int LEFT   = -1;
  const int RIGHT  =  1;
  const int UP     = -1;
  const int DOWN   =  1;
  unsigned int size;
  unsigned int box_size;
  int dir_x;
  int dir_y;
  int  pausen_dir_x;
  int  pausen_dir_y;
  bool stop;
  Position head;
  Position rat;
  std::deque<Position> tail;
  void adjust_size();
  void on_resize(wxSizeEvent &evt);
  void init();
  void on_paint(wxPaintEvent &evt);
  void on_key(wxKeyEvent &evt);
  void show();
  void render(wxDC &dc);
  void draw_box(
    wxDC &dc,
    const wxBrush& c,
    unsigned int x,
    unsigned int y
    );
  void quit();
//---------------------------------------

  void test_game_over();
  bool on_snake(const Position&) const;
  Position make_rat();
  bool got_rat() const;
  void pause();
};

#endif //SNAKE_HPP
