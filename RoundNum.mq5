//**************************************************
//*  RoundNum.mq4                                  *
//*                                                *
//*  Draws horizontal lines at round price levels  *
//*                                                *
//*  Written by: ttss000                           *
//   https://twitter.com/ttss000
//**************************************************
// 2022/1/2
#property version   "1.1"
#property indicator_chart_window

//#define MAX_LINES 1024
#define MAX_LINES_IN_A_WIN 50

//extern double LineSpace     = 1; // 1 unit = 0.01 of basic value (e.g. 1 USD cent)
input color  LineColor     = clrDeepSkyBlue;
input string LineStyleInfo = "0=Solid,1=Dash,2=Dot,3=DashDot,4=DashDotDot";
extern int    LineStyle     = 2;
extern string LineText      = "RoundNum";
input string memo="If RoundPoint is too small, ignored.";
input int RoundPoint=1000;
input int hideNumY=10;

double LineSpaceOld;
double Hoch;
double Tief;
bool   FirstRun = true;
int total_line_count=0;
//int line_array[MAX_LINES];
int int_chart_price_max_prev = 0;
int int_chart_price_min_prev = 0;

//-----------------------------------------------------------------------------------
int OnInit()
{
  //ChartSetInteger(0,CHART_SHOW_PRICE_SCALE,0,true);
  EventSetTimer(5);
  return(0);
}
//-----------------------------------------------------------------------------------
int deinit()
{
  int obj_total= ObjectsTotal(0,0,-1); //ObjectsTotal();
  //int Get_Arrow_Code;

  //Print ("Object_total = " + obj_total);

  for (int k= obj_total; k>=0; k--){
    string name= ObjectName(0,k, 0, -1); //ObjectName(k);
    //Print ("Object_name 000 = " + name + " type" + ObjectType(name));
    //if(0<=StringFind(StringSubstr(name,0,4),"PIPS")){
    //   Print ("Object_name 001 = " + name);
    //}
    //Get_Arrow_Code = ObjectGetInteger(0,name,OBJPROP_ARROWCODE, 0);
    // ObjectGetInteger (0, name, OBJPROP_TYPE)
    //if(OBJ_HLINE == ObjectType(name) && 0<=StringFind(StringSubstr(name,0,StringLen(LineText)),LineText)){
    if(OBJ_HLINE == ObjectGetInteger (0, name, OBJPROP_TYPE) && 0<=StringFind(StringSubstr(name,0,StringLen(LineText)),LineText)){
      //Print ("Obj = " + name + " ObjType:"+ObjectType(name));
      ObjectDelete(0,name);
    }
  }
  EventKillTimer();

  return(0);
}
//-----------------------------------------------------------------------------------
//int start()
//{
   //EventSetTimer(5);

//   DrawLines();
//   return(0);
//}
//-----------------------------------------------------------------------------------
void DrawLines()
{

  int Y_roundnum, Y_Ask, Y_Bid;
  int pixel_x;
  //,pixel_y;

  double chart_price_max=ChartGetDouble(0,CHART_PRICE_MAX,0);
  double chart_price_min=ChartGetDouble(0,CHART_PRICE_MIN,0);

  int int_chart_price_max = MathRound(chart_price_max/Point()/RoundPoint);
  int int_chart_price_min = MathRound(chart_price_min/Point()/RoundPoint);
  double hline_price;

  if(int_chart_price_max - int_chart_price_min < MAX_LINES_IN_A_WIN){
    if(int_chart_price_max_prev != int_chart_price_max || int_chart_price_min_prev != int_chart_price_min_prev){
      for(double i=int_chart_price_min; i<=int_chart_price_max; i++){
        hline_price = i*Point()*RoundPoint;
        string StringNr = IntegerToString(i); // 2 digits number in object name
        //ObjectFind(0, indiName+"_RunButton")
        if (ObjectFind(0,LineText+StringNr) != 0) // HLine not in main chartwindow
        {
        //   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
                     
          ObjectCreate(0,LineText+StringNr, OBJ_HLINE, 0, 0, hline_price);
          //line_array[total_line_count] = i;
          //total_line_count++;
        }else{    // Adjustments
          //ObjectSet(LineText+StringNr, OBJPROP_PRICE1, hline_price);
          ObjectMove(0,LineText+StringNr, 0,0, hline_price);
        }
        int iWindowFirstVisibleBar = ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0);
        int iTimeFirstVisible = iTime(NULL,0,iWindowFirstVisibleBar);
        double Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID); 
        double Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK); 

        ChartTimePriceToXY(0,0,iTimeFirstVisible,hline_price,pixel_x,Y_roundnum);
        ChartTimePriceToXY(0,0,iTimeFirstVisible,Ask,pixel_x,Y_Ask);
        ChartTimePriceToXY(0,0,iTimeFirstVisible,Bid,pixel_x,Y_Bid);

        if(MathAbs(Y_roundnum - Y_Ask) < hideNumY || MathAbs(Y_roundnum - Y_Bid) < hideNumY){
          ObjectSetInteger(0,LineText+StringNr, OBJPROP_BACK, false);
        }else{
          ObjectSetInteger(0,LineText+StringNr, OBJPROP_BACK, false);
        }
        //ObjectSet(LineText+StringNr, OBJPROP_STYLE, LineStyle);
        //ObjectSet(LineText+StringNr, OBJPROP_COLOR, LineColor);
        ObjectSetInteger(0,LineText+StringNr, OBJPROP_STYLE, LineStyle);
        ObjectSetInteger(0,LineText+StringNr, OBJPROP_COLOR, LineColor);
        ObjectSetInteger(0,LineText+StringNr, OBJPROP_BGCOLOR, LineColor);
        ObjectSetInteger(0,LineText+StringNr, OBJPROP_BORDER_COLOR, LineColor);
        ObjectSetInteger(0,LineText+StringNr, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0,LineText+StringNr, OBJPROP_SELECTED, false);
        ObjectSetInteger(0,LineText+StringNr, OBJPROP_RAY, false);
        ObjectSetInteger(0,LineText+StringNr, OBJPROP_FILL,true);
        ObjectSetString(0,LineText+StringNr, OBJPROP_TEXT, hline_price); 
        ObjectSetString(0,LineText+StringNr, OBJPROP_TOOLTIP, hline_price); 
        
      }
      //ChartRedraw();
    }
  }
}
//-----------------------------------------------------------------------------------

//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---
  if(id == CHARTEVENT_CHART_CHANGE || id == CHARTEVENT_CLICK){
    DrawLines();
  }
}
//+------------------------------------------------------------------+
void OnTimer()
{
  DrawLines();
}
//+------------------------------------------------------------------+

//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
  //DrawLines();
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
