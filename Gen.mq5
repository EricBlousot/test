#property copyright "Eric Blousot"
#property link      "https://www.mql5.com"
#property version   "1.00"

#define RAND_MAX 32767

#include <Trade/Trade.mqh>
CTrade trade;

//set the network configuration
const int layers[2] = {2,1};
const int minRandomNeuronConstant = -100;
const int maxRandomNeuronConstant = 100;
const int minRandomWeight = -100;
const int maxRandomWeight = 100;

//global variables
int nbNeurons = 0;
int nbWeights = 0;
int neuronsConstants[];
int weights[];
double neuronsValues[];

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
   ArrayResize(neuronsConstants,nbNeurons);
   ArrayResize(neuronsValues,nbNeurons);
   ArrayResize(weights,nbWeights);
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
}

void OnTick(){
   static datetime timeStamp;
   datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(timeStamp != time){
      timeStamp = time;
      
      //previous values 
      //TODO : iMA not adapted
      static int values = iMA(_Symbol, PERIOD_CURRENT,1,0, MODE_SMA, PRICE_CLOSE);
      double valuesArray[];
      CopyBuffer(values,0,0,layers[0],valuesArray);
      
      //ArraySetAsSeries(valuesArray,true);
      
      
      
      int nextNeuronIndex=0;
      int nextWeightIndex=0;
      //propagation
      for(int i=0;i<ArraySize(layers);i++){
         for(int j=0;j<layers[i];j++){
            if(i==0){
               neuronsValues[j]=valuesArray[j]+neuronsConstants[nextNeuronIndex];
               nextNeuronIndex+=1;
            }
            else{
               neuronsValues[nextNeuronIndex]=neuronsConstants[nextNeuronIndex];
               for(int k=0;k<layers[i-1];k++){
                  neuronsValues[nextNeuronIndex]+=(neuronsValues[nextNeuronIndex-j-k-1]*weights[nextWeightIndex]);
                  nextWeightIndex+=1;
               }
               nextNeuronIndex+=1;
            }
         }
      }
      for(int i=0;i<ArraySize(valuesArray);i++){
         Print("VALUE ",i," : ",valuesArray[i]);
      }
      for(int i=0;i<ArraySize(neuronsValues);i++){
         Print("NEURON ",i," : ",neuronsValues[i]);
      }
      Print("NEXT NEURON INDEX : ",nextNeuronIndex);
      Print("NEXT WEIGHT INDEX : ",nextWeightIndex);
   
   }
}