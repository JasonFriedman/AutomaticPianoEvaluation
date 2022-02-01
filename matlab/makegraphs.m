% These are for making graphs used in the paper, follow the instructions in
% the comments, they cannot be just run

% Open graph of HaAviv → student 9 → duration

set(gca,'Box','off','FontSize',16);

set(gcf,'PaperPosition',[0 0 30 20]);
print('-depsc2','figures/relativeduration_example');

%%
% Do the correlation plot

figure;
if ~isempty(which('corrplot_donttruncate'))
    [r,pvalue,h] = corrplot_donttruncate(t(:,end-4:end));
    % To make this file (corrplot_donttruncate), I took the file corrplot.m
    % and commented out three lines:
    % varNames = cellfun(@(s)[s,'     '],varNames,'UniformOutput',false);
    % varNames = cellfun(@(s)s(1:5),varNames,'UniformOutput',false);
    % set(get(bigAx,'Title'),'String','{\bf Correlation Matrix}')
else
    [r,pvalue,h] = corrplot(t(:,end-4:end));
end

set(gcf,'PaperPosition',[0 0 20 20]);
fn = 'figures/ratingcorrelations';
print('-depsc2',fn);

%%

% Select the piece Yom Huledet Sameach, Student 25, rectangles, show ideal,
% normalize time

% Open graph in new window

set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 30 20])
print('-dpng','figures/happybirthdayexample')

% Photo is https://unsplash.com/photos/UYgd_Kr6k_w from Josh Duke

%% Plot just overall - run this after doLasso

k=5;
figure
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
hold on
plot([1 10],[1 10],'k--');
axis([1 10 1 10]);
set(gca,'XTick',2:2:10,'YTick',2:2:10)
%axis equal
xlabel('Mean rater score');
ylabel('Predicted score');
set(gca,'FontSize',16,'Box','off')
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 10 0])
print('-dpng','figures/overallregression')

