% PLOTFEATURESDISTRIBUTION - plot the distributions of the 11 features
% (as histograms), save to an eps file

load evaluationfeatures % 11 features

thefeatures = fields(t);
predictornames = {'Correct notes','Duration','Note duration (slope)','Note duration (offset)','Note duration (std)',...
    'Inter-note interval (slope)','Inter-note interval (offset)','Inter-note interval (std)',...
    'Velocity (slope)','Velocity (offset)','Velocity (std)'};

rows = 3;
cols = 4;
for k=1:11
    subplot(rows,cols,k)
    histogram(t.(thefeatures{k}),5);
    xlabel(predictornames{k});
    if mod(k,4)==1
        ylabel('Count')
    end
    set(gca,'Box','off','FontSize',12)
end

set(gcf,'PaperPosition',[0 0 30 20])
print('-depsc2','figures/featuresdistribution')

