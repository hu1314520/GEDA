function [source_class_center,Dct] = get_class_center(Xs,Ys,Xt,dist)
% Get source class center and Dct
source_class_center = [];
Dct = [];
class_set = unique(Ys)';
for i = class_set
    indx = Ys == i;
    X_i = Xs(indx,:);
    mean_i = mean(X_i);
    source_class_center = [source_class_center,mean_i'];
    switch(dist)
        case 'ma'
            Dct_c = mahal(X_i,Xt);
        case 'euclidean'
            %Dct_c = sqrt(sum((mean_i - Xt).^2,2));
            Dct_c = sqrt(sum((ones(size(Xt,1),1)*mean_i - Xt).^2,2));
        case 'sqeuc'
            Dct_c = sum((mean_i - Xt).^2,2);
        case 'cosine'
            Dct_c = cosine_dist(Xt,mean_i);
        case 'rbf'
            Dct_c = sum((mean_i - Xt).^2,2);
            Dct_c = exp(-Dct_c / 1);
    end
    Dct = [Dct,Dct_c];
end

