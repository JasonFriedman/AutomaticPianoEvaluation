% READMIDIFILE - read a MIDI file
%
% data = readmidifile(fn)
% fn is the filename
% data is a struct with 5 fields:
% data.note are the notes played 
% data.onset are the onset times (in seconds)
% data.duration are the note durations (in seconds) - time from press to
%                                                     release
% data.pressvelocity is the velocity when presed
% data.releasevelocity is the release velocity

function data = readmidifile(fn)

if ~exist(fn,'file')
    error(['The midi file ' fn ' does not exist']);
end

midi = readmidi(fn);

count = 0;
thetime = 0;

for k=1:numel(midi.track(2).messages)
    message = floor(midi.track(2).messages(k).type / 16);
    channel = mod(midi.track(2).messages(k).type,16);
    thetime = thetime + midi.track(2).messages(k).deltatime;
    
    if message==9 % 1001
        count = count+1;
        thevelocity = midi.track(2).messages(k).data(2);
        % sometimes velocity = 0 is the same as note off
        if thevelocity==0
            off(count) = 1;
        else
            on(count) = 1;
        end
    elseif message==8 %1000
        count = count +1;
        off(count) = 1;        
    else
        continue;       
    end
    
    note(count) = midi.track(2).messages(k).data(1);
    velocity(count) = midi.track(2).messages(k).data(2);
    time(count) = thetime ./ 1000; % this is in "ticks"
end

ons = find(on);
offs = find(off);

count = 0;

for k=1:numel(ons)
    thisnote = note(ons(k));
    thisonset = time(ons(k));
    thispressvelocity = velocity(ons(k));
    % find its matching off
    matchingoff = find(time(offs)>thisonset,1);
    thisrelease = time(offs(matchingoff));
    thisduration = thisrelease - thisonset;
    thisreleasevelocity = velocity(offs(matchingoff));
    
    count = count+1;
    data.note(count) = thisnote;
    data.onset(count) = thisonset;
    data.duration(count) = thisduration;
    data.pressvelocity(count) = thispressvelocity;
    data.releasevelocity(count) = thisreleasevelocity;
end
