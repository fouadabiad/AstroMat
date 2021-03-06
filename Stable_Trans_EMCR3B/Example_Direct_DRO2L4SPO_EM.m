% Example_Direct_DRO2NRHO_EM.m
%
% This script uses collocation and direct optimization to compute 
% low-thrust transfers between periodic DRO orbits and L1 or L2 NRHO orbits
%
% Originally Written by: R. Pritchett, 01/11/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;clear;clc;

%% Set Constants %%

%Call script that calculates useful CR3BP constants
CR3BPConst_EM

% Define collocation and optimization parameter structure
colt = struct;

% Save CR3BP constant parameters in structure 
colt.mu = mu; % gravitational 
colt.l_ch = l_ch; % characteristic length
colt.t_ch = t_ch; % characteristic time
colt.L = L; % libration point position coordinates 
colt.g0 = g0; % acceleration due to gravity on the surface of the Earth (necessary to compute exhaust velocity)
colt.phi0 = phi0; % initial phi matrix
colt.psi0 = psi0; % initial psi matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User Inputs %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Spacecraft Inputs %%%
colt.m0_dim = 500; % [kg] initial s/c mass
% colt.Pmax_dim = 2000; % [W] maximum s/c power
colt.Isp_dim = 2000; % [s] s/c specific impulse
colt.ce_dim = colt.Isp_dim*colt.g0; % [m/s] s/c effective exhaust velocity
colt.Tmax_dim = 0.1; % [N] maximum s/c thrust
colt.lambda_m0 = 1; % [nondimensional] initial guess for mass costate

%%% Numerical Integration Options %%%
RelativeTol = 1e-12; % relative integration tolerance
AbsoluteTol = 1e-12; % absolute integration tolerance
colt.options = odeset('RelTol',RelativeTol,'AbsTol',AbsoluteTol);
colt.atten_tol = 1e-4; % tolerance for attenation factor
colt.atten = 1; % attenuation factor for Newton's method step size 1/atten

%%% Shooting Inputs %%%
colt.StpOff = 50/l_ch; % [nondimensional] manifold stepoff distance, format x (in km)/l_ch
colt.PorM = {{'minus'}, {'plus'}}; % define manifold stepoff direction for initial and final manifolds
colt.newt_tol = 1e-8; % tolerance for Newton's Method
colt.max_iter = 2000; % maximum iterations allowed before calculation terminates
colt.DiffType = 'Forward'; % finite difference method for numerical jacobian

%%% Collocation Inputs %%%
colt.N = 7; % degree of polynomials
colt.n_seg_revi = 40; % number of segments for initial orbit revs
colt.n_seg_revf = 40; % number of segments for final orbit revs
colt.n_seg = colt.n_seg_revi+colt.n_seg_revf; % initial number of segments
colt.n_state = 7; % number of state variables
colt.n_cntrl = 4; % number of control variables
colt.n_slack = 2; % number of slack variables
colt.n_coast = 0; % number of coasting/phasing parameters
colt.NodeSpace = 'LG'; % specify node spacing for polynomial interpolation

%%% Boundary Constraints %%%
% x0_des_ch = {{'fix'},{'fix'},{'fix'},{'fix'},{'fix'},{'fix'},{'fix'}};
x0_des_ch = {{'fix'},{'fix'},{'fix'},{'fix'},{'fix'},{'fix'},{'fix'}};
% xf_des_ch = {{'free'},{'free'},{'free'},{'free'},{'free'},{'free'},{'free'}};
xf_des_ch = {{'fix'},{'fix'},{'fix'},{'fix'},{'fix'},{'fix'},{'free'}};
[x0_des_ind,xf_des_ind] = FixBndInd(x0_des_ch,xf_des_ch);  % calculate indices of fixed components
colt.x0_des_ind = x0_des_ind; % indices of fixed components of initial endpoint
colt.xf_des_ind = xf_des_ind; % indices of fixed components of final endpoint

%%% Mesh Refinement Inputs %%%
colt.Mesh = 'CEP'; % CEP mesh refinement method used
% colt.Mesh = 'NoMesh'; % no mesh refinement used
% colt.Mesh = 'deBoor'; % de Boor mesh refinement method used

%%% de Boor Mesh Refinement Tolerances %%%
colt.ctol = 1e-8; % max error tolerance for de Boor method
colt.Dec = 2; % number of decimal places to examine in error distribution check
colt.maxdiffe = 100; % maximum difference between decimal places allowed in error distribution check

%%% CEP Mesh Refinement Tolerances %%%
colt.rem_tol = 1e-10; % Max error magnitude allowed for segment removal loop
colt.add_tol = 1e-10; % Min error magnitude allowed for segment addition loop

%%% Optimization Inputs %%%
% Note: optimization options defined within DirectTrans_InEq.m function
colt.opt_max_fevals = 1000000; % maximum number of function evaluations permitted before optimization algorithm terminates
colt.opt_max_iter = 10000; % maximum number of iterations permitted before optimization algorithm terminates
colt.OptMeth = 'NoOpt'; % no optimization method used
% colt.OptMeth = 'fmincon'; % fmincon optimization method used
% colt.OptMeth = 'IPOPT'; % IPOPT optimization method used

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Nondimensionalize User Inputs %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

colt.m_ch = colt.m0_dim; % override typical CR3BP characteristic mass and set as s/c mass
colt.m0 = colt.m0_dim/colt.m_ch; % [nondimensional]
% colt.Pmax = colt.Pmax_dim*(colt.t_ch^3/((1000*colt.l_ch)^2*colt.m_ch)); % [nondimensional]
colt.Isp = colt.Isp_dim/t_ch;
colt.ce = colt.ce_dim.*(t_ch/(l_ch*1000));
colt.Tmax = colt.Tmax_dim*(colt.t_ch^2/(1000*colt.l_ch*colt.m_ch)); % [nondimensional]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Data and Propagate Initial and Final Periodic Orbits %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Import L1 NRHO and DRO orbits selected for transfer
load EM_DRO_2_L4SPO
x0_spo = x0_spo_slct;
tf_spo = tf_spo_slct;
x0_dro = x0_dro_slct;
tf_dro = tf_dro_slct;

% Combine initial and final orbit IC into single vector
X_init = x0_dro;
T_init = tf_dro;
dro_revs = 3;
X_fin = x0_spo;
T_fin = tf_spo;
spo_revs = 2;

% Calculate total transfer time
T_trans = T_init*dro_revs + T_fin*spo_revs;
T_trans_dim = T_trans*t_ch/86400;

% Combine initial and final orbit IC into single vector
colt.OrbIC = [X_init,T_init,X_fin,T_fin];

% Save number of initial and final orbit revs used in initial guess
colt.n_rev = [dro_revs spo_revs];

% Propagate initial Lyap orbit
[Xprop_init,Tprop_init,V_mono_init] = PeriodicProp(colt.OrbIC(1:7),colt);
V_mono(:,:,1) = V_mono_init; % save monodromy matrix of initial orbit

% Propagate final Lyap orbit
[Xprop_fin,Tprop_fin,V_mono_fin] = PeriodicProp(colt.OrbIC(8:14),colt);
V_mono(:,:,2) = V_mono_fin; % save monodromy matrix of final orbit
colt.V_mono = V_mono; % save monodromy matrices in colt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Discretize Initial Guess %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Discretize initial guess
[Z0,t_var,t_bnd,xis_bnd,xis_plot,uis_plot] = RevWrap_Discrt(colt);

% Save initial and final boundary nodes of initial guess
colt.x0_des = [colt.OrbIC(1:6) 1];
colt.xf_des = [colt.OrbIC(8:13) 1];

% %%% Test Plot Setup %%%
% figure(1)
% hold on
% grid on
% axis equal
% 
% % Define initial view
% % view(18,16)
% view([-32,18])
% % view(0,90)
% 
% % Plot Moon - realistic image, function from Bonnie Prado
% bodyplot('Textures\','Moon',r_M,(1-mu).*l_ch,0,0,0.9,[1 0 0],0); % create 3D surface from sphere coordinates
% 
% % Plot Libration Points
% plot3(L(1,1).*l_ch,L(1,2).*l_ch,L(1,3).*l_ch,'sk') % plot L1
% plot3(L(2,1).*l_ch,L(2,2).*l_ch,L(2,3).*l_ch,'sk') % plot L2
% 
% % Add labels to plot
% xlabel('X [km]')
% ylabel('Y [km]')
% zlabel('Z [km]')
% 
% % Plot Periodic Orbits
% plot3(Xprop_init(:,1).*l_ch,Xprop_init(:,2).*l_ch,Xprop_init(:,3).*l_ch,':k','LineWidth',1); % initial halo orbit
% % plot3(Xprop_init(1,1).*l_ch,Xprop_init(1,2).*l_ch,Xprop_init(1,3).*l_ch,'ok','MarkerSize',8); % initial halo orbit
% plot3(Xprop_fin(:,1).*l_ch,Xprop_fin(:,2).*l_ch,Xprop_fin(:,3).*l_ch,':k','LineWidth',1); % final halo orbit
% % plot3(Xprop_fin(1,1).*l_ch,Xprop_fin(1,2).*l_ch,Xprop_fin(1,3).*l_ch,'ok','MarkerSize',8); % final halo orbit
% 
% % % Plot full transfer 
% plot3(xis_bnd(1,:).*l_ch,xis_bnd(2,:).*l_ch,xis_bnd(3,:).*l_ch,'+k','MarkerSize',8);
% plot3(xis_plot(1,:).*l_ch,xis_plot(2,:).*l_ch,xis_plot(3,:).*l_ch,'.b','MarkerSize',8)
% plot3(xis_plot(1,1).*l_ch,xis_plot(2,1).*l_ch,xis_plot(3,1).*l_ch,'.g','MarkerSize',12)
% plot3(xis_plot(1,end).*l_ch,xis_plot(2,end).*l_ch,xis_plot(3,end).*l_ch,'.r','MarkerSize',12)
% 
% % % Plot trajectory as line with color gradient that is a function of time
% % x = xis_plot(1,:).*l_ch;
% % y = xis_plot(2,:).*l_ch;
% % z = xis_plot(3,:).*l_ch;
% % c = 1:numel(t_var); % # colors
% % h = surface([x(:), x(:)], [y(:), y(:)], [z(:), z(:)], ...
% %     [c(:), c(:)], 'EdgeColor','flat', 'FaceColor','none','linew',2);
% % colormap( flipud(jet(numel(t_var))) )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Solve Collocation Problem before Direct Transcription %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Z,x_bnd,t_var,t_bnd,C,colt] = DirectTrans(Z0,t_bnd,t_var,colt);

% Save or load collocation result
% save('DRO2L4SPO_NoOpt_n80_N7','Z','x_bnd','t_var','t_bnd','C','colt')
% load DRO2L4SPO_NoOpt_n80_N7

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Modify Collocation Output and Settings to Run Direct Transcription Algorithm %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % If skipping initial collocation step then define Z=Z0
% Z = Z0;

% Remove slack variables from Z
[~,xis,uis,~,~,~] = Z23D(Z,colt);

% Calculate number of variable nodes per segment without slack variables
l = colt.n_state*(colt.N+1)/2 + colt.n_cntrl;

% Preallocate matrices
Z_mat = zeros(l,colt.n_seg);
lb_mat = zeros(l,colt.n_seg);
ub_mat = zeros(l,colt.n_seg);

for ii = 1:colt.n_seg
    
    % Define state, control, and slack variable for current segment
    xis_var_i = xis(:,:,ii);
    uis_var_i = uis(:,1,ii);
    
    % Formulate single column for Z_mat
    x_col = reshape(xis_var_i,[colt.n_state*(colt.N+1)/2 1]);
    Z_mat(:,ii) = [uis_var_i; x_col];
    
    % Formulate lower and upper bounds on state variables
    lb_mat(:,ii) = [0;-Inf.*ones(3,1); -Inf.*ones(colt.n_state*(colt.N+1)/2,1,1)];
    ub_mat(:,ii) = [colt.Tmax;Inf.*ones(3,1); Inf.*ones(colt.n_state*(colt.N+1)/2,1,1)];
      
end

% Reshape Z_mat into column vector
Z0 = reshape(Z_mat,[l*colt.n_seg 1]);
colt.lb_Z = reshape(lb_mat,[l*colt.n_seg 1]);
colt.ub_Z = reshape(ub_mat,[l*colt.n_seg 1]);

% Define number of slack variables to be zero
colt.n_slack = 0;

% Define mesh refinement method for direct transcription
% colt.Mesh = 'CEP'; % CEP mesh refinement method used
colt.Mesh = 'NoMesh'; % no mesh refinement used
% colt.Mesh = 'deBoor'; % de Boor mesh refinement method used

% Define optimization method for direct transcription
% Note: optimization options defined within DirectTrans_InEq.m function
colt.opt_max_fevals = 1000000; % maximum number of function evaluations permitted before optimization algorithm terminates
colt.opt_max_iter = 10000; % maximum number of iterations permitted before optimization algorithm terminates
% colt.OptMeth = 'NoOpt'; % no optimization method used
colt.OptMeth = 'fmincon'; % fmincon optimization method used
% colt.OptMeth = 'IPOPT'; % IPOPT optimization method used
 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Run Direct Transcription Algorithm %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Z,x_bnd,t_var,t_bnd,C,colt] = DirectTrans(Z0,t_bnd,t_var,colt);

% Save or load direct transcription result
% save('DRO2L4SPO_OptTrans_n80_N7','Z','x_bnd','t_var','t_bnd','C','colt')
% load DRO2L4SPO_OptTrans_n80_N7

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Process Results and Run Plotting Script %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ss

% Run plotting script
run('Plot_Example_Direct_DRO2L4SPO_EM')
