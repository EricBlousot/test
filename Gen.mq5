#property copyright "Eric Blousot"
#property link      "https://www.mql5.com"
#property version   "1.00"

#define RAND_MAX 32767

#include <Trade/Trade.mqh>
CTrade trade;

//set the network configuration
const int layers[5] = {40,20,20,20,1};
const int minRandomNeuronConstant = -100;
const int maxRandomNeuronConstant = 100;
const int minAddRandomNeuronConstant = -5;
const int maxAddRandomNeuronConstant = 5;
const int minRandomWeight = -100;
const int maxRandomWeight = 100;
const int minAddRandomWeight = -5;
const int maxAddRandomWeight = 5;
const int population = 2;

//global variables
int nbNeurons = 0;
int nbWeights = 0;
int neuronsConstants[];
int weights[];

int OnInit(){
   Print("Initialisation of Genetic Algorithm");
   //generate filename according to network configuration
   string filename="TradeNeurons";
   int fileHandle=0;
   for(int i=0;i<ArraySize(layers);i++){
      filename+=("_"+IntegerToString(layers[i]));
   }
   filename+=".txt";
   
   //file recovering/creation
   bool existingFile=false;
   if(!FileIsExist(filename)){
      Print("File ",filename," does not exist, creation needed");
      fileHandle=FileOpen(filename,FILE_WRITE|FILE_TXT);
      if(fileHandle<0){
         Print("Failed to create file ",filename," (Error code ",GetLastError(),")");
         return(INIT_FAILED);
      }
      else{
         Print("File ",filename," successfully created");
         FileClose(fileHandle);
      }
   }
   else{
      existingFile=true;
      Print("Existing file ",filename," founded");
   }
   
   //recover/generate the neurons constants & weights
   for(int i=0;i<ArraySize(layers);i++){
      nbNeurons+=layers[i];
      if(i<ArraySize(layers)-1){
         nbWeights+=(layers[i]*layers[i+1]);
      }
   }
   ArrayResize(neuronsConstants,nbNeurons*population);
   ArrayResize(weights,nbWeights*population);
   if(!existingFile){
      fileHandle=FileOpen(filename,FILE_WRITE|FILE_TXT);
      for(int i=0;i<nbNeurons;i++){
         double r = MathRand();
         neuronsConstants[i]=(int)(MathRound(minRandomNeuronConstant + (r/RAND_MAX)*(maxRandomNeuronConstant-minRandomNeuronConstant)));
         FileWrite(fileHandle, neuronsConstants[i]);
      }
      for(int i=0;i<nbWeights;i++){
         double r = MathRand();
         weights[i]=(int)(MathRound(minRandomWeight + (r/RAND_MAX)*(maxRandomWeight-minRandomWeight)));
         FileWrite(fileHandle, weights[i]);
      }
      FileClose(fileHandle);
   }
   else{
      fileHandle=FileOpen(filename,FILE_READ|FILE_TXT);
      for(int i=0;i<nbNeurons;i++){
         neuronsConstants[i]=StringToInteger(FileReadString(fileHandle));
      }
      for(int i=0;i<nbWeights;i++){
         weights[i]=StringToInteger(FileReadString(fileHandle));
      }
      FileClose(fileHandle);
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   //TODO : ecrire dans le fichier les nouvelles constantes et les nouveaux poids
}

void OnTick(){
   static datetime timeStamp;
   datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
   //execution du code à chaque chandelle et non a chaque tick
   if(timeStamp != time){
      timeStamp = time;
      
      //valeurs de la courbe
      static int values = iMA(_Symbol, PERIOD_CURRENT,1,0, MODE_SMA, PRICE_CLOSE);
      double valuesArray[];
      CopyBuffer(values,0,0,layers[0],valuesArray);
      
      //résultats de chaque réseau
      int networksResults[];
      ArrayResize(networksResults,population);
      //indexes dans les listes de constantes et poids
      int nextNeuronIndex=0;
      int nextWeightIndex=0;
      
      
      
      
      
   HistorySelect(0, TimeCurrent());
   int l_deals = HistoryDealsTotal();
   Print("TOTAL DEALS : ",l_deals);
   for (int i = 0; i < l_deals; i++)
   { 
      // Ticket
      ulong l_ticket =  HistoryDealGetTicket(i);
      double profit = HistoryDealGetDouble(l_ticket, DEAL_PROFIT);
      string comment = HistoryDealGetString(l_ticket, DEAL_COMMENT);
      int order = HistoryDealGetInteger(l_ticket, DEAL_ORDER);
      int positionId = HistoryDealGetInteger(l_ticket, DEAL_POSITION_ID);
      Print("PROFIT : ",profit);
      Print("COMMENT : ",comment);
      Print("ORDER : ",order);
      Print("POSITION : ",positionId);
   }
      
      
      
      
      
      /*double scores[];
      ArrayResize(scores,population);
      for(int i=0;i<population;i++){
         scores[i]=0;
      }*/
         //BEINGDOED : retrouver tous les trades de chaque réseau
         
         /*Print("HISTORY OF TRADES");
         int nbPositions=PositionsTotal();
         int nbDeals=HistoryOrdersTotal();
         int networkNo;
         ulong positionTicket;
         ulong dealTicket;
         double dealProfit;
         long positionId;
         Print("NB POSITIONS : ",nbPositions);
         Print("NB ORDERS TOTAL : ", OrdersTotal());
         for(int i=0;i<nbPositions;i++){
            Print("Position ",i);
            positionTicket = PositionGetTicket(i);
            positionId=PositionGetInteger(POSITION_IDENTIFIER);
            Print("Identifier ",positionId);
            networkNo=(int)PositionGetString(POSITION_COMMENT);
            for(int j=0;j<nbDeals;j++){
               Print("Deal ",j);
               dealTicket = HistoryDealGetTicket(i);
               if(HistoryDealGetInteger(dealTicket,DEAL_POSITION_ID) == positionId)
                  {
                     dealProfit=HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
                     Print("Network ",networkNo," MADE A PROFIT OF ",dealProfit);
                     scores[networkNo]+=dealProfit;
                     //deal_commission=HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION)*2;
                     //deal_fee=HistoryDealGetDouble(deal_ticket, DEAL_FEE);
                     break;
                  }
            }
         }*/
         
      
         //TODO : celui qui a fait le meilleur score se voit mettre ses constantes au début de la liste des constantes
         //TODO : celui qui a fait le meilleur score se voit mettre ses poids au début de la liste des poids
      
      
      //pour chaque individu
      for(int p=0;p<population;p++){
         //valeurs des neurones du réseau
         int neuronsValues[];
         ArrayResize(neuronsValues,nbNeurons);
         nextNeuronIndex=0;
         nextWeightIndex=0;
         //si ce n'est pas le premier individu
         if(p>0){
            //initialisation de ses constantes et poids en fonction du premier individu
            for(int i=0;i<nbNeurons;i++){
               double r = MathRand();
               neuronsConstants[i+nbNeurons*p]=neuronsConstants[i]+(int)(MathRound(minAddRandomNeuronConstant + (r/RAND_MAX)*(maxAddRandomNeuronConstant-minAddRandomNeuronConstant)));
            }
            for(int i=0;i<nbWeights;i++){
               double r = MathRand();
               weights[i+nbWeights*p]=weights[i]+(int)(MathRound(minAddRandomWeight + (r/RAND_MAX)*(maxAddRandomWeight-minAddRandomWeight)));
            }
         }
         //parcours du réseau neuronal
         for(int i=0;i<ArraySize(layers);i++){
            for(int j=0;j<layers[i];j++){
               if(i==0){
                  neuronsValues[j]=valuesArray[j]*100000+neuronsConstants[nextNeuronIndex+nbNeurons*p];
                  nextNeuronIndex+=1;
               }
               else{
                  neuronsValues[nextNeuronIndex]=neuronsConstants[nextNeuronIndex+nbNeurons*p];
                  for(int k=0;k<layers[i-1];k++){
                     neuronsValues[nextNeuronIndex]+=(neuronsValues[nextNeuronIndex-j-k-1]*weights[nextWeightIndex+nbWeights*p]);
                     nextWeightIndex+=1;
                  }
                  nextNeuronIndex+=1;
               }
            }
         }
         networksResults[p]=neuronsValues[nextNeuronIndex-1];
      }
      
         //Print("NETWORKS RESULTS");
      for(int i=0;i<population;i++){
         //BEINGDOED : transformer le resultat en 0,1 ou 2
         networksResults[i]=networksResults[i]%3;
         //Print("Network ",i," result : ",networksResults[i]);
         
         //BEINGDOED : faire les achats/ventes correspondants en stockant leurs références dans une liste pour retrouver qui a fait quoi
         if(networksResults[i]==1){
            Print("Network ",i," BUY");
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double stopLoss = ask - 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            double takeProfit = ask + 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            trade.Buy(0.01, _Symbol, ask, 0, 100, i);
         
         }
         else if(networksResults[i]==2){
            Print("Network ",i," SELL");
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double stopLoss = bid + 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            double takeProfit = bid - 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            trade.Sell(0.01, _Symbol, bid, 100, 0, i);
         }
      }
   
   }
}