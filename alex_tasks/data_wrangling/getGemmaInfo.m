function [y , z] = getGemmaInfo(startAcc,endAcc,varargin);
% call with (1,1) or (start#,end#)
y = [];
z = [];
p = "s";
authorize = 1;
if length(varargin) == 1
    authorize = 0;
elseif length(varargin) == 2
    p = matlab.net.base64encode(strcat(string(varargin(1)),":",string(varargin{2})));
elseif length(varargin) == 3
    p = matlab.net.base64encode(strcat(string(varargin(1)),":",string(varargin{2})));
    authorize = 0;
end
options = weboptions;
options.CertificateFilename=('');
options.Timeout = 10000;
if authorize
options.HeaderFields = matlab.net.http.field.AuthorizationField("Authorization", strcat("Basic ",p));
end
apiHit = '';

if endAcc ~= 0
if (endAcc - startAcc < 1000)
    lastTemp = startAcc;
    temp = endAcc;
else 
lastTemp = startAcc;
temp = startAcc + 1000;
end
else 
    fileID = fopen(startAcc);
    scanned = textscan(fileID,'%s');
    fclose(fileID);
    scannedArray = (string(scanned{:,:}));
    i = scannedArray;
end

loopNum = 0;
try 
if endAcc ~= 0
while true
    if temp > endAcc ; break ; end
    i = lastTemp:temp;
    tempHit = char(strjoin(string(cast(webread(gemmaQueryBuilder(i),options) ,'char')),''));
    lastTemp = temp+1;
    temp = temp+1000;
    if ~loopNum
        apiHit = tempHit;
    else apiHit = combineGemmaJSONchars(apiHit,tempHit);
    end
    loopNum = loopNum + 1; 
end
else 
    apiHit = char(strjoin(string(cast(webread(gemmaQueryBuilder(i),options) ,'char')),''));
end
struct = jsondecode(apiHit);
structArray = struct.data;
%save('nextGemmaAPI','structArray')
temptable2 = struct2table(structArray); 
vec = 1:size(temptable2,2);
temptable2 = temptable2(:,setdiff(vec,[24,32,35,36]));
writetable(temptable2, 'nextGemmaAPI.txt')
disp( "Call complete || CSV saved  ")
y = structArray;
z="";
for i = 1:size(y,1)
    z(i,1) = string(y(i).shortName);
end
exit()
catch ME
    if string(ME.identifier) == "MATLAB:webservices:HTTP401StatusCodeError"
        warning(strcat('Credentials not accepted at the Gemma end. Try entering your Gemma username and password...', newline, 'TO QUIT THE CALL TO THE API, ENTER USERNAME: quit'))
        uname = input('Enter gemma username: ','s');
        if string(uname) ~= "quit"
        pass = input('Enter gemma password: ','s');
        disp("retrying...")
        [y,z] = getGemmaInfo(startAcc, endAcc, uname, pass);
        else disp("Gemma call was cancelled, thus an empty Gemma List will be used from hence forth")
        end
    else rethrow(ME)
    end
end

end
function y = gemmaQueryBuilder(q)
query = "";
for i = 1:length(q)
    query = strcat(string(q(i)),'%2C',query);
end
y = strcat('https://gemma.msl.ubc.ca/rest/v2/datasets/',query,'?offset=0&limit=0&sort=%2Bid');
end
function y = combineGemmaJSONchars(j1,j2)
y= strcat( j1(1:end-2), ',', j2(10:end));
end
function y = parseGseAccession(x)
% x is a length(x) by 1 string array, y is just the double of the
% accesssion
y = [];
t = char(x);
for i = 1:size(t,1)
    temp = t(i,1:end);
    y(i,1) = str2num(temp(4:end));
end
end
