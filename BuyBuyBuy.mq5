#property copyright "Eric Blousot"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade trade;

int OnInit(){
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
}

void OnTick(){
   static datetime timeStamp;
   datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(timeStamp != time){
      timeStamp = time;
      static int nbBuy=1;
      static int nbSell=1;
      
      static int values = iMA(_Symbol, PERIOD_CURRENT,10,0, MODE_SMA, PRICE_CLOSE);
      double valuesArray[];
      CopyBuffer(values,0,0,2,valuesArray);
      ArraySetAsSeries(valuesArray,true);
      
      if(valuesArray[0]>valuesArray[1]){
         nbSell=1;
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double stopLoss = ask - 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double takeProfit = ask + 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         if(trade.Buy(0.01*nbBuy, _Symbol, ask, stopLoss, takeProfit, ("Buy "+nbBuy))){
            nbBuy+=5;
         }
         else{
            nbBuy=1;
            trade.Buy(0.01*nbBuy, _Symbol, ask, stopLoss, takeProfit, ("Buy "+nbBuy));
         }
      }
      
      else if(valuesArray[0]<valuesArray[1]){
         nbBuy=1;
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double stopLoss = bid + 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double takeProfit = bid - 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         if(trade.Sell(0.01*nbSell, _Symbol, bid, stopLoss, takeProfit, ("Sell "+nbSell))){
            nbSell+=5;
         }
         else{
            nbSell=1;
            trade.Sell(0.01*nbSell, _Symbol, bid, stopLoss, takeProfit, ("Sell "+nbSell));
         }
      }
      
      Comment("\nNb Buy : ",nbBuy,"\nNb Sell : ",nbSell, "\nOpened Positions : ",PositionsTotal());
   
   }
}