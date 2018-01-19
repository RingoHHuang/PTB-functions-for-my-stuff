function [keyPressed, RT] = WaitForKeyboardInput(varargin)
%% Convenience function to interface with PTB keyboard input functions
% 3 options: TerminateIfKeyPressed; TerminateAfterDurationElapsed;
% TerminateIfKeyPressedOrDurationElapsed
%
% Written by: Ringo Huang
% Created on 1/19/2018

startTime = GetSecs;
narginchk(1,3);

type = varargin{1};
if nargin == 1  
    allowableResponses = 1:256;       %default to any keyCode (256 keys)
    duration = inf;                   %default to infinite duration
elseif nargin == 2
    allowableResponses = varargin{2};
    duration = inf;
elseif nargin == 3
    allowableResponses = varargin{2};
    duration = varargin{3};
end

keyPressed = [];
RT = [];

keyIsDown = 0;

switch type
    case 'TerminateIfKeyPressed'
        % Make sure key has been released before polling next keyboard input
        while KbCheck
        end
        while ~keyIsDown
            [keyIsDown, secs, keyCode, ~] = KbCheck;
            if keyIsDown && ismember(find(keyCode,1,'first'),allowableResponses)
                keyPressed = find(keyCode,1,'first');
                RT = secs-startTime;
            elseif keyIsDown == 1 && ~ismember(find(keyCode,1,'first'),allowableResponses)
                keyIsDown = 0;      %keep polling
            end
            WaitSecs(0.001);        %do not poll continuously
        end
    case 'TerminateAfterDurationElapsed'
        % Make sure key has been released before polling next keyboard input
        while KbCheck
        end
        while GetSecs - startTime < duration
            [keyIsDown, secs, keyCode, ~] = KbCheck;
            if keyIsDown  && ismember(find(keyCode,1,'first'),allowableResponses)
                keyPressed(end + 1) = find(keyCode,1,'first');
                RT(end + 1) = secs-startTime;
                while KbCheck
                end
            end
            WaitSecs(0.001);        %do not poll continuously
        end
    case 'TerminateIfKeyPressedOrDurationElapsed'
        % Make sure key has been released before polling next keyboard input
        while KbCheck 
        end
        while GetSecs - startTime < duration && ~keyIsDown
            [keyIsDown, secs, keyCode, ~] = KbCheck;
            if keyIsDown && ismember(find(keyCode,1,'first'),allowableResponses)
                keyPressed(end+1) = find(keyCode,1,'first');
                RT(end+1) = secs-startTime;
            elseif keyIsDown && ~ismember(find(keyCode,1,'first'),allowableResponses)
                keyIsDown = 0;      %reset keyIsDown if keyCode is not a 
            end
            WaitSecs(0.001);        %do not poll continuously
        end
end
end