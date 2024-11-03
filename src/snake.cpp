// snake.cpp

#include "snake.hpp"
#include <iostream>

Snake::Snake(wxFrame* parent, unsigned int size)
  :wxPanel(parent),size(size){

  adjust_size();
  init();

  Bind(wxEVT_PAINT,&Snake::on_paint,this);
  Bind(wxEVT_SIZE,&Snake::on_resize,this);
  Bind(wxEVT_KEY_DOWN,&Snake::on_key,this);
}

void Snake::adjust_size(){
  box_size = size / number_of_boxes;
  size = number_of_boxes *box_size;
  show();
}

void Snake::init(){
  head_y = head_x = number_of_boxes / 2;
}

void Snake::on_resize(wxSizeEvent &evt){
  size = evt.GetSize().GetHeight();
  int width = evt.GetSize().GetWidth();
  if((unsigned int)width < size)
    size = width;
  adjust_size();
}


void Snake::on_paint(wxPaintEvent &evt){
  wxPaintDC dc(this);
  render(dc);
}

void Snake::on_loop(){
  // go in direction
  head_x+= dir_x;
  head_y+= dir_y;

  
  Refresh();
}

void Snake::on_key(wxKeyEvent &evt){
  int key = evt.GetKeyCode();
  if(key == WXK_LEFT && dir_x != RIGHT)
    dir_x = LEFT, dir_y=0;
  else if (key == WXK_RIGHT && dir_x != LEFT)
    dir_x = RIGHT, dir_y=0;
  else if (key == WXK_UP && dir_y != DOWN)
    dir_y = UP, dir_x=0;
  else if (key == WXK_DOWN && dir_y != UP)
    dir_y = DOWN, dir_x=0;

  //std::cout << dir_x << " | " << dir_y << std::endl;
}

void Snake::show(){
  wxClientDC dc(this);
  render(dc);
}

void Snake::render(wxDC &dc){
  
 
  //set the head
  dc.SetBrush(*wxYELLOW);
  unsigned int pos_x = head_x * box_size;
  unsigned int pos_y = head_y * box_size;
  dc.DrawRectangle(pos_x, pos_y, box_size, box_size);
  
  // set the grid
  dc.SetPen(wxPen(wxColor(255,255,255),1));
  for(unsigned int i=0;i<=number_of_boxes;++i){
    unsigned int dist = i*box_size;
    dc.DrawLine(dist, 0, dist,size);
    dc.DrawLine(0, dist, size,dist);
  }

  
}
