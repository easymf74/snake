// snake.cpp

#include "snake.hpp"

Snake::Snake(wxFrame* parent, unsigned int size)
  :wxPanel(parent),size(size){

  adjust_size();
  init();
  srand(time(NULL));

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
  stop = false;
  dir_x = dir_y = pausen_dir_x = pausen_dir_y = 0;
  head = {number_of_boxes / 2,number_of_boxes / 2};
  tail.clear();
  rat = make_rat();
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
  Position mem_head = head;
  
  // go in direction
  head.x+= dir_x;
  head.y+= dir_y;

  test_game_over();

  if(!stop && !(pausen_dir_x || pausen_dir_y)) {
    // adjust the tail
    tail.push_front(mem_head);
    if (!got_rat())
      tail.pop_back();
    else
      rat = make_rat();
  }

  Refresh();
}

void Snake::on_key(wxKeyEvent &evt){
  int key = evt.GetKeyCode();
  if (!stop &&  !(pausen_dir_x || pausen_dir_y) ) {
    if (key == WXK_LEFT && dir_x != RIGHT)
      dir_x = LEFT, dir_y = 0;
    else if (key == WXK_RIGHT && dir_x != LEFT)
      dir_x = RIGHT, dir_y = 0;
    else if (key == WXK_UP && dir_y != DOWN)
      dir_y = UP, dir_x = 0;
    else if (key == WXK_DOWN && dir_y != UP)
      dir_y = DOWN, dir_x = 0;
    
  }else if (key == WXK_ESCAPE)
    init();

  if (key == WXK_SPACE)
      pause();
  
}

void Snake::show(){
  wxClientDC dc(this);
  render(dc);
}

void Snake::render(wxDC &dc){
  
  // set the rat
  draw_box(dc, *wxGREEN, rat.x, rat.y);
 
  //set the head
  draw_box(dc, *wxYELLOW, head.x, head.y);

  //set the tail 
  for(const Position &p: tail)
    draw_box(dc,wxColor(139,129, 76) , p.x, p.y);

  // set the grid
  dc.SetPen(wxPen(wxColor(255,255,255),1));
  for(unsigned int i=0;i<=number_of_boxes;++i){
    unsigned int dist = i*box_size;
    dc.DrawLine(dist, 0, dist,size);
    dc.DrawLine(0, dist, size,dist);
  }

}

void Snake::draw_box(
    wxDC &dc,
    const wxBrush& c,
    unsigned int x,
    unsigned int y
  ){
  dc.SetBrush(c);
  dc.DrawRectangle(x*box_size, y*box_size, box_size, box_size);
}

void Snake::quit(){
  head.x -= dir_x;
  head.y -= dir_y;
  dir_x = dir_y = 0;
  stop = true;
}


void Snake::test_game_over(){
  if(on_snake(head))
    quit();
}
bool Snake::on_snake(const Position& p) const{
  if(
    p.x >= number_of_boxes
    ||
    p.y >= number_of_boxes
    ) return true;

  if(tail.size()>1){
    for(unsigned int i=0; !stop && i<tail.size()-2;++i){
      Position t = tail[i];
      if (t.x == p.x && t.y == p.y) 
        return true;
    }// end for tail without the last
  }// end !stop

  return false;
}

Snake::Position Snake::make_rat(){
  Position new_rat;
  do {
    new_rat.x= rand() % number_of_boxes;
    new_rat.y = rand() % number_of_boxes;
  }while(on_snake(new_rat));
  return new_rat;
}

bool Snake::got_rat() const{
  return head.x == rat.x && head.y == rat.y;
}

void Snake::pause() {
  if (pausen_dir_x || pausen_dir_y) {
    dir_x = pausen_dir_x;
    dir_y = pausen_dir_y;
    pausen_dir_x = pausen_dir_y = 0;
  } else {
    pausen_dir_x = dir_x;
    pausen_dir_y = dir_y;
    dir_x = dir_y = 0;
  }
}
