

classdef OandaAPI
   % Class to interact with OANDA API   - TradEA SYSTEMS
   % (www.tradeasystems.com) 2014  Javier Falces Marin
   %
   % REQUIREMENTS
   % JSONLAB :  http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave
   % URLREAD2: http://www.mathworks.com/matlabcentral/fileexchange/35693-urlread2   
   % thanks to Qianqian Fang(JSONLAB) and Jim Hokanson
 

  
       properties
       % define the properties of the class here, (like fields of a struct)
           account = '';
           token =''%'12345678900987654321-abc34135acde13f13530';
           s_apiServer = 'http://api-sandbox.oanda.com/';%url to OANDA api sandbox
           %username;
           %password;
           connected = false;
           streaming ;
           headers='';
           
           environment = 'sandbox';
            
       end
       
       
       
       
       
       
     %% METHODS  
       
       methods
           
          %% CONSTRUCTOR------------------------------------------------
          function api = OandaAPI(token,environment,account)
              %streaming = oandafunctions.OandaFunctions();
              addpath 'libs'; % Json toolbox and urlread2
              javaaddpath('libs/OandaFunctions.jar');%methodsview oandafunctions.OandaFunctions
              javaaddpath('libs/lib/httpclient-4.3.3.jar');
                 javaaddpath('libs/lib/httpclient-cache-4.3.3.jar');
                 javaaddpath('libs/lib/commons-cli-1.2.jar');
                 javaaddpath('libs/lib/commons-codec-1.6.jar');%methodsview oandafunctions.OandaFunctions
                 javaaddpath('libs/lib/commons-logging-1.1.3.jar');
                 javaaddpath('libs/lib/fluent-hc-4.3.3.jar');
                 javaaddpath('libs/lib/httpcore-4.3.2.jar');
                 javaaddpath('libs/lib/httpcore-ab-4.3.2.jar');
                 javaaddpath('libs/lib/httpcore-nio-4.3.2.jar');
                 javaaddpath('libs/lib/httpmime-4.3.3.jar');
                 javaaddpath('libs/lib/json-simple-1.1.1.jar');
                 javaaddpath('libs/lib/commons-io-2.4.jar');
              api.streaming =  oandafunctions.OandaFunctions();
              if strcmp(class(account),'double')==1
                    account = num2str(account); 
              end 
              
              if(nargin ==3)
                 api.environment = environment;
                 api.token   = token;
                 
                 api.account = account;
                 api.connected = true;
               elseif( nargin ==2)
                 api.environment = environment;
                 api.token   = token;
                 api.account = '0';
                 
               elseif(nargin ==0)
                       api.token   = '';%'12345678900987654321-abc34135acde13f13530';%demo token
                       account='0';
                       print('DEMO');
                       api.environment = 'sandbox';
               elseif(nargin ==1)
                       api.token   = token;    
                       api.environment = 'sandbox';
               else                       
                  disp('Max 3 args:token,environment,account');
               end
               
               
               if strcmp(api.environment ,'sandbox' )
                   disp('Set enviroment to Sandbox');
                   api.s_apiServer = 'http://api-sandbox.oanda.com/';
                   
               elseif strcmp(api.environment ,'practice' )
                    disp('Set enviroment to practice');
                   api.s_apiServer = 'https://api-fxpractice.oanda.com/'; 
                   
                   header0 = http_createHeader('X-HostCommonName','api-fxpractice.oanda.com');
                   header1 = http_createHeader('Host','api-fxpractice.oanda.com');
                   header2 = http_createHeader('X-Target-URI',api.s_apiServer);
                                      
                   header_auth = http_createHeader('Authorization',sprintf('Bearer %s',api.token));
                   
                   api.headers =  [header0;header1;header2;header_auth];
%                    header1 = struct('name','Content-Type','value','application/x-www-form-urlencoded; charset=UTF-8');
%                    header2 = struct('name','Connection','value','Keep-Alive');
%                    header3 = struct('name','Host','value','api-fxpractice.oanda.com');
%                    %api.headers = [header1;api.headers;header2;header3];
%                    api.headers = [header1 api.headers header2 header3];
                
                   
                   
               elseif strcmp(api.environment ,'live' )
                    disp('Set enviroment to live');
                    api.s_apiServer = 'https://api-fxtrade.oanda.com/'; 
                    
                   header0 = http_createHeader('X-HostCommonName','api-fxtrade.oanda.com');
                   header1 = http_createHeader('Host','api-fxtrade.oanda.com');
                   header2 = http_createHeader('X-Target-URI',api.s_apiServer);
                                      
                   header_auth = http_createHeader('Authorization',sprintf('Bearer %s',api.token));
                   
                   api.headers =  [header0;header1;header2;header_auth];
                                     
                   
%                     header1 = struct('name','Content-Type','value','application/x-www-form-urlencoded; charset=UTF-8');
%                    header2 = struct('name','Connection','value','Keep-Alive');
%                    header3 = struct('name','Host','value','api-fxtrade.oanda.com');
%                    api.headers = [header1;api.headers;header2;header3];
               
               else
                    disp('Uknown Environment(sandbox,practice,live) => Sandbox');
               end
               
           end           
          %% ACCOUNTS --------------------------------------------------- 
          %% Create Account, Only valid in SANDBOX
          function accountid  = create_account (api)
            if strcmp(api.environment ,'sandbox' )  
              
                requestString = strcat(api.s_apiServer,'v1/accounts');
                accountid=0;
              
                header = struct('name','Bearer','value',api.token);
%                 header.name1 = 'Content-Type';
%                 header.value1 = 'application/x-www-form-urlencoded; charset=UTF-8';
%                 header.name2 = 'Connection';
%                 header.value2 = 'Keep-Alive';
%                 header.name3 = 'Host';
%                 header.value3 = 'api-sandbox.oanda.com';
                
                
                response = urlread2(requestString,'POST','',header);
                response = loadjson(response);
                
                if response.accountId~=0
                   api.connected = true;
                   api.account = response.accountId;
                   api.username = response.username;
                   api.password = response.password;
                   text = sprintf('Connected to account %i , NAME: %s , PASSWORD: %s \n',api.account, api.username, api.password);
                   disp(text);
                   
                   accountid = api.account;
                    
                else
                   disp('Error Connecting'); 
                end
            else
                disp('ONLY avaible in sandbox Environment');
            end
            
          end
           
          %% Get accounts of a token access
          function ListAccounts = GetAccount(api)
        
               requestString = strcat(api.s_apiServer,'v1/accounts/');
               accountid=0;
               
               
              
              
               
               
               response = api.MakeRequest(requestString);
               if exist('response.accountId','var') && response.accountId~=0
                   accountid = response.accountId;
                   api.connected = true;
               end
               ListAccounts = response.accounts;
               
          end
          
          %% Instruments ----------------------------------------------- 
          %% List of instruments
           function ListInstruments = GetInstruments(api)
               if(~api.connected)
                  disp('must be connected to an account') ;
                  return ;
               end
               
               requestString = strcat(api.s_apiServer , 'v1/instruments?accountId=' , api.account )%http://api-sandbox.oanda.com/v1/accounts/12345/trades
               ListInstruments = api.MakeRequest(requestString).instruments;
               
               
           end
           
           %% List of current prices for a cell of symbols
           function Prices = GetPrices(api,Symbols)
               if(~api.connected)
                  disp('must be connected to an account') ;
                  return ;
               end
               symbolscell = '';
               for i=1:length(Symbols)
                   symbolscell = strcat(symbolscell,Symbols(i),'%2C');
               end
               symbolsString = symbolscell{1}(1:length(symbolscell{1})-3) ;%Delete last separator
               
               
               requestString = strcat(api.s_apiServer , 'v1/prices?instruments=' , symbolsString )%http://api-sandbox.oanda.com/v1/accounts/12345/trades
               Prices = api.MakeRequest(requestString);
               Prices = Prices(1).prices;
               
               
           end
           
           %% Retrieve instrument history
           function History = GetHistory(api, symbol ,granularity, count,startdate,enddate, candleFormat,includeFirst  )
               
               
               if nargin ==2
                   granularity='';
                   count=0;
                   startdate=0;
                   enddate= 0;
                   candleFormat='bidask';
                  
                                      
               end    
                   optdate = '';
                   if strcmp(class(startdate),'char')==1 || strcmp(class(enddate),'char')==1 
                    disp 'startdate and endate must be a double'
                    History = '';
                    return;
                   end
                   optincludeFirst = ''; 
                   if startdate ~= 0 || enddate ~= 0
                       startdate = datestr(startdate,'yyyy-mm-dd');%'yyyy-mm-ddTHH:MM:SS.FFFZ');
                       optdate = strcat(optdate,'&start=',startdate);
                                         
                   
                   %if enddate ~= 0
                       enddate = datestr(enddate,'yyyy-mm-dd');%'yyyy-mm-ddTHH:MM:SS.FFFZ');
                       optdate = strcat(optdate,'&end=',enddate);
                       count = 0;
                       
                       if includeFirst == 1
                       optincludeFirst = strcat('&includeFirst= ','true');
                           else
                              optincludeFirst = ''; 
                           end
                       
                       
                   end
                   
                   if count ~=0
                       count = num2str(count);
                       optcount = strcat('&count=',count);
                   else
                   optcount = '';
                   end
                   
                   if strcmp(granularity,'')==0
                      optgranularity = strcat('&granularity=',granularity);                      
                   else
                       optgranularity = '';
                   end
                   
                   if strcmp(candleFormat,'')==0
                      optcandleFormat = strcat('&candleFormat=',candleFormat);                      
                   else
                       optcandleFormat = '';
                   end

               
              % if strcmp(api.environment,'sandbox')
                   
                requestString = strcat(api.s_apiServer , 'v1/candles?instrument=' , symbol,optgranularity,optcount,optdate,optcandleFormat,optincludeFirst )%http://api-sandbox.oanda.com/v1/accounts/12345/trades
               %else
               % requestString = strcat(api.s_apiServer , 'v1/candles?instrument=' , symbol,optgranularity,granularity,optcount,optdate,optcandleFormat,optincludeFirst )%http://api-sandbox.oanda.com/v1/accounts/12345/trades
               %end
                History = api.MakeRequest(requestString)
               
           end
           %% Order ( not executed) ----------------------------------------------- 
           %% Create new ‘limit’,‘stop’,‘marketIfTouched’ or ‘market’.
           function [orderId,ret] = CreateOrder(api, symbol , volume, side, type,expiry,price,      lowerBound,upperBound,stopLoss,takeProfit,  trailingStop )
            requestString = '';
            if api.connected 
               requestString = strcat(api.s_apiServer , 'v1/accounts/' , api.account,'/orders');
               
               %stringsconversion
               if strcmp(class(volume),'double')==1
                    volume = num2str(volume); 
              end 
               
              
               
               
                  if nargin==4 %market order
                    %Market Order   
                    %https://api-fxpractice.oanda.com/v1/accounts/{account_id}/orders
                    %http://api-sandbox.oanda.com/v1/accounts/12345/trades
                    body = strcat('Content-Type=application%2Fx-www-form-urlencoded&instrument=',symbol,'&units=',volume,'&side=',side,'&type=market');

                  else %limit order
                      opt = '';
                      if strcmp(class(price),'double')==1
                            price = num2str(price); 
                      end 
                      
                      if lowerBound ~=0
                       lowerBoundstr = num2str(lowerBound);
                       opt = strcat(opt,'&lowerBound=',lowerBoundstr);
                                                                   
                      end
                      if upperBound ~=0
                        upperBoundstr = num2str(upperBound);
                       opt = strcat(opt,'&upperBound=',upperBoundstr);
                                                               
                      end
                      if stopLoss ~=0
                        stopLossstr = num2str(stopLoss);
                       opt = strcat(opt,'&stopLoss=',stopLossstr);                                                               
                      end
                      if takeProfit ~=0
                        takeProfitstr = num2str(takeProfit);
                       opt = strcat(opt,'&takeProfit=',takeProfitstr);                                                               
                      end
                       
                      if trailingStop ~=0
                        trailingStopstr = num2str(trailingStop);
                       opt = strcat(opt,'&trailingStop=',trailingStopstr);                                                               
                      end
                      
                      body = strcat('Content-Type=application%2Fx-www-form-urlencoded&instrument=',symbol,'&units=',volume,'&side=',side,'&type=',type,...
                          '&price=',pricestr,opt);


                    end
            
            end
            ret = api.MakePost(requestString,body)
            orderId = ret.tradeOpened.id(1);
           end
           %% Get Order Info
           function [order] = GetOrder(api, orderId)
               requestString = '';
               
              if strcmp(class(orderId),'double')==1
                    orderId = num2str(orderId); 
              end 
                             
            if api.connected 
                requestString = strcat(api.s_apiServer , 'v1/accounts/',api.account,'/orders/',orderId );
                
                order = api.MakeRequest(requestString);
            else
                disp('Must be connected - api.account not chosen');
               order='0';
            end
           end
           %% Cancel Order
           function [order] = CloseOrder(api, orderId)
               requestString = '';
               
              if strcmp(class(orderId),'double')==1
                    orderId = num2str(orderId); 
              end 
                             
            if api.connected 
                requestString = strcat(api.s_apiServer , 'v1/accounts/',api.account,'/orders/',orderId );
                
                order = api.MakeDelete(requestString);
            else
                disp('Must be connected - api.account not chosen');
               order='0';
            end
           end
           %% Modify Order
           function [orderId,ret] = ModifyOrder(api,orderId, symbol , volume, side, type,expiry,price,      lowerBound,upperBound,stopLoss,takeProfit,  trailingStop )
            requestString = '';
            if strcmp(class(orderId),'double')==1
                    orderId = num2str(orderId); 
              end 
            
            if api.connected 
               requestString = strcat(api.s_apiServer , 'v1/accounts/' , api.account,'/orders/',orderId);
               
               %stringsconversion
               volumestr = num2str(volume);
              
                           
                  
                  %limit order
                      opt = '';
                       pricestr = num2str(price);
                      if lowerBound ~=0
                       lowerBoundstr = num2str(lowerBound);
                       opt = strcat(opt,'&lowerBound=',lowerBoundstr);
                                                                   
                      end
                      if upperBound ~=0
                        upperBoundstr = num2str(upperBound);
                       opt = strcat(opt,'&upperBound=',upperBoundstr);
                                                               
                      end
                      if stopLoss ~=0
                        stopLossstr = num2str(stopLoss);
                       opt = strcat(opt,'&stopLoss=',stopLossstr);                                                               
                      end
                      if takeProfit ~=0
                        takeProfitstr = num2str(takeProfit);
                       opt = strcat(opt,'&takeProfit=',takeProfitstr);                                                               
                      end
                       
                      if trailingStop ~=0
                        trailingStopstr = num2str(trailingStop);
                       opt = strcat(opt,'&trailingStop=',trailingStopstr);                                                               
                      end
                      
                      body = strcat('Content-Type=application%2Fx-www-form-urlencoded&instrument=',symbol,'&units=',volumestr,'&side=',side,'&type=',type,...
                          '&price=',pricestr,opt);


                    
            
            end
            ret = api.MakePatch(requestString,body)
            orderId = ret.tradeOpened.id(1);
           end
          
           %% Trades (Executed)----------------------------------------------- 
           %% List of open trades
           function [ListTrades] = GetListTrades(api,symbolorid,count)
               requestString = '';
               opt = ''; 
               if nargin ==1
                  opt = ''; 
               else
                  if strcmp(class(symbolorid),'double')==1
                        symbolorid = num2str(symbolorid); 
                        opt = strcat('ids=',symbolorid);                    
                  else
                      opt = strcat('instrument=',symbolorid); 
                  end
                      
                  if strcmp(class(count),'double')==1
                        count = num2str(count); 
                        opt = strcat(opt,'&count=',count);                    
                  end

               end          
            if api.connected 
                requestString = strcat(api.s_apiServer , 'v1/accounts/',api.account,'/trades?',opt );
                
                ListTrades = api.MakeRequest(requestString);
                ListTrades = ListTrades.trades;
            else
                disp('Must be connected - api.account not chosen');
               ListTrades='0';
            end
           end
           %% Get trade- id
           function [trade] = GetTrade(api, orderId)
               requestString = '';
               
              if strcmp(class(orderId),'double')==1
                    orderId = num2str(orderId); 
              end 
                             
            if api.connected 
                requestString = strcat(api.s_apiServer , 'v1/accounts/',api.account,'/trades/',orderId );
                
                trade = api.MakeRequest(requestString);
            else
                disp('Must be connected - api.account not chosen');
               trade='0';
            end
           end
           %% Modify trade
            function [ret] = ModifyTrade(api,orderId,stopLoss,takeProfit,  trailingStop )
            requestString = '';
            if nargin < 3
                disp 'Must have orderrID and variable min'
                ret = 0;
                return ;
            end
            if nargin == 3
                disp 'TP and trail not modify'
                takeProfit = 0;
                trailingStop = 0;
            end
            if nargin == 4
                disp 'trail not modify'
                trailingStop = 0;
            end
            
            if strcmp(class(orderId),'double')==1
                    orderId = num2str(orderId); 
            end 
            
            if api.connected 
               requestString = strcat(api.s_apiServer , 'v1/accounts/' , api.account,'/trades/',orderId);
                  %limit order
                      opt = '';
                       
                      
                      if stopLoss ~=0
                        stopLossstr = num2str(stopLoss);
                       opt = strcat(opt,'stopLoss=',stopLossstr,'&');                                                               
                      end
                      if nargin>3
                          if takeProfit ~=0
                            takeProfitstr = num2str(takeProfit);
                           opt = strcat(opt,'takeProfit=',takeProfitstr,'&');                                                               
                          end
                           if nargin>4
                                  if trailingStop ~=0
                                    trailingStopstr = num2str(trailingStop);
                                   opt = strcat(opt,'trailingStop=',trailingStopstr,'&');                                                               
                                  end
                           end
                      end
                      opt = opt(1:length(opt)-1) ;%Delete last separator
                      


                    
            
            end
            ret = api.MakePatch(requestString,opt)
            
           end
           %% Close Trade
           function [order] = CloseTrade(api, orderId)
               requestString = '';
               
              if strcmp(class(orderId),'double')==1
                    orderId = num2str(orderId); 
              end 
                             
            if api.connected 
                requestString = strcat(api.s_apiServer , 'v1/accounts/',api.account,'/trades/',orderId );
                
                order = api.MakeDelete(requestString);
                
                
            else
                disp('Must be connected - api.account not chosen');
               order='0';
            end
           end
           %% Positions ----------------------------------------------- 
           %% List of Positions
           function [ListPositions] = GetListPositions(api,symbol)
               requestString = '';
              if nargin ==1
                 opt = ''; 
              else
                  opt = symbol;
              end
            if api.connected 
                requestString = strcat(api.s_apiServer , 'v1/accounts/',api.account,'/positions/',opt );
                
                ListPositions = api.MakeRequest(requestString);
                ListPositions = Listpositions.positions;
            else
                disp('Must be connected - api.account not chosen');
               ListPositions='0';
            end
           end
           %% Close Positions
           function [order] = ClosePosition(api, symbol)
               requestString = '';
                                           
            if api.connected 
                requestString = strcat(api.s_apiServer , 'v1/accounts/',api.account,'/positions/',symbol );
                
                order = api.MakeDelete(requestString);
                
                
            else
                disp('Must be connected - api.account not chosen');
               order='0';
            end
           end
           %% Transaction History ---------------------------------------
           %% Get Transaction history
           function history = GetTransactionHistory(api, maxId , minId , count , symbol,orderId  )
      if api.connected   
           requestString = '';
           opt = '';
           if nargin >1   
               opt = '?';
                   if maxId ~=0
                       if strcmp(class(maxId),'double')==1
                            maxId = num2str(maxId); 
                       end
                       option = strcat(opt,'maxid=',maxId,'&');
                    end
                   
                   if minId ~=0
                    if strcmp(class(minId),'double')==1
                        minId = num2str(minId); 
                    end 
                     opt = strcat(opt,'minid=',minId,'&');
                   end
                   
                   if count ~=0
                    if strcmp(class(count),'double')==1
                        count = num2str(count); 
                    end 
                     opt = strcat(opt,'count=',count,'&');
                   end
                   
                   if strcmp(symbol, '')==0
                       opt = strcat(opt,'instrument=',symbol,'&');
                   end
                   
                   if orderId ~=0
                    if strcmp(class(orderId),'double')==1
                        orderId = num2str(orderId); 
                    end 
                     opt = strcat(opt,'ids=',orderId,'&');
                   end
                   
                   
          end
           requestString = strcat(api.s_apiServer , 'v1/accounts/',api.account,'/transactions',opt );
           history = api.MakeRequest(requestString).transactions;
           
      else
          disp('Must be connected - api.account not chosen');
          history='0';
      end
      
           
           
           end
           
            %% Streaming Prices ---------------------------------------
             
          function prices = GetPricesSuscribe(api, Symbols)
                requestString = '';
                
                symbolscell = '';
             if iscell(Symbols)
               for i=1:length(Symbols)
                   symbolscell = strcat(symbolscell,Symbols(i),'%2C');
               end
               symbolsString = symbolscell{1}(1:length(symbolscell{1})-3) ;%Delete last separator
               
             else
                 symbolsString = Symbols;
             end
                
                                           
            if api.connected 
                requestString = strcat(api.s_apiServer , 'v1/prices?accountId=',api.account,'&instruments=',symbolsString );
                               
                prices = '';
                api.streaming.streamingSuscribe(requestString, api.token)  ;
                
                %%prices = api.MakeRequest(requestString);
                %%prices = prices.prices;
                
                
                
                %prices = loadjson(prices.prices);
                %prices = prices.prices;
                
                
            else
                disp('Must be connected - api.account not chosen');
               prices='0';
            end
           
                
                
           end
            
           
%% REQUEST , POST    , DELETE       
           function [ response ] = MakeRequest(api,requestString )
                
               resp = urlread2(requestString,'GET','',api.headers);
               response = loadjson(resp);


           end
            
            function [ response ] = MakePost(api,requestString, body )
                
               resp = urlread2(requestString,'POST',body,api.headers);
               response = loadjson(resp);


            end
            function [ response ] = MakeDelete(api,requestString )
                
               resp = urlread2(requestString,'DELETE','',api.headers);
               response = loadjson(resp);


            end
            function [ response ] = MakePatch(api,requestString ,body)
               disp('PATH ethod not implemnted') ;
              % headerPatch = [http_createHeader('X-HTTP-Method-Override',''); api.headers ];
               resp= char(oandafunctions.OandaFunctions.PatchRequest(requestString,api.token,body) );
               %resp = urlread2(strcat(requestString,'?_HttpMethod=PATCH'),'POST',body,api.headers);
               
               response = loadjson(resp);


            end



           
           
       end
       
       
       
       
       
       
    
       
       
       
end
       % methods, including the constructor are defined in this block