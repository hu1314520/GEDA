function [acc,y_pred] = EasyTL2(Xs,Ys,Xt,Yt,~)
% Inputs:
%%% Xs          : source data, ns * m
%%% Ys          : source label, ns * 1
%%% Xt          : target data, nt * m
%%% Yt          : target label, nt * 1
%%%%%% The following inputs are not necessary
%%% intra_align : intra-domain alignment: coral(default)|gfk|pca|raw
%%% dist        : distance: Euclidean(default)|ma(Mahalanobis)|cosine|rbf
%%% lp          : linear(default)|binary
C = length(unique(Ys));                 % num of shared class
if C > max(Ys)
    Ys = Ys + 1;
    Yt = Yt + 1;
end
m = length(Yt); 
 lp = 'linear';
dist = 'euclidean';
[~,Dct]= get_class_center(Xs,Ys,Xt,dist);
fprintf('Start intra-domain programming...\n');
[Mcj] = label_prop(C,m,Dct,lp);
[~,y_pred] = max(Mcj,[],2);
acc = mean(y_pred == Yt);


    