% BETWEENRATERCORRELATIONS Make a latex table of the between rater correlations
% for the 8 features, calculate mean +- std

[ratings,names] = readEvaluation;

for feature = 8:-1:1
    thisfeature = squeeze(ratings(:,:,feature));
    numraters = size(thisfeature,1);
    allcorr = corr(thisfeature','Rows','pairwise');
    allvals = allcorr(find(allcorr .* ~tril(ones(numraters))));
    meancorr(feature) = mean(allvals);
    stdcorr(feature) = std(allvals);
end

% print as a latex table for copy/paste

fprintf('%s & %s & %s & %s & %s \\ \n',names{1:5});
fprintf('$%.2f \\pm %.2f$ & $%.2f \\pm %.2f$ & $%.2f \\pm %.2f$ & $%.2f \\pm %.2f$ & $%.2f \\pm %.2f$\n',...
    meancorr(1),stdcorr(1),...
    meancorr(2),stdcorr(2),...
    meancorr(3),stdcorr(3),...
    meancorr(4),stdcorr(4),...
    meancorr(5),stdcorr(5));