// frame.cpp

#include "frame.hpp"

MyFrame::MyFrame(
  unsigned int size,
  unsigned int title_hight)
  :wxFrame((wxFrame*)NULL,
    wxID_ANY,
    wxT("S N A K E - by Maik Friemel"),
    wxPoint(400,100),
    wxSize(size,size+title_hight)
    ){
  wxBoxSizer* sizer = new wxBoxSizer(wxHORIZONTAL);
  snake = new Snake(this,size);
  sizer->Add(snake,1,wxEXPAND);
  SetSizer(sizer);
  timer = new Loop(snake);
  Show();
  timer->start();
  
  Bind(wxEVT_CLOSE_WINDOW,&MyFrame::on_close,this);
};

MyFrame::~MyFrame(){
  delete timer;
}

void MyFrame::on_close(wxCloseEvent &evt){
  timer->Stop();
  evt.Skip();
}
