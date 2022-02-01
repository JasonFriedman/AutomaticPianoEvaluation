% READEVALUATION  Read the evaluation file
% [ratings,names] = readEvaluation

function [ratings,names] = readEvaluation

subjectorder = [12 3 23 10 6 18 1 22 11 19 2 4 7 8 15 20 24 14 16 9 21 5 17 25 13];

names = {'pitch','tempo','rhythm','articulation','overall','reccomendation','samechoice','differentchoice'};

t = readtable('Music+evaluation_September+7%2C+2021_07.06.csv');

numraters = size(t,1);

numsongs = 25;

for rater=1:numraters
    % Removed to anonymize the raters
    %ratername{rater} = t.Q1(rater); 
    %rateremail{rater} = t.Q2(rater);

    for song=1:numsongs
        for val = 1:8
            if val<=4
                ratings(rater,subjectorder(song),val) = 5 - table2array(t(rater,19 + (song-1)*8 + val));
            else
                ratings(rater,subjectorder(song),val) = table2array(t(rater,19 + (song-1)*8 + val));
            end
        end
    end
end

save evaluation ratings
