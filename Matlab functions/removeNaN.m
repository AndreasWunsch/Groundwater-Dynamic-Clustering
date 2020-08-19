function [X,date] = removeNaN(X1,date1)
    NaN=isnan(X1);
    X = X1; date = date1;
    X(NaN) = [];
    date(NaN) = [];
end

