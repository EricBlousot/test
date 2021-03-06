#property copyright "Eric Blousot"
#property link      "https://www.mql5.com"
#property version   "1.00"

#define RAND_MAX 32767

#include <Trade/Trade.mqh>
CTrade trade;

//set the network configuration
const int layers[5] = {50,20,20,20,1};
const int minRandomNeuronConstant = -50;
const int maxRandomNeuronConstant = 50;
const int minAddRandomNeuronConstant = -5;
const int maxAddRandomNeuronConstant = 5;
const int minRandomWeight = -50;
const int maxRandomWeight = 50;
const int minAddRandomWeight = -5;
const int maxAddRandomWeight = 5;
const int population = 30;//min 3
const int scorePeriod = 100;
const double mutationProportion = 0.05;
const int nbNewRandomNetworks=10;//max population-2

//global variables
int nbNeurons = 0;
int nbWeights = 0;
int neuronsConstants[];
int weights[];
double previousScores[];
string baseFileName="TradeNeurons";



int FindInArray(int &Array[],int Value){
   int size=ArraySize(Array);
      for(int i=0; i<size; i++){
         if(Array[i]==Value){
            return(i);
         }
      }
   return(-1);
}

int OnInit(){
   Print("Initialisation of Genetic Algorithm");
   //generate filename according to network configuration
   string filename=baseFileName;
   int fileHandle=0;
   for(int i=0;i<ArraySize(layers);i++){
      filename+=("_"+IntegerToString(layers[i]));
   }
   filename+=".txt";
   
   //file recovering/creation
   bool existingFile=false;
   if(!FileIsExist(filename,FILE_COMMON)){
      Print("File ",filename," does not exist, creation needed");
      fileHandle=FileOpen(filename,FILE_WRITE|FILE_TXT|FILE_COMMON);
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
      fileHandle=FileOpen(filename,FILE_WRITE|FILE_TXT|FILE_COMMON);
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
      
      for(int i=1;i<population;i++){
         for(int j=0;j<nbNeurons;j++){
            double r = MathRand();
            neuronsConstants[j+i*nbNeurons]=(int)(MathRound(minRandomNeuronConstant + (r/RAND_MAX)*(maxRandomNeuronConstant-minRandomNeuronConstant)));
         }
      }
      for(int i=1;i<population;i++){
         for(int j=0;j<nbWeights;j++){
            double r = MathRand();
            weights[j+i*nbWeights]=(int)(MathRound(minRandomWeight + (r/RAND_MAX)*(maxRandomWeight-minRandomWeight)));
         }
      }
      FileClose(fileHandle);
   }
   else{
      fileHandle=FileOpen(filename,FILE_READ|FILE_TXT|FILE_COMMON);
      for(int i=0;i<nbNeurons;i++){
         neuronsConstants[i]=StringToInteger(FileReadString(fileHandle));
      }
      for(int i=0;i<nbWeights;i++){
         weights[i]=StringToInteger(FileReadString(fileHandle));
      }
      for(int i=1;i<population-nbNewRandomNetworks;i++){
         for(int j=0;j<nbNeurons;j++){
            double r = MathRand();
            neuronsConstants[j+i*nbNeurons]=neuronsConstants[j]+(int)(MathRound(minAddRandomNeuronConstant + (r/RAND_MAX)*(maxAddRandomNeuronConstant-minAddRandomNeuronConstant)));
         }
      }
      for(int i=1;i<population-nbNewRandomNetworks;i++){
         for(int j=0;j<nbWeights;j++){
            double r = MathRand();
            weights[j+i*nbWeights]=weights[j]+(int)(MathRound(minAddRandomWeight + (r/RAND_MAX)*(maxAddRandomWeight-minAddRandomWeight)));
         }
      }
      for(int i=population-nbNewRandomNetworks;i<population;i++){
         for(int j=0;j<nbNeurons;j++){
               double r = MathRand();
               neuronsConstants[j+i*nbNeurons]=(int)(MathRound(minRandomNeuronConstant + (r/RAND_MAX)*(maxRandomNeuronConstant-minRandomNeuronConstant)));
         }
      }
      for(int i=population-nbNewRandomNetworks;i<population;i++){
         for(int j=0;j<nbWeights;j++){
               double r = MathRand();
               weights[j+i*nbWeights]=(int)(MathRound(minRandomWeight + (r/RAND_MAX)*(maxRandomWeight-minRandomWeight)));
         }
      }
      FileClose(fileHandle);
   }
   ArrayResize(previousScores,population);
   for(int i=0;i<population;i++){
      previousScores[i]=0;
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   //TODO : ecrire dans le fichier les nouvelles constantes et les nouveaux poids
}

void OnTick(){
   //////////////////////////////////////////////////////////////////////////////////////////////INITIALISATION OF TOTALSCORES
   /*static int[] totalScores;
   static bool firstTime=true;
   if(firstTime){
      firstTime=false;
      ArrayResize(totalScores,population);
      for(int i=0;i<population;i++){
         totalScores[i]=0;
      }
   }*/
   //////////////////////////////////////////////////////////////////////////////////////////////end INITIALISATION OF TOTALSCORES
   
   
   //////////////////////////////////////////////////////////////////////////////////////////////TIME HANDLE
   static int currentPeriod=0;
   static datetime timeStamp;
   datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(timeStamp != time){
      timeStamp = time;
      currentPeriod+=1;
   //////////////////////////////////////////////////////////////////////////////////////////////end TIME HANDLE
      
      //////////////////////////////////////////////////////////////////////////////////////////////CALCULATIONS BY NETWORKS
      Print("Calculation by neurons");
      static int values = iMA(_Symbol, PERIOD_CURRENT,1,0, MODE_SMA, PRICE_CLOSE);
      double valuesArray[];
      CopyBuffer(values,0,0,layers[0],valuesArray);
      int networksResults[];
      ArrayResize(networksResults,population);
      int nextNeuronIndex=0;
      int nextWeightIndex=0;
      for(int p=0;p<population;p++){
         int neuronsValues[];
         ArrayResize(neuronsValues,nbNeurons);
         nextNeuronIndex=0;
         nextWeightIndex=0;
         if(p>0){
            for(int i=0;i<nbNeurons;i++){
               double r = MathRand();
               neuronsConstants[i+nbNeurons*p]=neuronsConstants[i]+(int)(MathRound(minAddRandomNeuronConstant + (r/RAND_MAX)*(maxAddRandomNeuronConstant-minAddRandomNeuronConstant)));
            }
            for(int i=0;i<nbWeights;i++){
               double r = MathRand();
               weights[i+nbWeights*p]=weights[i]+(int)(MathRound(minAddRandomWeight + (r/RAND_MAX)*(maxAddRandomWeight-minAddRandomWeight)));
            }
         }
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
      /////////////////////////////////////////////////////////////////////////////////////////////end CALCULATIONS BY NETWORKS
      
      ///////////////////////////////////////////////////////////////////////NETWORKS TRADING
      const string tradeCommentIdentifier="NetworkTrade_";
      for(int i=0;i<population;i++){
         Print("Result of network ",i," : ",networksResults[i],"(",MathAbs(networksResults[i]%3),")");
         networksResults[i]=MathAbs(networksResults[i]%3);
         if(networksResults[i]==1){
            Print("Network ",i," BUY");
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double stopLoss = ask - 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            double takeProfit = ask + 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            trade.Buy(0.01, _Symbol, ask, stopLoss, takeProfit, tradeCommentIdentifier+i);
         
         }
         else if(networksResults[i]==2){
            Print("Network ",i," SELL");
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double stopLoss = bid + 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            double takeProfit = bid - 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            trade.Sell(0.01, _Symbol, bid, stopLoss, takeProfit, tradeCommentIdentifier+i);
         }
      }
      ///////////////////////////////////////////////////////////////////////end NETWORKS TRADING
      
      if(currentPeriod%scorePeriod==0){
         Print("PERIOD OK");
         ////////////////////////////////////////////////////////////////CALCULATE SCORES
         Print("Calculate scores");
         HistorySelect(0, TimeCurrent());
         int l_deals = HistoryDealsTotal();
         int memoPositions[];
         double memoProfits[];
         string memoComments[];
         ArrayResize(memoPositions,l_deals);
         ArrayResize(memoProfits,l_deals);
         ArrayResize(memoComments,l_deals);
         double scores[];
         ArrayResize(scores,population);
         for(int i=0;i<population;i++){
            scores[i]=0;
         }
         for (int i = 1; i < l_deals; i++)
         { 
            ulong l_ticket =  HistoryDealGetTicket(i);
            double profit = HistoryDealGetDouble(l_ticket, DEAL_PROFIT);
            string comment = HistoryDealGetString(l_ticket, DEAL_COMMENT);
            //int order = HistoryDealGetInteger(l_ticket, DEAL_ORDER);
            int positionId = HistoryDealGetInteger(l_ticket, DEAL_POSITION_ID);
            //Print("PROFIT : ",profit," -- COMMENT : ",comment," -- POSITION : ",positionId);
            memoProfits[i]=profit;
            memoComments[i]=comment;
            int networkId=0;
            int correspondingOrderIndex = FindInArray(memoPositions,positionId);
            if(correspondingOrderIndex>=0){
               if(StringFind(memoComments[correspondingOrderIndex],tradeCommentIdentifier)>=0){
                  networkId=(int)StringSubstr(memoComments[correspondingOrderIndex],StringLen(tradeCommentIdentifier));
               }
               else if(StringFind(memoComments[i],tradeCommentIdentifier)>=0){
                  networkId=(int)StringSubstr(memoComments[i],StringLen(tradeCommentIdentifier));
               }
               //Print("NETWORK "+networkId," MADE A PROFIT OF ",(memoProfits[correspondingOrderIndex]+memoProfits[i]));
               scores[networkId]+=(memoProfits[correspondingOrderIndex]+memoProfits[i]);
            }
            memoPositions[i]=positionId;
         }
         ////////////////////////////////////////////////////////////////end CALCULATE SCORES
         ////////////////////////////////////////////////////////////////MUTATIONS
         int bestNetworkId=0;
         bool bestChanged=false;
         Print("Score 0 : ", scores[0]-previousScores[0]);
         for(int i=1;i<population;i++){
            Print("Score ",i," : ", scores[i]-previousScores[i]);
            if((scores[i]-previousScores[i])>(scores[bestNetworkId]-previousScores[bestNetworkId])){
               bestNetworkId=i;
               bestChanged=true;
            }
         }
         Comment("                                                           LAST BEST SCORE : ",scores[bestNetworkId]-previousScores[bestNetworkId]);
         for(int i=0;i<population;i++){
            previousScores[i]=scores[i];
         }
         
         Print("Best : ", bestNetworkId);
         if(bestChanged){
            Print("Best changed : change the first network");
            //network 1 (best)
            for(int i=0;i<nbNeurons;i++){
               neuronsConstants[i]=neuronsConstants[i+nbNeurons*bestNetworkId];
            }
            for(int i=0;i<nbWeights;i++){
               weights[i]=weights[i+nbWeights*bestNetworkId];
            }
         }
         Print("other mutations");
         //network 1 to n-1 (mutations of the best)
         for(int i=1;i<population-nbNewRandomNetworks;i++){
            for(int j=0;j<nbNeurons;j++){
               double p = MathRand();
               if(p/RAND_MAX <= mutationProportion){
                  double r = MathRand();
                  neuronsConstants[j+i*nbNeurons]=neuronsConstants[j]+(int)(MathRound(minAddRandomNeuronConstant + (r/RAND_MAX)*(maxAddRandomNeuronConstant-minAddRandomNeuronConstant)));
               }
            }
         }
         for(int i=1;i<population-nbNewRandomNetworks;i++){
            for(int j=0;j<nbWeights;j++){
               double p = MathRand();
               if(p/RAND_MAX <= mutationProportion){
                  double r = MathRand();
                  weights[j+i*nbWeights]=weights[j]+(int)(MathRound(minAddRandomWeight + (r/RAND_MAX)*(maxAddRandomWeight-minAddRandomWeight)));
               }
            }
         }
         //network n (total random)
         for(int i=population-nbNewRandomNetworks;i<population;i++){
            for(int j=0;j<nbNeurons;j++){
                  double r = MathRand();
                  neuronsConstants[j+i*nbNeurons]=(int)(MathRound(minRandomNeuronConstant + (r/RAND_MAX)*(maxRandomNeuronConstant-minRandomNeuronConstant)));
            }
         }
         for(int i=population-nbNewRandomNetworks;i<population;i++){
            for(int j=0;j<nbWeights;j++){
                  double r = MathRand();
                  weights[j+i*nbWeights]=(int)(MathRound(minRandomWeight + (r/RAND_MAX)*(maxRandomWeight-minRandomWeight)));
            }
         }
         ////////////////////////////////////////////////////////////////end MUTATIONS
         ////////////////////////////////////////////////////////////////SAVE BEST NETWORK
         Print("SAVE THE BEST");
         string filename=baseFileName;
         int fileHandle=0;
         for(int i=0;i<ArraySize(layers);i++){
            filename+=("_"+IntegerToString(layers[i]));
         }
         filename+=".txt";
         fileHandle=FileOpen(filename,FILE_WRITE|FILE_TXT|FILE_COMMON);
         for(int i=0;i<nbNeurons;i++){
            FileWrite(fileHandle, neuronsConstants[i]);
         }
         for(int i=0;i<nbWeights;i++){
            FileWrite(fileHandle, weights[i]);
         }
         FileClose(fileHandle);
         ////////////////////////////////////////////////////////////////end SAVE BEST NETWORK
      }
   }
}