% do Lasso fits

load evaluationfeatures % 11 features

% Create tables with the predictors + the outcome variable
numfeatures = 11;
t_predictors_pitch =        t(:,[1:numfeatures numfeatures+1]);
t_predictors_tempo =        t(:,[1:numfeatures numfeatures+2]);
t_predictors_rhythm =       t(:,[1:numfeatures numfeatures+3]);
t_predictors_articulation = t(:,[1:numfeatures numfeatures+4]);
t_predictors_overall =      t(:,[1:numfeatures numfeatures+5]);
t_predictors_recommendation = t(:,[1:numfeatures numfeatures+6]);
t_predictors_samechoice = t(:,[1:numfeatures numfeatures+7]);
t_predictors_differentchoice = t(:,[1:numfeatures numfeatures+8]);

ts = {t_predictors_pitch, t_predictors_tempo, t_predictors_rhythm, t_predictors_articulation, t_predictors_overall, ...
    t_predictors_recommendation, t_predictors_samechoice, t_predictors_differentchoice};
t_names = {'Pitch','Tempo','Rhythm','Articulation \& Dynamics','Overall','Recomm-endation','Same choice','Different choice'};

predictornames = {'Correct notes','Duration','Note duration (slope)','Note duration (offset)','Note duration (std)',...
    'Inter-note interval (slope)','Inter-note interval (offset)','Inter-note interval (std)',...
    'Velocity (slope)','Velocity (offset)','Velocity (std)'};

%%
% lassoo for each of the fields
% Note that as the process is stochastic, different results may be achieved
% each time. So we load the results previous generated
if exist('selected.mat','file')
    load selected;
else
    for k=1:5
        fprintf('%s\n',t_names{k});
        a = table2array(ts{k});
        X = a(:,1:end-1);
        Y = a(:,end);
        fns = fields(ts{k});
        [B,fitinfo] = lasso(X,Y,'CV',4,'PredictorNames',fns(1:size(X,2)));
        idxLambdaMinMSE = fitinfo.IndexMinMSE;
        selected(:,k) = B(:,idxLambdaMinMSE)~=0;
        minMSEModelPredictors = fitinfo.PredictorNames(B(:,idxLambdaMinMSE)~=0)
    end

    %

    for k=7:8
        fprintf('%s\n',t_names{k});
        a = table2array(ts{k});
        relevant = ~isnan(a(:,end));
        X = a(relevant,1:end-1);
        Y = a(relevant,end);
        fns = fields(ts{k});
        [B,fitinfo] = lasso(X,Y,'CV',4,'PredictorNames',fns(1:size(X,2)));
        idxLambdaMinMSE = fitinfo.IndexMinMSE;
        selected(:,k) = B(:,idxLambdaMinMSE)~=0;
        minMSEModelPredictors = fitinfo.PredictorNames(B(:,idxLambdaMinMSE)~=0)
    end

    % For this, use chi squared tests
    k=6;
    fprintf('%s\n',t_names{k});
    %[idx,scores] = fscmrmr(ts{k},'reccomendation');
    [idx,scores] = fscchi2(ts{k},'reccomendation')
    % pick the top 3
    selected(idx(1:3),k) = 1;
    save selected selected
end

%%

% Make a latex table for the paper
fprintf('\\begin{tabular}{p{3.5cm}||p{1cm}|p{1cm}|p{1.2cm}|p{1.6cm}|p{1cm}|p{1.5cm}|p{1cm}|p{1cm}}\n');
fprintf('Feature name & %s & %s & %s & %s & %s & %s & %s & %s\\\\ \n',t_names{1},t_names{2},t_names{3},t_names{4},t_names{5},t_names{6},t_names{7},t_names{8});
fprintf('\\hline\\hline\n');
for n=1:size(selected,1)
    fprintf('%s',predictornames{n});
    for k=1:numel(ts)
        if selected(n,k)
            fprintf('& X');
        else
            fprintf('& ');
        end
    end
    if n<size(selected,1)
        fprintf('\\\\\n\\hline\n');
    else
        fprintf('\n');
    end
end
fprintf('\\end{tabular}\n');

%% Do logistic regression for number 6
k=6;
a = table2array(ts{k});
X = a(:,selected(:,k));
Y = a(:,end);
[B,~,stats] = mnrfit(X,Y);
[pihat,dlow,dhi] = mnrval(B,X,stats);

thisnames = predictornames(selected(:,k));

% result = 1./(1+exp(-(B(1) + B(2).*X(:,1) + B(3).*X(:,2) + B(4).*X(:,3))))
fprintf('P(same) &= 1 / \\left(1 + e^{-(%.2f + %.2f \\text{%s} + %.2f \\text{%s} + %.2f \\text{%s})} \\right) \\\\\n',...
    B(1),B(2),thisnames{1},B(3),thisnames{2},B(4),thisnames{3});

accuracysame =  100*mean(pihat(Y==1) > 0.5);
accuracydifferent = 100 * mean(pihat(Y==2) < 0.5);

figure;
rows = 2;
cols = 4;

subplot(rows,cols,6);
plot(Y,pihat(:,1),'*');
hold on;
plot([0.5 2.5],[0.5 0.5],'k--');
xlim([0.5 2.5]);
ylim([0 1]);
set(gca,'XTick',[1 2],'XTickLabel',{'same','different'});
title({'Recommendation. Accuracy:',sprintf('same = %.0f%%, different = %.0f%%',accuracysame,accuracydifferent)});
ylabel('Probability of selecting same');
xlabel('Majority rater selection');
set(gca,'Box','off','FontSize',16);

% calculate accuracy
fprintf('Accuracy for same = %.2f%%\n',accuracysame)
fprintf('Accuracy for different = %.2f%%\n', accuracydifferent)


%% Do linear regression and print the regression equations

%figure;
for k=[1:5 7:8]
    subplot(rows,cols,k);
    a = table2array(ts{k});
    X = a(:,selected(:,k));
    thisnames = predictornames(selected(:,k));
    % add a column of ones
    X = [X ones(size(X,1),1)];
    Y = a(:,end);
    [b,~,~,~,stats] = regress(Y,X);
    Rsquared = stats(1);
    F = stats(2);
    p = stats(3);
    predicted = X * b;
    plot(Y,predicted,'*');
    hold on;
    if k<5
        plot([0 4],[0 4],'k--');
        axis([0 4 0 4]);
    elseif k==5
        plot([1 10],[1 10],'k--');
        axis([1 10 1 10]);
    elseif k>6
        plot([1 3],[1 3],'k--');
        axis([1 3 1 3]);
    end
    axis equal
    if k>cols
        xlabel('Mean rater score');
    end
    if mod(k-1,cols)==0
        ylabel('Predicted score');
    end
    title({strrep(t_names{k},'\&','&'),...
        sprintf('R^2=%.2f',Rsquared)});
    set(gca,'Box','off','FontSize',16);
    
    if k==7
        set(gca,'XTick',1:3,'XTickLabel',{'Slower','Same speed','Faster'},...
            'YTick',1:3,'YTickLabel',{'Slower','Same speed','Faster'});
    elseif k==8
        set(gca,'XTick',1:3,'XTickLabel',{'Easier','Same level','Harder'},...
            'YTick',1:3,'YTickLabel',{'Easier','Same level','Harder'});
    end

    fprintf('\\text{%s} &= ',t_names{k});
    inds = find(selected(:,k));
    for n=1:numel(inds)
        if b(n)<0
            fprintf(' - %.2f \\times \\text{%s}',-b(n),thisnames{n});
        else
            fprintf(' + %.2f \\times \\text{%s}',b(n),thisnames{n});
        end
    end
    if b(end)<0
        fprintf(' - %.2f \\\\\n',-b(end));
    else
        fprintf(' + %.2f \\\\\n',b(end));
    end
end
set(gcf,'PaperPosition',[0 0 40 30]);
print('-depsc2','figures/predictions');
saveas(gcf,'figures/predictions','fig');
