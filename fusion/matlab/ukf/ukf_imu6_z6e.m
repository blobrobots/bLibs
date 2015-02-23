% tiempos de muestreo
dt = 0.01;    % freq de filtro 100Hz
dtz = 0.02; % freq de medida 50Hz

racc = 0.01; %std of acc measurement
rmag = 0.1; %std of mag measurement

qe = 0; qbg = 0.0001;

gyro_max_rate = 1;
acc_max_rate = 1;
mag_max_rate = 1;

gyro_lpf = 0;
acc_lpf = 0;
mag_lpf = 0;

% q=[qe,qe,qe,qbg,qbg,qbg];    %std of process: qpos qvel qacc
% r=[racc,racc,racc,rmag,rmag,rmag];        %std of measurement: qpos qvel qacc

Q = [  (qe*dt)^2    0     0     0      0      0       % covariance of process
         0    (qe*dt)^2   0     0      0      0        
         0      0   (qe*dt)^2   0      0      0       
         0      0     0   (qbg*dt)^2    0     0       
         0      0     0     0   (qbg*dt)^2    0       
         0      0     0     0      0   (qbg*dt)^2 ];
     
R = [ (racc*dtacc)^2    0     0     0      0      0  % covariance of measurement
         0   (racc*dtacc)^2   0     0      0      0
         0      0  (racc*dtacc)^2   0      0      0
         0      0     0  (rmag*dtmag)^2    0      0
         0      0     0     0   (rmag*dtmag)^2    0
         0      0     0     0      0   (rmag*dtmag)^2 ];
% IMU:
% x = [q0, q1, q2, q3, gxb, gyb, gzb] = [quaternion, gyro_bias];
% u = [gx, gy, gz] = [gyro];
% z = [ax, ay, az, mx, my, mz] = [acc, mag];

f = @(x,args)f_imu6e(x,args.u,args.dt); % prediction equation
h = @(x,args)h_imu6e(x);                % measurement equation
x = zeros(6,1);                         % initial state
N = size(x,1);                          % number of states                           
P = eye(N);                             % initial state covariance
u = [0 0 0];                            % initial input
z = [0;0;-1];                           % normalized measurement

gx=0;gy=0;gz=0;
ax=0;ay=0;az=-9.8;
mx=0;my=0;mz=0;

time=size(imu(2).data,1); % total dynamic steps (1 per ms)

xV = zeros(N,time); % state output
uV = zeros(3,time); % control output
zV = zeros(6,time); % measurement output

imugx = imu(2).data(:,1);
imugy = imu(2).data(:,2);
imugz = imu(2).data(:,3);
imuax = imu(2).data(:,4);
imuay = imu(2).data(:,5);
imuaz = imu(2).data(:,6);
imumx = imu(2).data(:,7);
imumy = imu(2).data(:,8);
imumz = imu(2).data(:,9);

for t=1:time
    if (mod(t,dt*1000) == 0)
        % filter sensor data
        gx = gx + constrain((gyro_lpf*gx + (1-gyro_lpf)*imugx(t)) - gx, -gyro_max_rate, gyro_max_rate);
        gy = gy + constrain((gyro_lpf*gy + (1-gyro_lpf)*imugy(t)) - gy, -gyro_max_rate, gyro_max_rate);
        gz = gz + constrain((gyro_lpf*gz + (1-gyro_lpf)*imugz(t)) - gz, -gyro_max_rate, gyro_max_rate);
        
        ax = ax + constrain((acc_lpf*ax + (1-acc_lpf)*imuax(t)) - ax, -acc_max_rate, acc_max_rate);
        ay = ay + constrain((acc_lpf*ay + (1-acc_lpf)*imuay(t)) - ay, -acc_max_rate, acc_max_rate);
        az = az + constrain((acc_lpf*az + (1-acc_lpf)*imuaz(t)) - az, -acc_max_rate, acc_max_rate);
        
        mx = mx + constrain((mag_lpf*mx + (1-mag_lpf)*imumx(t)) - mx, -mag_max_rate, mag_max_rate);
        my = my + constrain((mag_lpf*my + (1-mag_lpf)*imumy(t)) - my, -mag_max_rate, mag_max_rate);
        mz = mz + constrain((mag_lpf*mz + (1-mag_lpf)*imumz(t)) - mz, -mag_max_rate, mag_max_rate);

        % normalise the measurements
        anorm = sqrt(ax*ax + ay*ay + az*az);
        if (anorm > 0)
            axn = ax/anorm;
            ayn = ay/anorm;
            azn = az/anorm;
        end
        mnorm = sqrt(mx*mx + my*my + mz*mz);
        if (mnorm > 0)
            mxn = mx/mnorm;
            myn = my/mnorm;
            mzn = mz/mnorm;
        end

        u(1) = gx;
        u(2) = gy;
        u(3) = gz;
        
        % apply filter
        if(mod(t,dtz*1000) == 0)
           z = [axn; ayn; azn; mxn; myn; mzn]; % measurements
           [x, P] = ukf(dt,x,P,f,u,Q,h,z,R);  % ukf predict + measurement update
        else
           [x, P] = ukf(dt,x,P,f,u,Q); % ukf  only predict 
        end
    end
    % plot purposes
    xV(:,t) = x;                            
    uV(:,t) = u;
    zV(:,t) = z;
end
