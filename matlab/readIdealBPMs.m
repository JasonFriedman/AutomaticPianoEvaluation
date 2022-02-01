% READIDEALBPMS Read the ideal tempo (in BPM - beats per minute)
%
% These are based on the instructions provided in the book where
% the songs were taken from
%
% [M_BPM,M_duration] = readIdealBPMs
% M_BPM is in BPM, duration is the overall duration (in seconds)
% both are returned as containers.Map
function [M_BPM,M_duration] = readIdealBPMs

keySet = {'Achbar Hizaher','Bnu Gesher','Emek Hanahar Haadom','Gina Li',...
    'HaAviv','HaKova Sheli','Hatul Al Hagag','Lifnei Shanim Rabot',...
    'Shir Eres','Yom Huledet Sameach'};

BPMs = [90, 70, 70, 70, ...
    70, 90, 120, 90, ...
    50, 70];

numBeats = [32 16 32 48 ...
    36 48 48 64 ...
    64 24];

durations = numBeats ./ BPMs * 60;
    
M_BPM = containers.Map(keySet,BPMs);
M_duration = containers.Map(keySet,durations);