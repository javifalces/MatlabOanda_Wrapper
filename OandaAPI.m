

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
           
           headers='';
           
           environment = 'sandbox';
            
       end
       
       
       
       
       
       
     %% METHODS  
       
       methods
           
          %% CONSTRUCTOR------------------------------------------------
          function api = OandaAPI(token,environment,account)
               if(nargin ==3)
                 api.environment = environment;
                 api.token   = token;
                 api.account = account;
                 api.connected = true;
               elseif( nargin ==2)
                 api.environment = environment;
                 api.token   = token;
                 api.account = 0;
                 
               elseif(nargin ==0)
                       api.token   = '';%'12345678900987654321-abc34135acde13f13530';%demo token
                       account=0;
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
                   api.headers =  struct('name','Authorization','value',sprintf('Bearer %s',api.token));
%                    header1 = struct('name','Content-Type','value','application/x-www-form-urlencoded; charset=UTF-8');
%                    header2 = struct('name','Connection','value','Keep-Alive');
%                    header3 = struct('name','Host','value','api-fxpractice.oanda.com');
%                    %api.headers = [header1;api.headers;header2;header3];
%                    api.headers = [header1 api.headers header2 header3];
                
                   
                   
               elseif strcmp(api.environment ,'live' )
                    disp('Set enviroment to live');
                   api.s_apiServer = 'https://api-fxtrade.oanda.com/'; 
                   api.headers =  struct('name','Authorization','value',strcat('Bearer %s',api.token));
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
               if nargin < 8
                   granularity='S5';
                   count='500';
                   startdate='';
                   enddate= '';
                   candleFormat='midpoint';
                   optincludeFirst ='';
                                      
               end    
               
               if( (strcmp(startdate,'' )==0) && (strcmp(enddate,'' )==0) )
                       optdate = strcat('&start=',startdate,'&end=',enddate);
                       optincludeFirst = strcat('&includeFirst= ',includeFirst);
                       count='';
               else
                       optdate = '';
               end
               
               
               
                requestString = strcat(api.s_apiServer , 'v1/candles?instrument=' , symbol,'&granularity=',granularity,'&count=',count,optdate,'&candleFormat=',candleFormat,optincludeFirst )%http://api-sandbox.oanda.com/v1/accounts/12345/trades
          
                History = api.MakeRequest(requestString)
               
           end
           %%
           
          
            
            
           
           
           
           
           
           
           
           
           
           
           function [ response ] = MakeRequest(api,requestString )
                
               resp = urlread2(requestString,'GET','',api.headers);
               response = loadjson(resp);


                end


           
           
       end
       
       
       
       %%   STATIC METHODS
       
       
       
       
       methods(Static)
           
            
           
           
           
           
           
       end
       
       
       
end
       % methods, including the constructor are defined in this block