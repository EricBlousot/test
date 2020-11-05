#property copyright "Eric Blousot"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade trade;

const int layers[3] = {5,3,1};

int OnInit(){
   Print("Initialisation of Genetic Algorithm");
   string filename="TradeNeurons.txt";
   if(!FileIsExist(filename)){
      int filehandle=FileOpen(filename,FILE_WRITE|FILE_TXT);
      if(filehandle<0){
         Print("Failed to open the file ",filename," (Error code ",GetLastError(),")");
        }
      else{
         FileWrite(filehandle,"Bonjour à tous!");
         FileClose(filehandle);
      }
   }
     
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
}

void OnTick(){
}