function s = SQW(t) %#codegen
%SQUARE Square wave generation.
%   SQUARE(T) generates a square wave with period 2*Pi for the
%   elements of time vector T.  SQUARE(T) is like SIN(T), only
%   it creates a square wave with peaks of +1 to -1 instead of
%   a sine wave.
%   SQUARE(T,DUTY) generates a square wave with specified duty
%   cycle. The duty cycle, DUTY, is the percent of the period
%   in which the signal is positive.
%
%   For example, generate a 30 Hz square wave:
%        t = 0:.0001:.0625;
%        y = square(2*pi*30*t);, plot(t,y)
%
%   See also SIN, COS, CHIRP, DIRIC, GAUSPULS, PULSTRAN, RECTPULS,
%   SINC and TRIPULS.

%   Author(s): L. Shure, 2-23-88
%   Copyright 1988-2018 The MathWorks, Inc.

% If no duty specified, make duty cycle 50%.

duty = 50; %see above


% 't' input must be real
% validateattributes(t,{'numeric'},{'real'},mfilename,'t',1);
% % 'duty' input must be a real scalar
% validateattributes(duty,{'numeric'},{'real','scalar'},mfilename,'duty',2);

% Compute values of t normalized to (0,2*pi)
tmp = mod(t,2*pi); %remainder/modulus after division of t/2pi - x must be in terms of pi (hence multiplication by pi/2)

% Compute normalized frequency for breaking up the interval (0,2*pi)
w0 = 2*pi*duty(1,1)/100; 

% Assign 1 values to normalized t between (0,w0), 0 elsewhere
nodd = (tmp < w0);

% The actual square wave computation
s = 2*nodd-1;