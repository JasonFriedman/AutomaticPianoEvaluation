% CALCULATEFEATURES  Calculate features from the MIDI data
%
% [features,tocheck,tocheckideal,details] = calculateFeatures(midi,idealmidi,idealoverallduration)
% midi is the MIDI data (output from loadmidifile)
% idealmidi is the MIDI data of the ideal performance (also output from loadmidifile)
% idealoverallduration is the ideal duration of the song (in seconds)
%
% Returns: features - a struct with the features
%          tocheck - which notes (indices) in the performance correspond to notes in the "ideal"
%          tocheckideal - which notes (indices) in the ideal correspond to those in the performance
%          details - additional quantities calculated which may be of use
function [features,tocheck,tocheckideal,details] = calculateFeatures(midi,idealmidi,idealoverallduration)

[details.dtw,ix,iy] = dtw(midi.note,idealmidi.note);
details.editdistance = editDistance(char(midi.note),char(idealmidi.note));

overallduration = midi.onset(end) + midi.duration(end) - midi.onset(1);
% Ideal overall duration is passed as a parameter
idealmididuration = idealmidi.onset(end) + idealmidi.duration(end) - idealmidi.onset(1);

% calculate difference for each note played
%[tocheck,inds] = unique(ix,'last'); % don't look at repeated notes (which were needed for DTW to work)
%tocheckideal = iy(inds);

% the other way around
[tocheckideal,inds] = unique(iy,'last'); % don't look at repeated notes (which were needed for DTW to work)
tocheck = ix(inds);

% Proportion of notes played correctly
notes = abs(sign(idealmidi.note(tocheckideal) - midi.note(tocheck)));
if numel(notes)<numel(idealmidi.note)
    notes = [notes ones(1,numel(idealmidi.note)-numel(notes))];
end

features.notesCorrect = 1-mean(notes);

features.overalldurationdifference = (overallduration - idealoverallduration) ./ idealoverallduration;

% duration = on to off
playeddurations = midi.duration(tocheck) ./ overallduration;
idealdurations = idealmidi.duration(tocheckideal) ./ idealmididuration;
Y = (playeddurations ./ idealdurations)';

% Note duration
%features.durationdifference = median(abs(playeddurations - idealdurations) ./ idealdurations);

[features.durationslope,features.durationoffset,features.durationstd] = calculateparams(Y);

% to calculate onset slope
onset = midi.onset;
onset = (onset - min(midi.onset)) / overallduration;
onsetIdeal = idealmidi.onset;
onsetIdeal = (onsetIdeal - min(idealmidi.onset)) / idealmididuration;
% We need to match the notes - so only do for those in "tocheck"
onsetDiff = onset(tocheck)-onsetIdeal(tocheckideal);
% use the last value - first value as the slope
%features.onsetslope = (onsetDiff(end) - onsetDiff(1)) ./ numel(onsetDiff);
% use regression

% remove for now, use gaps instead
%%%Y = onsetDiff';
%%%[features.onsetslope,features.onsetoffset,features.onsetstd] = calculateparams(Y);

% timing = relative time (since last press) - for the 2nd note on

% for timing, use the ideal
[tocheckideal2,inds] = unique(iy,'last');
tocheck2 = ix(inds);

idealgaps = (idealmidi.onset(tocheckideal2(2:end)) - idealmidi.onset(tocheckideal2(1:end-1))) ./ idealmididuration;
actualgaps = (midi.onset(tocheck2(2:end)) -  midi.onset(tocheck2(1:end-1))) ./ overallduration;
%features.timingdifference = median(abs(actualgaps - idealgaps) ./ idealgaps);
Y = ((actualgaps - idealgaps) ./ idealgaps)';
[features.internoteintervalslope,features.internoteintervaloffset,features.internoteintervalstd] = calculateparams(Y);

playedvelocity = midi.pressvelocity(tocheck);
idealvelocity = idealmidi.pressvelocity(tocheckideal);
Y = (playedvelocity - idealvelocity)';
%features.velocitydifference = median(Y);

[features.velocityslope, features.velocityoffset, features.velocitystd] = calculateparams(Y);

if nargout>3
    details.playeddurations = playeddurations;
    details.idealdurations = idealdurations;
    details.actualgaps = actualgaps;
    details.idealgaps = idealgaps;
    details.overallduration = overallduration;
    details.idealoverallduration = idealoverallduration;
    details.idealmididuration = idealmididuration;
end

function [slope,offset,thestd] = calculateparams(Y)

X = [(1:numel(Y))' ones(size(Y))];
b = regress(Y,X);
predicted = b(1) * (1:numel(Y))' + b(2);
slope = b(1);
offset = b(2);
thestd = std(Y - predicted);
