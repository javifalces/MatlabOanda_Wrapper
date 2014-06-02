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
%api = OandaAPI(token,'sandbox');%Practice
api = OandaAPI(token,'practice',account);%Practice




%%
ListAccounts = api.GetAccount()
%%
ListInstruments = api.GetInstruments()
%% 
Prices = api.GetPrices({'EUR_USD' ,'USD_JPY'});
%% History
Hist = api.GetHistory('EUR_USD');

%%
startdate = datenum('27-May-2014');
Hist = api.GetHistory('USD_JPY' ,'M10', 251,startdate,now, 'midpoint',true  );

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

% PATCH REQUEST
%CHANGE jar in matlab ->   edit classpath.txt
%# Comment these two lines and RESTART Matlab
% #$matlabroot/java/jarext/axis2/commons-httpclient.jar
% #$matlabroot/java/jarext/axis2/httpcore.jar


ret = api.ModifyTrade(Trades{1}.id , 1.35,1.5,10);
%% Close Trade
deletetrade = api.CloseTrade(Trades{1}.id);

%% Get History
HistoryTrades = api.GetTransactionHistory();
%% Get Prices Suscribe Streaming
PricesEurUSD = api.GetPricesSuscribe('EUR_USD');% NOT Working Suscribtion
