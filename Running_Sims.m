clear all;
% 
% % % %set up of cluster parameters - Euler
% batch_job = parcluster('EulerLSF8h');
% batch_job = parcluster('MATLAB Parallel Cloud');
% batch_job.SubmitArguments = '-W 24:00 -R "rusage[mem=3210]"'; 
% num_pp=35; %number of workers (max 39 with memory 3210 - why not 40 with 3100? - euler should allow 48)
% pool = parpool(batch_job, num_pp); 

%%%for local cluster 
num_pp=6; %number of workers (cores)
local_job = parcluster('local');
pool = parpool(local_job, num_pp);

rng('shuffle','simdTwister')
pp=what('TEST_SHOWING');
path=pp.path;

%average for the lengthscale
v0 = 5e-6; %velocity (metres)
L_V = [10]; %L/V ratio
gap = v0*L_V; %"length" of a box/period
tau = [0,0.03,0.3,3,30,300];

%unique(round(logspace(-2,2,20),3));%unique(round(logspace(-2,2,8),3));%unique(round(logspace(2,4,5),3)); %unique(round(logspace(2,4,5),3));
%tau(end) = [] %drop final element
% tau(1) = []; %drop first element %

Np=1e1; %number particles 
dt=1e-3; %integration time step (in seconds)

N = 1e4;  %total number of steps DEFAULT 1e8!! (increased by 10 for tau increased by factor 10) - increased from 1e8 to 1e9 for dt = 1e-4, since need to match times
%for tau = 1e4, increased to 1e9 so that dt*N >= 100*tau( - when dt = 1e-3,
%ensuring that enough time for tau to relax)
delta=50;%every data points saved %10000 for L/v = 10 - 10000 seconds to save
%!!! N/delta must be a positive number

period = 5; %how many waves to have (10 normally, 5 for imaging?)

W=0/180*pi; %angular velocity rad/s
PBC = 1; %periodic boundary conditions
verbose = 0; %simulation time shown - always off for parallel

%DR values
% kappa_Dr = 1000; %ratio between Dr_min, Dr_max 
% Dr_min = 0.010295335381257;
% Dr_max = Dr_min*kappa_Dr;

%Velocity values
kappa_v0 = 10;
v0_min = 0;%1e-6;
v0_max = 2e-6;%v0_min*kappa_v0;

% W_min = 0;
% W_max = 10;

[Y,Z] = meshgrid(gap,tau);

g=reshape(Y,1,numel(gap)*numel(tau)); %gaps (L_V ratios)
T=reshape(Z,1,numel(gap)*numel(tau)); %taus 

M=[g' T'];
%
pathprova=[path];

F=filter_files(pathprova);%is a function fabio wrote - formats so tau, v0 and gap are input in row below F
if ~isempty(F)
    indeces = ismember(M,F,'rows');
    M(indeces,:)=[];
end

%
g=M(:,1);T=M(:,2);

%num_fbatch 
%number of batches needed 
num_fbatch=floor(numel(g)/num_pp); %numel is number of elements - therefore no point using parallel.pool.Constant()
%modulus of the number batches needed
num_rem=mod(numel(g),num_pp); %modulus/remainder of numel(v)/num_pp 

% Running_Sims_function(Np,dt,N,delta,100e-6,1e-3,v0,4,Dr_min,Dr_max,W,verbose,pathprova,PBC);

for jobs=1:num_fbatch %used to reset after each full occupation of all the workers - resets memory (otherwise huge build up)
% parpool(num_pp,'SpmdEnabled', false)
parfor i=jobs*(num_pp)-num_pp+1:jobs*(num_pp)
%for DR
% Running_Sims_function(Np,dt,N,delta,g(i),[g(i)*period g(i)*period],v0,T(i),Dr_min,Dr_max,W,verbose,pathprova,PBC);
%for v0
Running_Sims_function(Np,dt,N,delta,g(i),[g(i)*10 g(i)*10],v0,T(i),v0_min,v0_max,W,verbose,pathprova,PBC);
end
% delete(gcp('nocreate'));
end
% 
% parpool(num_pp,'SpmdEnabled', false)
%modulus of the left overs
parfor i=num_fbatch*(num_pp)+1:numel(g) %used for the final remainder on top - since the floor cuts out the remainder
%for DR
% Running_Sims_function(Np,dt,N,delta,g(i),[g(i)*period g(i)*period],v0,T(i),Dr_min,Dr_max,W,verbose,pathprova,PBC);
%for v0
Running_Sims_function(Np,dt,N,delta,g(i),[g(i)*10 g(i)*10],v0,T(i),v0_min,v0_max,W,verbose,pathprova,PBC);
end
% delete(gcp('nocreate'));

pool.delete() %removes pool at end of command

