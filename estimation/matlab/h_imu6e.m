%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The MIT License (MIT)
%
% Copyright (c) 2015 Blob Robotics
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal 
% in the Software without restriction, including without limitation the rights 
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is 
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
% SOFTWARE.
% 
% \file       h_imu6e.m
% \brief      expected accelerometer and magnetometer measurement given state
% \author     adrian jimenez-gonzalez (blob.robots@gmail.com)
% \copyright  the MIT License Copyright (c) 2015 Blob Robots.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% expected accelerometer and magnetometer measurement given state
% in:
% x = [roll, pitch, yaw, gbx, gby, gbx]
% z = [ax, ay, az, mx, my, mz]
% out:
% output: [ax, ay, az, mx, my, mz] = expected accel and mag given state
function output = h_imu6e(x)

roll = x(1); pitch = x(2); yaw = x(3);

g = -1; % NED frame
h =  1;

% expected accel and mag measurement given state estimation and direction of gravity and magnetic field in NED frame
output = [ -g*sin(pitch);             % ax
            g*sin(roll)*cos(pitch);   % ay
            g*cos(pitch)*cos(roll);   % az
            h*cos(pitch)*cos(yaw);    % mx
            h*(sin(roll)*sin(pitch)*cos(yaw) - cos(roll)*sin(yaw));    % my
            h*(cos(roll)*sin(pitch)*cos(yaw) + sin(roll)*sin(yaw)); ]; % mz
end

% explanation:
% 
% navigation to body frame rotation:
% bfx = nfx*cos(pitch)*cos(yaw)                                  + nfy*cos(pitch)*sin(yaw)                                  - nfz*sin(pitch);
% bfy = nfx*(sin(roll)*sin(pitch)*cos(yaw) - cos(roll)*sin(yaw)) + nfy*(sin(roll)*sin(pitch)*sin(yaw) + cos(roll)*cos(yaw)) + nfz*sin(roll)*cos(pitch);
% bfz = nfx*(cos(roll)*sin(pitch)*cos(yaw) + sin(roll)*sin(yaw)) + nfy*(cos(roll)*sin(pitch)*sin(yaw) - sin(roll)*cos(yaw)) + nfz*cos(pitch)*cos(roll);
%
% normalized gravity vector in NED reference frame: g = [0; 0; -1]
% expected normalized accelerometer measurement (body frame rotation):
% a = [ sin(pitch); -sin(roll)*cos(pitch); -cos(pitch)*cos(roll);]
%
% normalized magnetic field vector in navigation reference frame: h = [1; 0; 0]
% expected normalized accelerometer measurement (body frame rotation):
% m = [  cos(pitch)*cos(yaw); 
%       (sin(roll)*sin(pitch)*cos(yaw) - cos(roll)*sin(yaw)); 
%       (cos(roll)*sin(pitch)*cos(yaw) + sin(roll)*sin(yaw));]
%