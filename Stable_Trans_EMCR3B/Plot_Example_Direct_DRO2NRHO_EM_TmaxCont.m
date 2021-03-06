% Plot_Example_Direct_DRO2NRHO_EM.m
%
% This script plots the results of the associated script 
% Example_Direct_DRO2NRHO_EM.m which employs collocation and direct 
% optimization to compute low-thrust transfers between DRO and L1 and L2
% NRHO orbits
%
% Originally Written by: R. Pritchett, 09/23/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate number of continutation results
n_cont = numel(Z_store);

% % Preallocate matrix M for storing figure frames
% M_Traj = struct;
% M_TProf = struct;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cycle Through Continuation Results - Plot Configuration Space Results %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %---------------------------------------------------------------------%
% % Setup Configuration Space Plot %
% %---------------------------------------------------------------------%
% 
% %%% Plot Setup %%%
% ax_traj = figure;
% hold on
% grid on
% axis equal
% 
% % Define Figure size based on screen size
% screensize = get(groot,'Screensize');
% ax_traj.OuterPosition = screensize;
% 
% % Define axes limits
% xlim([49028 679597]);
% ylim([-179273 337524]);
% zlim([-277301 209008]);
% 
% % Define initial view
% % view(18,16)
% view([-32,18])
% % view(0,90) % XY Plane View
% % view(0,0) % XZ View
% % view(90,0) % YZ Plane View
% 
% %     % Plot Earth - realistic image, function from Bonnie Prado
% %     bodyplot('Textures\','Earth',r_E,-mu.*l_ch,0,0,0.9,[1 0 0],0); % create 3D surface from sphere coordinates
% 
% % Plot Moon - realistic image, function from Bonnie Prado
% bodyplot('Textures\','Moon',r_M,(1-mu).*l_ch,0,0,0.9,[1 0 0],0); % create 3D surface from sphere coordinates
% 
% % Plot Libration Points
% dx = 0.02; % text offset in x
% dy = 0.02; % text offset in y
% dz = 0.0; % text offset in z
% plot3(L(1,1).*l_ch,L(1,2).*l_ch,L(1,3).*l_ch,'sk') % plot L1
% text((L(1,1)-dx).*l_ch,(L(1,2)+dy).*l_ch,(L(1,3)+dz).*l_ch,'L_1') % plot L1
% plot3(L(2,1).*l_ch,L(2,2).*l_ch,L(2,3).*l_ch,'sk') % plot L2
% text((L(2,1)-dx).*l_ch,(L(2,2)+dy).*l_ch,(L(2,3)+dz).*l_ch,'L_2') % plot L2
% % plot3(L(3,1).*l_ch,L(3,2).*l_ch,L(3,3).*l_ch,'sk') % plot L3
% % text((L(3,1)+dx).*l_ch,(L(3,2)+dy).*l_ch,(L(3,3)+dz).*l_ch,'L_3') % plot L3
% % plot3(L(4,1).*l_ch,L(4,2).*l_ch,L(4,3).*l_ch,'sk') % plot L4
% % text((L(4,1)+dx).*l_ch,(L(4,2)+dy).*l_ch,(L(4,3)+dz).*l_ch,'L_4') % plot L4
% % plot3(L(5,1).*l_ch,L(5,2).*l_ch,L(5,3).*l_ch,'sk') % plot L5
% % text((L(5,1)+dx).*l_ch,(L(5,2)+dy).*l_ch,(L(5,3)+dz).*l_ch,'L_5') % plot L5
% 
% % Add labels to plot
% xlabel('X [km]')
% ylabel('Y [km]')
% zlabel('Z [km]')
% 
% % Plot Periodic Orbits
% plot3(Xprop_init(:,1).*l_ch,Xprop_init(:,2).*l_ch,Xprop_init(:,3).*l_ch,':k','LineWidth',1); % initial halo orbit
% plot3(Xprop_fin(:,1).*l_ch,Xprop_fin(:,2).*l_ch,Xprop_fin(:,3).*l_ch,':k','LineWidth',1); % final halo orbit
% 
% for jj = 1:n_cont
%     
%     %---------------------------------------------------------------------%
%     % Extract Results for Current Continuation Iteration %
%     %---------------------------------------------------------------------%
%     
%     Z_i = Z_store{jj};
%     x_bnd_i = x_bnd_store{jj};
%     t_bnd_i = t_bnd_store{jj};
%     t_var_i = t_var_store{jj};
%     C_i = C_store{jj};
%     colt_i = colt_store{jj};
% 
%     %---------------------------------------------------------------------%
%     % Adjust Plot Title %
%     %---------------------------------------------------------------------%
% 
%     % Add title with current max thrust level
%     title(['T_{max} = ' num2str(colt_i.Tmax_dim)]);
%     
%     %-------------------------------------------------------------------------%
%     % Process Collocation Results for Plotting %
%     %-------------------------------------------------------------------------%
% 
%     % Process direct transcription results
%     [ZPlot_fin] = Z2Plot(Z_i,x_bnd_i,t_bnd_i,t_var_i,colt_i);
% 
%     % Extract data from Z2Plot structure for plotting
%     x_bnd_plot_fin = ZPlot_fin.x_bnd_plot;
%     x_var_plot_fin = ZPlot_fin.x_var_plot;
%     u_var_fin = ZPlot_fin.u_var;
%     T_var_fin = ZPlot_fin.T_var;
%     uT_var_fin = ZPlot_fin.uT_var;
%     pos_bnd_dim_plot = ZPlot_fin.pos_bnd_dim_plot;
%     vel_bnd_dim_plot = ZPlot_fin.vel_bnd_dim_plot;
%     mass_bnd_dim_plot = ZPlot_fin.mass_bnd_dim_plot;
%     pos_var_dim_plot = ZPlot_fin.pos_var_dim_plot;
%     vel_var_dim_plot = ZPlot_fin.vel_var_dim_plot;
%     mass_var_dim_plot = ZPlot_fin.mass_var_dim_plot;
%     T_var_fin_dim = ZPlot_fin.T_var_dim; 
%     uT_var_fin_dim = ZPlot_fin.uT_var_dim; 
%     
%     %-------------------------------------------------------------------------%
%     % Plot Collocation Products in Configuration Space %
%     %-------------------------------------------------------------------------%
% 
%     % % Plot boundary nodes
% %     h1 = plot3(x_bnd_plot_fin(:,1).*l_ch,x_bnd_plot_fin(:,2).*l_ch,x_bnd_plot_fin(:,3).*l_ch,'.k','MarkerSize',8);
% 
%     % Plot initial and final boundary nodes only
%     h2 = plot3(x_bnd_plot_fin(1,1).*l_ch,x_bnd_plot_fin(1,2).*l_ch,x_bnd_plot_fin(1,3).*l_ch,'.k','MarkerSize',12);
%     h3 = plot3(x_bnd_plot_fin(end,1).*l_ch,x_bnd_plot_fin(end,2).*l_ch,x_bnd_plot_fin(end,3).*l_ch,'.k','MarkerSize',12);
% 
%     % Plot variable nodes
%     % h4 = plot3(x_var_plot_fin(:,1).*l_ch,x_var_plot_fin(:,2).*l_ch,x_var_plot_fin(:,3).*l_ch,'.b','MarkerSize',8);
%     % h5 = plot3(x_var_plot_fin(:,1).*l_ch,x_var_plot_fin(:,2).*l_ch,x_var_plot_fin(:,3).*l_ch,'b','LineWidth',2);
% 
%     % % Plot thrust vectors
%     % h6 = quiver3(x_var_plot_fin(:,1).*l_ch,x_var_plot_fin(:,2).*l_ch,x_var_plot_fin(:,3).*l_ch,...
%     %     uT_var_fin(:,1),uT_var_fin(:,2),uT_var_fin(:,3),'r'); % from indirect optimization result
% 
%     %-------------------------------------------------------------------------%
%     % Plot Results as Thrust or Coast arcs %
%     %-------------------------------------------------------------------------%
%     
%     % Define initial conditions for thrust and coast arcs
%     x_traj = ZPlot_fin.x_traj;
%     t_traj = ZPlot_fin.t_traj;
%     traj_TorC = ZPlot_fin.traj_TorC;
% 
%     % Define logical variable indicating whether coast or thrust period occurs
%     nocst = true;
%     nothrst = true;
% 
%     for ii = 1:colt_i.n_seg
% 
%         % Extract data for current trajectory segment
%         x_traj_i = x_traj{ii};
%         traj_TorC_i = traj_TorC{ii};
% 
%         % Determine whether thrust or coast arc and plot
%         scl = 100000;
%         if strcmp(traj_TorC_i,'T')
%             h7(ii) = plot3(x_traj_i(:,1).*l_ch,x_traj_i(:,2).*l_ch,x_traj_i(:,3).*l_ch,'r','LineWidth',1);
%     %         ind_arrow = floor(size(x_traj_i,1)/2);
%     %         quiver3(x_traj_i(ind_arrow,1).*l_ch,x_traj_i(ind_arrow,2).*l_ch,x_traj_i(ind_arrow,3).*l_ch,...
%     %             x_traj_i(ind_arrow,4).*scl,x_traj_i(ind_arrow,5).*scl,x_traj_i(ind_arrow,6).*scl,'r')
%             nothrst = false;
%         else
%             h8(ii) = plot3(x_traj_i(:,1).*l_ch,x_traj_i(:,2).*l_ch,x_traj_i(:,3).*l_ch,'b','LineWidth',1);
%     %         ind_arrow = floor(size(x_traj_i,1)/2);
%     %         quiver3(x_traj_i(ind_arrow,1).*l_ch,x_traj_i(ind_arrow,2).*l_ch,x_traj_i(ind_arrow,3).*l_ch,...
%     %             x_traj_i(ind_arrow,4).*scl,x_traj_i(ind_arrow,5).*scl,x_traj_i(ind_arrow,6).*scl,'b') 
%             nocst = false;
%         end
%     end
% 
% %     % Add legend
% %     if nocst
% %         legend(h7,{'Thrust'})
% %     elseif nothrst
% %         legend(h8,{'Coast'})
% %     else
% %         legend([h7 h8],{'Thrust','Coast'})
% %     end
% 
%     %---------------------------------------------------------------------%
%     % Capture Configuration Space Figure as Movie Frame %
%     %---------------------------------------------------------------------%
% 
%     % Force Matlab to generate Figure (1) immediately
%     drawnow
%     
%     % Store the frame
%     M_Traj(jj) = getframe(gcf); 
%     
% %     % Freeze x,y,z, axis limits after first iteration
% %     if jj == 1
% %         xlim manual; ylim manual; zlim manual % freeze axes to match first plot
% %     end
% 
%     % Record axis limit of each plot
%     xl_all(jj,:) = xlim; 
%     yl_all(jj,:) = ylim; 
%     zl_all(jj,:) = zlim; 
% 
%     % Now that frame has been captured delete lines from the plot
%     delete([h2,h3,h7,h8])
%     
% end % End loop through continuation results
%     
% hold off
% 
% % Determine maximum values of axes that occur in all plots
% xl_max = max(xl_all);
% xl_min = min(xl_all);
% yl_max = max(yl_all);
% yl_min = min(yl_all);
% zl_max = max(zl_all);
% zl_min = min(zl_all);
% 
% % Save movie of configuration space plot
% % v = VideoWriter('DRO2L1NRO_NoOpt_rev55_TmaxCont_1kto10_Traj.avi');
% v = VideoWriter('DRO2L2NRHO_NoOpt_rev55_n100_TmaxCont_1k210_RevGuess_Traj.avi');
% v.FrameRate = 10;
% open(v);
% writeVideo(v,M_Traj);
% close(v);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cycle Through Continuation Results - Plot Thrust Profile Results %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %---------------------------------------------------------------------%
% % Setup Configuration Space Plot %
% %---------------------------------------------------------------------%
% 
% %%% Plot Setup %%%
% ax_tprof = figure;
% hold on
% grid on
% % axis equal
% 
% % Define Figure size based on screen size
% screensize = get(groot,'Screensize');
% ax_tprof.OuterPosition = screensize;
% 
% % % Define axes limits
% % xlim([49028 679597]);
% % ylim([-179273 337524]);
% % zlim([-277301 209008]);
% 
% % Add labels to plot
% xlabel('Time [days]')
% ylabel('Thrust [N]')
% 
% for jj = 1:n_cont
%     
%     %---------------------------------------------------------------------%
%     % Extract Results for Current Continuation Iteration %
%     %---------------------------------------------------------------------%
%     
%     Z_i = Z_store{jj};
%     x_bnd_i = x_bnd_store{jj};
%     t_bnd_i = t_bnd_store{jj};
%     t_var_i = t_var_store{jj};
%     C_i = C_store{jj};
%     colt_i = colt_store{jj};
%     
%     %---------------------------------------------------------------------%
%     % Adjust Plot Title %
%     %---------------------------------------------------------------------%
% 
%     % Add title with current max thrust level
%     title(['T_{max} = ' num2str(colt_i.Tmax_dim)]);
%     
%     %-------------------------------------------------------------------------%
%     % Process Collocation Results for Plotting %
%     %-------------------------------------------------------------------------%
% 
%     % Process direct transcription results
%     [ZPlot_fin] = Z2Plot(Z_i,x_bnd_i,t_bnd_i,t_var_i,colt_i);
% 
%     % Extract data from Z2Plot structure for plotting 
%     t_var_hist = ZPlot_fin.t_var_hist;
%     T_var_hist = ZPlot_fin.T_var_hist;
%     uT_var_hist = ZPlot_fin.uT_var_hist;
%     
%     %---------------------------------------------------------------------%
%     % Plot Thrust and Specific Impulse %
%     %---------------------------------------------------------------------%
% 
%     % Create line for max thrust magnitude
%     tmax_line = colt_i.Tmax_dim.*ones(1,length(t_var_hist));
%     
%     % Plot thrust magnitude
%     h1 = plot(t_var_hist.*(t_ch/86400),T_var_hist,'k');
%     
%     % Plot thrust components
%     h2 = plot(t_var_hist.*(t_ch/86400),uT_var_hist(1,:),'b');
%     h3 = plot(t_var_hist.*(t_ch/86400),uT_var_hist(2,:),'r');
%     h4 = plot(t_var_hist.*(t_ch/86400),uT_var_hist(3,:),'g');
%     
%     % Plot max thrust line
%     h5 = plot(t_var_hist.*(t_ch/86400),tmax_line,'--r');
%     
% %     legend([h1,h2,h3,h4],{'|T|','T1','T2','T3'})
%     
%     %---------------------------------------------------------------------%
%     % Capture Configuration Space Figure as Movie Frame %
%     %---------------------------------------------------------------------%
% 
%     % Force Matlab to generate Figure (1) immediately
%     drawnow
%     
%     % Store the frame
%     M_TProf(jj) = getframe(gcf); 
%     
%     % Freeze x,y,z, axis limits after first iteration
%     if jj == 1
%         xlim manual; ylim manual; zlim manual % freeze axes to match first plot
%     end
% 
%     % Record axis limit of each plot
%     xl_all(jj,:) = xlim; 
%     yl_all(jj,:) = ylim; 
% 
%     % Now that frame has been captured delete lines from the plot
%     delete([h1,h2,h3,h4,h5])
%     
% end % End loop through continuation results
% 
% hold off
% 
% % Determine maximum values of axes that occur in all plots
% xl_max = max(xl_all);
% xl_min = min(xl_all);
% yl_max = max(yl_all);
% yl_min = min(yl_all);
% 
% % Save movie of configuration space plot
% % v = VideoWriter('DRO2L1NRO_NoOpt_rev55_TmaxCont_1kto10_TProf.avi');
% v = VideoWriter('DRO2L2NRHO_NoOpt_rev55_n100_TmaxCont_1k210_RevGuess_TProf.avi');
% v.FrameRate = 10;
% open(v);
% writeVideo(v,M_TProf);
% close(v);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Alternate Method - Use Subplots %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Plot Setup %%%
ax_Subplot = figure;

% Define Figure size based on screen size
screensize = get(groot,'Screensize');
ax_Subplot.OuterPosition = screensize;

for jj = 1:n_cont
    
    %---------------------------------------------------------------------%
    % Extract Results for Current Continuation Iteration %
    %---------------------------------------------------------------------%
    
    Z_i = Z_store{jj};
    x_bnd_i = x_bnd_store{jj};
    t_bnd_i = t_bnd_store{jj};
    t_var_i = t_var_store{jj};
    C_i = C_store{jj};
    colt_i = colt_store{jj};

    %-------------------------------------------------------------------------%
    % Process Collocation Results for Plotting %
    %-------------------------------------------------------------------------%

    % Process direct transcription results
    [ZPlot_fin] = Z2Plot(Z_i,x_bnd_i,t_bnd_i,t_var_i,colt_i);

    % Extract data from Z2Plot structure for plotting
    x_bnd_plot_fin = ZPlot_fin.x_bnd_plot;
    x_var_plot_fin = ZPlot_fin.x_var_plot;
    u_var_fin = ZPlot_fin.u_var;
    T_var_fin = ZPlot_fin.T_var;
    uT_var_fin = ZPlot_fin.uT_var;
    pos_bnd_dim_plot = ZPlot_fin.pos_bnd_dim_plot;
    vel_bnd_dim_plot = ZPlot_fin.vel_bnd_dim_plot;
    mass_bnd_dim_plot = ZPlot_fin.mass_bnd_dim_plot;
    pos_var_dim_plot = ZPlot_fin.pos_var_dim_plot;
    vel_var_dim_plot = ZPlot_fin.vel_var_dim_plot;
    mass_var_dim_plot = ZPlot_fin.mass_var_dim_plot;
    T_var_fin_dim = ZPlot_fin.T_var_dim; 
    uT_var_fin_dim = ZPlot_fin.uT_var_dim; 
    t_var_hist = ZPlot_fin.t_var_hist;
    T_var_hist = ZPlot_fin.T_var_hist;
    uT_var_hist = ZPlot_fin.uT_var_hist;
    
    %-------------------------------------------------------------------------%
    % Subplot 1 - Configuration Space %
    %-------------------------------------------------------------------------%
    subplot(1,2,1)
    hold on
    grid on
    axis equal
    
    % Add title with current max thrust level
    title(['T_{max} = ' num2str(colt_i.Tmax_dim*1000) ' [mN]']);
    
    %%% Configuration Space Subplot Setup %%%
    
    % Define axes limits
    xlim([49028 679597]);
    ylim([-179273 337524]);
    zlim([-277301 209008]);

    % Define initial view
    % view(18,16)
    view([-32,18])
    % view(0,90) % XY Plane View
    % view(0,0) % XZ View
    % view(90,0) % YZ Plane View

    %     % Plot Earth - realistic image, function from Bonnie Prado
    %     bodyplot('Textures\','Earth',r_E,-mu.*l_ch,0,0,0.9,[1 0 0],0); % create 3D surface from sphere coordinates

    % Plot Moon - realistic image, function from Bonnie Prado
    bodyplot('Textures\','Moon',r_M,(1-mu).*l_ch,0,0,0.9,[1 0 0],0); % create 3D surface from sphere coordinates

    % Plot Libration Points
    dx = 0.02; % text offset in x
    dy = 0.02; % text offset in y
    dz = 0.0; % text offset in z
    plot3(L(1,1).*l_ch,L(1,2).*l_ch,L(1,3).*l_ch,'sk') % plot L1
    text((L(1,1)-dx).*l_ch,(L(1,2)+dy).*l_ch,(L(1,3)+dz).*l_ch,'L_1') % plot L1
    plot3(L(2,1).*l_ch,L(2,2).*l_ch,L(2,3).*l_ch,'sk') % plot L2
    text((L(2,1)-dx).*l_ch,(L(2,2)+dy).*l_ch,(L(2,3)+dz).*l_ch,'L_2') % plot L2
    % plot3(L(3,1).*l_ch,L(3,2).*l_ch,L(3,3).*l_ch,'sk') % plot L3
    % text((L(3,1)+dx).*l_ch,(L(3,2)+dy).*l_ch,(L(3,3)+dz).*l_ch,'L_3') % plot L3
    % plot3(L(4,1).*l_ch,L(4,2).*l_ch,L(4,3).*l_ch,'sk') % plot L4
    % text((L(4,1)+dx).*l_ch,(L(4,2)+dy).*l_ch,(L(4,3)+dz).*l_ch,'L_4') % plot L4
    % plot3(L(5,1).*l_ch,L(5,2).*l_ch,L(5,3).*l_ch,'sk') % plot L5
    % text((L(5,1)+dx).*l_ch,(L(5,2)+dy).*l_ch,(L(5,3)+dz).*l_ch,'L_5') % plot L5

    % Add labels to plot
    xlabel('X [km]')
    ylabel('Y [km]')
    zlabel('Z [km]')

    % Plot Periodic Orbits
    plot3(Xprop_init(:,1).*l_ch,Xprop_init(:,2).*l_ch,Xprop_init(:,3).*l_ch,':k','LineWidth',1); % initial halo orbit
    plot3(Xprop_fin(:,1).*l_ch,Xprop_fin(:,2).*l_ch,Xprop_fin(:,3).*l_ch,':k','LineWidth',1); % final halo orbit

    %%% Plot Collocation Results %%%
    
    % % Plot boundary nodes
%     h1 = plot3(x_bnd_plot_fin(:,1).*l_ch,x_bnd_plot_fin(:,2).*l_ch,x_bnd_plot_fin(:,3).*l_ch,'.k','MarkerSize',8);

    % Plot initial and final boundary nodes only
    h2 = plot3(x_bnd_plot_fin(1,1).*l_ch,x_bnd_plot_fin(1,2).*l_ch,x_bnd_plot_fin(1,3).*l_ch,'.k','MarkerSize',12);
    h3 = plot3(x_bnd_plot_fin(end,1).*l_ch,x_bnd_plot_fin(end,2).*l_ch,x_bnd_plot_fin(end,3).*l_ch,'.k','MarkerSize',12);

    % Plot variable nodes
    % h4 = plot3(x_var_plot_fin(:,1).*l_ch,x_var_plot_fin(:,2).*l_ch,x_var_plot_fin(:,3).*l_ch,'.b','MarkerSize',8);
    % h5 = plot3(x_var_plot_fin(:,1).*l_ch,x_var_plot_fin(:,2).*l_ch,x_var_plot_fin(:,3).*l_ch,'b','LineWidth',2);

    % % Plot thrust vectors
    % h6 = quiver3(x_var_plot_fin(:,1).*l_ch,x_var_plot_fin(:,2).*l_ch,x_var_plot_fin(:,3).*l_ch,...
    %     uT_var_fin(:,1),uT_var_fin(:,2),uT_var_fin(:,3),'r'); % from indirect optimization result

    %%%% Plot Results as Thrust or Coast arcs %%%%
    
    % Define initial conditions for thrust and coast arcs
    x_traj = ZPlot_fin.x_traj;
    t_traj = ZPlot_fin.t_traj;
    traj_TorC = ZPlot_fin.traj_TorC;

    % Define logical variable indicating whether coast or thrust period occurs
    nocst = true;
    nothrst = true;

    for ii = 1:colt_i.n_seg

        % Extract data for current trajectory segment
        x_traj_i = x_traj{ii};
        traj_TorC_i = traj_TorC{ii};

        % Determine whether thrust or coast arc and plot
        scl = 100000;
        if strcmp(traj_TorC_i,'T')
            h7(ii) = plot3(x_traj_i(:,1).*l_ch,x_traj_i(:,2).*l_ch,x_traj_i(:,3).*l_ch,'r','LineWidth',1);
    %         ind_arrow = floor(size(x_traj_i,1)/2);
    %         quiver3(x_traj_i(ind_arrow,1).*l_ch,x_traj_i(ind_arrow,2).*l_ch,x_traj_i(ind_arrow,3).*l_ch,...
    %             x_traj_i(ind_arrow,4).*scl,x_traj_i(ind_arrow,5).*scl,x_traj_i(ind_arrow,6).*scl,'r')
            nothrst = false;
        else
            h8(ii) = plot3(x_traj_i(:,1).*l_ch,x_traj_i(:,2).*l_ch,x_traj_i(:,3).*l_ch,'b','LineWidth',1);
    %         ind_arrow = floor(size(x_traj_i,1)/2);
    %         quiver3(x_traj_i(ind_arrow,1).*l_ch,x_traj_i(ind_arrow,2).*l_ch,x_traj_i(ind_arrow,3).*l_ch,...
    %             x_traj_i(ind_arrow,4).*scl,x_traj_i(ind_arrow,5).*scl,x_traj_i(ind_arrow,6).*scl,'b') 
            nocst = false;
        end
    end

%     % Add legend
%     if nocst
%         legend(h7,{'Thrust'})
%     elseif nothrst
%         legend(h8,{'Coast'})
%     else
%         legend([h7 h8],{'Thrust','Coast'})
%     end

    %---------------------------------------------------------------------%
    % Subplot 2 - Thrust Profile %
    %---------------------------------------------------------------------%
    subplot(1,2,2)
    hold on
    grid on
    
    % Add title with current max thrust level
    title(['T_{max} = ' num2str(colt_i.Tmax_dim*1000) ' [mN]']);
    
    % Add labels to plot
    xlabel('Time [days]')
    ylabel('Thrust [mN]')
    
    % Define axes limits
%     xlim([49028 679597]);
    ylim([0 500]);
    
   % Create line for max thrust magnitude
    tmax_line = colt_i.Tmax_dim.*ones(1,length(t_var_hist));
    
    % Plot thrust magnitude
    h9 = plot(t_var_hist.*(t_ch/86400),T_var_hist*1000,'k','LineWidth',2);
    
    % Plot thrust components
    h10 = plot(t_var_hist.*(t_ch/86400),uT_var_hist(1,:)*1000,'b');
    h11 = plot(t_var_hist.*(t_ch/86400),uT_var_hist(2,:)*1000,'r');
    h12 = plot(t_var_hist.*(t_ch/86400),uT_var_hist(3,:)*1000,'g');
    
    % Plot max thrust line
    h13 = plot(t_var_hist.*(t_ch/86400),tmax_line*1000,'--r','LineWidth',2);
    
%     legend([h1,h2,h3,h4],{'|T|','T1','T2','T3'})
 
    %---------------------------------------------------------------------%
    % Capture Subplot as Movie Frame %
    %---------------------------------------------------------------------%

    % Force Matlab to generate Figure (1) immediately
    drawnow
    
    % Store the frame
    M_Subplot(jj) = getframe(gcf); 
    
%     % Freeze x,y,z, axis limits after first iteration
%     if jj == 1
%         xlim manual; ylim manual; zlim manual % freeze axes to match first plot
%     end

    % Now that frame has been captured delete lines from the plot
    delete([h2,h3,h7,h8,h9,h10,h11,h12,h13])
    
end % End loop through continuation results
    
hold off

% Save movie of configuration space plot
% v = VideoWriter('DRO2L1NRO_NoOpt_rev55_TmaxCont_1kto10_TProf.avi');
v = VideoWriter('DRO2L2NRHO_NoOpt_rev55_n100_TmaxCont_1k210_Subplot.avi');
v.FrameRate = 10;
open(v);
writeVideo(v,M_Subplot);
close(v);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Package Data for Export to Other Users %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Rename variables for export
% X_ppt = x_bnd_plot_fin;
% T_ppt = t_bnd;

% save('DRO2L1NRHO_OptwColl_rev11_Tmax10_n60_Export_BndPts','mu','X_init',...
%     'T_init','X_fin','T_fin','X_ppt','T_ppt')
