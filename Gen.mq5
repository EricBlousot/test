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
      
      for(int i=0;i<population;i++){
         Print("Network ",i," result : ",networksResults[i]);
      }
   
   }
}