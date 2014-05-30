%% First download Json toolbox
%http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave
%addpath 'C:\Program Files\MATLAB\R2014a\toolbox\json';

%https://github.com/oanda/CSharpLibAPISample/blob/master/RestAPI/Rest.cs

clear;
clc;
addpath 'libs'; % Json toolbox and urlread2
token = 'your token for oanda';%my personal token
account = 'account number';
%% LOGN API

api = OandaAPI(token,'practice',account);


%%
ListAccounts = api.GetAccount()
%%
ListInstruments = api.GetInstruments()
%% 
Prices = api.GetPrices({'EUR_USD' ,'USD_JPY'});
%% History
Hist = api.GetHistory('EUR_USD');

%% Create Order - start trading
[id,order1] = api.CreateOrder('EUR_USD' , 5, 'buy');%buy mkt order

%% Get Order
order = api.GetOrder(id);
%% Close Order
close = api.CloseOrder(id);
%% Modify Order
modif= api.ModifyOrder();
%%
ListAccounts = api.GetAccount()
%%
ListInstruments = api.GetInstruments()
%% 
Prices = api.GetPrices({'EUR_USD' ,'USD_JPY'});
%% History
Hist = api.GetHistory('EUR_USD');

%% Create Order - start trading
[id,order1] = api.CreateOrder('EUR_USD' , 5, 'buy');%buy mkt order

%% Get Order(not executed)
order = api.GetOrder(id);
%% Close Order(not executed)
close = api.CloseOrder(id);
%% Modify Order(not executed)
modif= api.ModifyOrder();

%% Get List trades
Trades = api.GetListTrades();
%% Get trade
trade1 = api.GetTrade(Trades{1}.id);

%% Modify Trade
ret = api.ModifyTrade(Trades{1}.id , 123)
%% Close Trade
deletetrade = api.CloseTrade(Trades{1}.id);

%% Get History
HistoryTrades = api.GetTransactionHistory();
%% Get Prices Suscribe Streaming  - NOTWORKING
PricesEurUSD = api.GetPricesSuscribe('EUR_USD');

