%% Source and Target are from Botwana
clear;clc;
load 2001may31.mat; %% data name

f = fspecial('average',5);
Data = imfilter(Data,f);

[nr,nc,nDim] = size(Data);  nAll = nr*nc;
Data2 = reshape(Data, nAll, nDim);
tmp = unique(DataClass); classLabel = tmp(tmp~=0); nClass = length(classLabel);

% Source domain
DataClass1 = DataClass(:,1:180);   Label = [3 4 6 8 9 10];
postrn_Src = []; 
for i = 1 : length(Label)
    numi = length(find(DataClass1==Label(i)));
    [B,D] = find(DataClass1==Label(i));
    tmptrn = zeros(3,numi); 
    tmptrn(1,:) = B; tmptrn(2,:) = D; tmptrn(3,:) = i;
    postrn_Src = [postrn_Src tmptrn];
end
ntrn_Src = size(postrn_Src,2); YTrn_Src = postrn_Src(3, :)';
for i = 1 : ntrn_Src
    idxtrn_Src(i) = (postrn_Src(2,i)-1)*nr + postrn_Src(1,i);
end
XTrn_Src = Data2(idxtrn_Src,:);

% Target domain
DataClass2 = DataClass; DataClass2(:,1:180) = 0;
postrn_Tar = [];  
for i = 1 : length(Label)
    numi = length(find(DataClass2==Label(i)));
    [B,D] = find(DataClass2==Label(i));
    tmptrn = zeros(3,numi); 
    tmptrn(1,:) = B; tmptrn(2,:) = D; tmptrn(3,:) = i;
    postrn_Tar = [postrn_Tar tmptrn];
end
ntrn_Tar = size(postrn_Tar,2); YTrn_Tar = postrn_Tar(3, :)';
for i = 1 : ntrn_Tar
    idxtrn_Tar(i) = (postrn_Tar(2,i)-1)*nr + postrn_Tar(1,i);
end
XTrn_Tar = Data2(idxtrn_Tar,:);
Source = XTrn_Src;   Source_label = YTrn_Src;  
Target = XTrn_Tar;   Target_label = YTrn_Tar;

fts = Source ./ repmat(sum(Source,2),1,size(Source,2)); % L1norm = 1
Source_Zs = zscore(fts,1);  % mean = 0, std = 1
fts = Target ./ repmat(sum(Target,2),1,size(Target,2)); 
Target_Zs = zscore(fts,1);
%% Set algorithm parameters(GEDA)
options.k = 20;            % #subspace bases 
options.ker = 'primal';     % kernel type, default='linear' options: linear, primal, gauss, poly 10 20 1 0.5 10 5
options.T = 10;             % #iterations, default=10
options.alpha = 1;           % the parameter for subspace divergence ||A-B||
options.mu = 0.01;             % the parameter for target variance
options.beta = 1;        % the parameter for P and Q (source discriminaiton)
options.interK = 10; 
options.intraK = 5; 

Xs = Source_Zs';   Xt = Target_Zs'; 
Ys = Source_label; Yt = Target_label;
[acc,Yt0] = EasyTL2(Xs',Ys,Xt',Yt);
fprintf('acc=%0.4f\n',full(acc));

[Zs, Zt, ~, acc, Yt0] = GEDA(Xs, Xt, Ys, Yt0, Yt,options);
