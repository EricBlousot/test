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
   //ne change pas
   static datetime timeStamp;
   //time of the current candle, initialisé à chaque fois
   datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(timeStamp != time){
   timeStamp = time;
   //static parce que on va le declarer qu'une seule fois
   //iMA = fonction de Indicator Moving Average
   //_Symbol = symbole actuel, EURUSD par exemple. On peut choisir un autre symbole
   //PERIOD_CURRENT = laps de temps choisi dans la courbe (M1, M5, ...)
   //200 est la periode pour le calcul de l'indicateur moving average
   //0 est le shift
   //MODE_SMA est le type de moyenne utilisé par l'indicateur
   //PRICE_CLOSE est la valeur de chaque tick utilisé pour calculer la moyenne
   static int slowMAIndicatorValues = iMA(_Symbol, PERIOD_CURRENT,200,0, MODE_SMA, PRICE_CLOSE);
   //liste qui va contenir les valeurs tampon
   double slowMAArray[];
   //on transfert les 2 dernieres valeurs de slowMAIndicatorValues dans SlowMAArray (en partant de l'indice 0 et pendant 2 valeurs)
   CopyBuffer(slowMAIndicatorValues,0,0,2,slowMAArray);
   //on retourne les indices de la liste slowMAArray
   ArraySetAsSeries(slowMAArray,true);
   
   //on fait tout pareil pour le fast MA
   static int fastMAIndicatorValues = iMA(_Symbol, PERIOD_CURRENT,20,0, MODE_SMA, PRICE_CLOSE);
   double fastMAArray[];
   CopyBuffer(fastMAIndicatorValues,0,0,2,fastMAArray);
   ArraySetAsSeries(fastMAArray,true);
   
   if(fastMAArray[0]>slowMAArray[0] && fastMAArray[1]<slowMAArray[1]){
      Print("fast > slow");
      //get the price of the current symbol (to buy)
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      //calculate a value to use as a stoploss value
      double stopLoss = ask - 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      //calculate a value to use as a takeprofit value
      double takeProfit = ask + 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      //buy 0.01 lots
      trade.Buy(0.01, _Symbol, ask, stopLoss, takeProfit, "This is a buy");
   }
   
   if(fastMAArray[0]<slowMAArray[0] && fastMAArray[1]>slowMAArray[1]){
      Print("fast < slow");
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double stopLoss = bid + 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double takeProfit = bid - 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      trade.Sell(0.01, _Symbol, bid, stopLoss, takeProfit, "This is a sell");
   }
   
   Comment("\nSlowMAArray[0] : ",slowMAArray[0],"\nSlowMAArray[1] : ",slowMAArray[1],"\nFastMAArray[0] : ",fastMAArray[0],"\nFastMAArray[1] : ",fastMAArray[1]);
   
   }
}