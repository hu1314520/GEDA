function [Xs, Xt, A, acc, Yt0] = GEDA(Xs, Xt, Ys, Yt0, Yt, options)

% GEDA JSTARS 2021.7.10
%Huangyi Pengjiangtao

alpha = options.alpha;
mu = options.mu;
beta = options.beta;
ker = 'primal';
k = options.k;
T = options.T;

m = size(Xs,1);
ns = size(Xs,2);
nt = size(Xt,2);

class = unique(Ys);
C = length(class);
if strcmp(ker,'primal')
    
    [Lws,Lbs] = myConGraph2(Ys,options,Xs');
    Sb = Xs*Lbs*Xs';
    Sw = Xs*Lws*Xs';
    
    P = zeros(2*m,2*m);
    P(1:m,1:m) = Sb;
    Q = Sw;
    
    for t = 1:T
        [Lwt,Lbt] = myConGraph2(Yt0,options,Xt');
        Sbt = Xt*Lbt*Xt';
        Swt = Xt*Lwt*Xt';
        P(m+1:2*m,m+1:2*m) = Sbt;
        % Construct MMD matrix
        [Ms, Mt, Mst, Mts] = constructMMD(ns,nt,Ys,Yt0,C);
        
        Ts = Xs*Ms*Xs';
        Tt = Xt*Mt*Xt';
        Tst = Xs*Mst*Xt';
        Tts = Xt*Mts*Xs';
        
        % Construct centering matrix
        Ht = eye(nt)-1/(nt)*ones(nt,nt);
        
        X = [zeros(m,ns) zeros(m,nt); zeros(m,ns) Xt];
        H = [zeros(ns,ns) zeros(ns,nt); zeros(nt,ns) Ht];
        
        Smax = mu*X*H*X'+beta*P;
        Smin = [Ts+alpha*eye(m)+beta*Q, Tst-alpha*eye(m) ; ...
            Tts-alpha*eye(m),  Tt+beta*Swt+(alpha+mu)*eye(m)];
        [W,~] = eigs(Smax, Smin+1e-9*eye(2*m), k, 'LM');
        A = W(1:m, :);
        Att = W(m+1:end, :);
        
        Zs = A'*Xs;
        Zt = Att'*Xt;
        
        if T>1
            [acc,Yt0] = EasyTL2(Zs',Ys,Zt',Yt);
            fprintf('acc of iter %d: %0.4f\n',t, full(acc));
        end
    end
else
    %核部分、未利用
    Xst = [Xs, Xt];
    nst = size(Xst,2);
    [Ks, Kt, Kst] = constructKernel(Xs,Xt,ker,gamma);
    %--------------------------------------------------------------------------
    % compute LDA
    dim = size(Ks,2);
    C = length(class);
    meanTotal = mean(Ks,1);
    
    Sw = zeros(dim, dim);
    Sb = zeros(dim, dim);
    for i=1:C
        Xi = Ks(find(Ys==class(i)),:);
        meanClass = mean(Xi,1);
        Hi = eye(size(Xi,1))-1/(size(Xi,1))*ones(size(Xi,1),size(Xi,1));
        Sw = Sw + Xi'*Hi*Xi; % calculate within-class scatter
        Sb = Sb + size(Xi,1)*(meanClass-meanTotal)'*(meanClass-meanTotal); % calculate between-class scatter
    end
    P = zeros(2*nst,2*nst);
    P(1:nst,1:nst) = Sb;
    Q = Sw;
    
    for t = 1:T
        [Lwt,Lbt] = myConGraph2(Yt0,options,Xt');
        Sbt = Xt*Lbt*Xt';
        Swt = Xt*Lwt*Xt';
        P(m+1:2*m,m+1:2*m) = Sbt; 
        % Construct MMD matrix
        [Ms, Mt, Mst, Mts] = constructMMD(ns,nt,Ys,Yt0,C);
        
        Ts = Ks'*Ms*Ks;
        Tt = Kt'*Mt*Kt;
        Tst = Ks'*Mst*Kt;
        Tts = Kt'*Mts*Ks;
        
        K = [zeros(ns,nst), zeros(ns,nst); zeros(nt,nst), Kt];
        Smax =  mu*K'*K+beta*P;
        
        Smin = [Ts+alpha*Kst+beta*Q, Tst-alpha*Kst;...
            Tts-alpha*Kst, Tt+mu*Kst+beta*Swt+alpha*Kst];
        [W,~] = eigs(Smax, Smin+1e-9*eye(2*nst), k, 'LM');
        W = real(W);
        
        A = W(1:nst, :);
        Att = W(nst+1:end, :);
        
        Zs = A'*Ks';
        Zt = Att'*Kt';
        
        if T>1
            [acc,Yt0] = EasyTL2(Zs',Ys,Zt',Yt);
            fprintf('acc of iter %d: %0.4f\n',t, full(acc));
        end
        Xs = Zs;
        Xt = Zt;
    end
end

Xs = Zs;
Xt = Zt;