//+------------------------------------------------------------------+
//|                                                          B30.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
int total;
int count_buy_s,
      count_buy,
      total_buy_s,
      total_buy,
      count_sell_s,
      count_sell,
      total_sell_s,
      total_sell,
      buy_ticket_n,
      sell_ticket_n;
double   M17,
         M72,
         B1Open,
         B1Close,
         B2Open,
         B2Close;
double   buy_open,
         sell_open,
         buy_stop,
         sell_stop,
         buy_bar_op,
         sell_bar_op,
         lot_size;
extern double  risk = 2, //Risk size in %, 
               last_lot_size = 0.01, //Last Lot Size
               manual_lot_size = 0, //Manual Position sizing 
               stop_loss = 301; //Stop Loss 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//---
count_buy_s = 0;
count_buy = 0;
total_buy_s = 0;
total_buy = 0;

count_sell_s = 0;
count_sell = 0;
total_sell_s = 0;
total_sell = 0;

   total = OrdersTotal();
   
   for(int i=0;i<total;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
         {
            switch(OrderType())
            {
               case  OP_BUY:
                  buy_open = OrderOpenPrice(); 
                  buy_ticket_n = OrderTicket();
               break;
               case  OP_SELL:
                  //count_sell = 1;
                  sell_open = OrderOpenPrice(); 
                  sell_ticket_n = OrderTicket();
               break;
            default:
              break;
           }
         }         
        }
     } 

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   total = OrdersTotal();
   
   for(int i=0;i<total;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
         {
            switch(OrderType())
            {
               case  OP_BUYSTOP:
                  count_buy_s = 1;
               break;
               case  OP_SELLSTOP:
                  count_sell_s = 1;
                  break;
               case  OP_BUY:
                  count_buy = 1;
               break;
               case  OP_SELL:
                  count_sell = 1;
               break;
            default:
              break;
           }
         }         
        }
     } 
   
   VerifyBuy(); 
   VerifySell();
   VerifyBuyStop();
   VerifySellStop();  
  
  }
//+------------------------------------------------------------------+

void VerifyBuyStop(){
   //Print(total_buy);
   if((count_buy_s > 0))
     {
      total_buy_s = 1;
      count_buy_s = 0;
     }
   else
     {
      total_buy_s = 0;
      count_buy_s = 0;
     }
     
   switch(total_buy_s)
     {
      case  0:
         MediamOut();
         BarOut();
         if((B1Open>B1Close) &&((B1Open+103*Point)>=M17)  && (total_buy == 0))
           {
            buy_open = B1Open+101*Point;
            buy_stop = B1Open-(stop_loss-100)*Point;
            SetOrderBuy();
           } 
        break;
      case  1:
         if((B1Open > B1Close) && (B1Open != buy_bar_op))
           {
            if(OrderDelete(buy_ticket_n,clrRed))
              {
               total_buy_s = 0;
              } 
           } 
        break;
      default:
        break;
     }
}
void VerifySellStop(){
    if((count_sell_s > 0))
     {
      total_sell_s = 1;
      count_sell_s = 0;
     }
   else
     {
      total_sell_s = 0;
      count_sell_s = 0;
     }
   switch(total_sell_s)
     {
      case  0:
         MediamOut();
         BarOut();
         if((B1Open<B1Close) && ((B1Open-103*Point)<=M17) && (total_sell == 0))
           {
            sell_open = B1Open-101*Point;
            sell_stop = B1Open+(stop_loss-100)*Point;
            SetOrderSell();
           } 
        break;
      case  1:
         if((B1Open < B1Close) && (B1Open != sell_bar_op))
           {
            if(OrderDelete(sell_ticket_n,clrRed))
              {
               total_sell_s = 0;
              } 
           } 
        break;
      default:
        break;
     }
}
void VerifyBuy(){
   if(count_buy > 0)
     {
      total_buy = 1;
      count_buy = 0;
     }
   else
     {
      total_buy = 0;
      count_buy = 0;
     }
   switch(total_buy)
     {
      case  1: 
         BarOut();
         if((B1Open < B1Close) && (B1Close >= (buy_open+99*Point)))
            {
              if(OrderSelect(buy_ticket_n,SELECT_BY_TICKET,MODE_TRADES))
                {
                  if((OrderStopLoss() != B1Open-100*Point))
                    {
                     OrderModify(buy_ticket_n,OrderOpenPrice(),B1Open-100*Point,OrderTakeProfit(),0,clrAliceBlue);   
                    }
                }
            }         
         break;
      default:
        break;
     }
}
void VerifySell(){
    if(count_sell > 0)
     {
      total_sell = 1;
      count_sell = 0;
     }
   else
     {
      total_sell = 0;
      count_sell = 0;
     }
  switch(total_sell)
     {
      case  1:
         BarOut();
        //Print(sell_open-200*Point);
         if((B1Open > B1Close) && (B1Close <= (sell_open-99*Point)))
            {
              if(OrderSelect(sell_ticket_n,SELECT_BY_TICKET,MODE_TRADES))
                {
                  if((OrderStopLoss() != B1Open+100*Point))
                    {
                     OrderModify(sell_ticket_n ,OrderOpenPrice(),B1Open+100*Point,OrderTakeProfit(),0,clrAliceBlue); 
                    }
                }
            }         
         break;
      default:
        break;
     }
}
void  MediamOut(){
   M17 = iMA(Symbol(),NULL,17,0,MODE_EMA,PRICE_CLOSE,2);
   M72 = iMA(Symbol(),NULL,72,0,MODE_EMA,PRICE_CLOSE,2);
}
void  BarOut(){
   B1Open=iOpen(Symbol(),NULL,1);
   B1Close= iClose(Symbol(),NULL,1);
   B2Open = iOpen(Symbol(),NULL,2);
   B2Close= iClose(Symbol(),NULL,2);
}
void SetOrderBuy(){
   buy_bar_op = B1Open;
   PositionSize();
   buy_ticket_n = OrderSend(Symbol(),OP_BUYSTOP,lot_size,buy_open,5,buy_stop,0,NULL,100,0,clrAliceBlue);
   if(buy_ticket_n > 0)
     {
      total_buy = 1;
     }
    
}
void SetOrderSell(){
   sell_bar_op = B1Open;
   PositionSize();
   sell_ticket_n = OrderSend(Symbol(),OP_SELLSTOP,lot_size,sell_open,5,sell_stop,0,NULL,101,0,clrAliceBlue);
   if(sell_ticket_n > 0)
     {
      total_sell = 1;
     }
}

void PositionSize(){
if(manual_lot_size == 0)
  {
   double   acc_balance = AccountBalance();

   lot_size = NormalizeDouble((((acc_balance*(risk/100))/20)/10),2);
   if(lot_size < last_lot_size)
     {
      lot_size = last_lot_size;
     }
   else
     {
      last_lot_size = lot_size;
     }   
  }
else
  {
   lot_size = manual_lot_size;
  }

}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }