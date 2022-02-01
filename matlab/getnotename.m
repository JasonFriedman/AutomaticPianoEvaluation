% GETNOTENAME - get the note name for a midi note
% name = getnotename(midinote)
% e.g. getnotename(60) will return 'C4'

function name = getnotename(midinote)

if numel(midinote)>1
    for k=1:numel(midinote)
        name{k} = getnotename(midinote(k));
    end
    return
end

notenames = {'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'};

notename = notenames{mod(midinote,12)+1};

octave = floor(midinote/12)-1;

name = [notename num2str(octave)];