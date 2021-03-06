function [grad] = DrctTrans_ObjGrad_MaxMf(Z,colt,collmat)
% function [grad] = DrctTrans_ObjGrad_MaxMf(Z,colt,collmat)
% 
% This function computes the gradient of the objective function employed in 
% an optimization algorithm. Specifically this function is intended to be
% used when the objective function is defined so that the final mass of a 
% spacecraft is maximized. This function assumes that the only nonzero
% partials of the objective function will be with respect to the variables
% in the final segment of the collocation discretization. Therefore, these
% partials are computed by complex step differentiation and all other
% partials are automatically set to equal zero.
%
% INPUTS:
%    Z        design variable vector (n_coast+(n_state+n_cntrl+n_slack)*n_seg*(N+1)/2 x 1)
%    colt     structure containing collocation and optimization parameters
%    collmat    structure containing constant collocation matrices
%
% OUTPUTS:
%    grad     gradient of the objective function employed by the optimization algorithm
%
% Written by R. Pritchett, 6/07/16
% Last Update: R. Pritchett, 10/01/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup %%

% Extract necessary parameters from colt stucture
N = colt.N;
n_seg = colt.n_seg;
n_state = colt.n_state;
n_cntrl = colt.n_cntrl;
n_slack = colt.n_slack;

% Extract necessary parameters from collmat stucture
t_seg = collmat.t_seg;
t_seg_d = collmat.t_seg_d;

% Calculate length of design vector
Zl = length(Z);

% Convert column vector of design variables to 3D matrices
[~,xis,uis,~,~,l] = Z23D(Z,colt);

% Set step size for complex step differentiation
stpsz = 1e-100; 

% Preallocate matrices of partial derivatives for collocation constraints
Dmf = zeros(l,1);

% Preallocate perturbation matrices
u_pert = zeros(n_cntrl,(N+1)/2,n_seg);
x_pert = zeros(n_state,(N+1)/2,n_seg);

% Initialize iteration counter
count = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compute Partials of Objective wrt Control and Slack Variables in Final Segment %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------%
% Loop Through Control Design Variable Nodes %
%-----------------------------------------------------------------%
for ii = 1:n_cntrl
    
    % Iterate iteration counter
    count = count + 1;
    
    % Simultaneously perturb 1 state of 1 variable node in all segments
    u_pert(ii,:,:)=1i*stpsz; % complex step

    % Add perturbation to variable node states
    uis_p=uis+u_pert;

    %Compute continuity and defect constraints with perturbed uis
    [~,~,~,xf_p,~] = Con_Defect(xis,uis_p,t_seg,t_seg_d,collmat,colt);

    % Compute Collocation Constraint Partials
    Dmf(count,:) = -imag(xf_p(n_state,:,end))/stpsz;

    u_pert=0*u_pert; % reset perturbation matrix
                         
end % end control variable loop

%-----------------------------------------------------------------%
% Loop Through Slack Design Variable Nodes %
%-----------------------------------------------------------------%
for ii = 1:n_slack
    
    % Iterate iteration counter
    count = count + 1;
    
    % Slack variable constraint partials will equal zero
    Dmf(count,:) = 0;

end % end slack variable loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compute Partials of Objective wrt State Variables in Final Segment %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------%
% Loop Through Variable Nodes %
%-----------------------------------------------------------------%
for jj = 1:(N+1)/2 % loop through variable nodes
    
    %-----------------------------------------------------------------%
    % Loop Through Design Variables at Each Variable Node %
    %-----------------------------------------------------------------%
    for ii = 1:n_state % loop through design variables 
    
        count = count + 1;
    
        % Simultaneously perturb 1 state of 1 variable node in all segments
        x_pert(ii,jj,:)=1i*stpsz; % complex step 

        %Add perturbation to variable node states
        xis_p=xis+x_pert;

        %Compute continuity and defect constraints with perturbed uis
        [~,~,~,xf_p,~] = Con_Defect(xis_p,uis,t_seg,t_seg_d,collmat,colt);

        % Compute Collocation Constraint Partials
        Dmf(count,:) = -imag(xf_p(n_state,:,end))/stpsz;

        x_pert=0*x_pert; % reset perturbation matrix
        
    end % end design variable loop
    
end % end variable node loop
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Add Partials Equal to Zero to Gradient Vector %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Note: This is necessary because the final mass only has partials wrt the 
% design variables in the final segment

grad = [zeros(Zl-l,1); Dmf];
 