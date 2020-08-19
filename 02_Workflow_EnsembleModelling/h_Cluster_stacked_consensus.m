close all
clear
warning('off','all');

%% configuration

savefigures = "Yes"; %save figures
% savefigures = ""No"; %create but do not save figures

xscaling = "Yes"; %same time scale boundaries for every figure
% xscaling = "No"; %automatic time scale limit

z_trans = "Yes"; %mean shift (stacking) and z-scoring
% z_trans = "No"; %only mean shift, no z-scoring

pos=[1,41,1536,748]; %size and position of figures

%% load data
load('d_workspace_SOM_featuredata_member','features','data','data_weekly','feature_names','HyraumID');
load g_finalClustering

%% some necessary stuff
clusternumbers_of_samples = finalClustering;
no = max(clusternumbers_of_samples);
sD = som_data_struct(features);
sData = som_normalize(sD,'var'); %Z-score

%% indices per cluster - ipc
ipc = struct('sample_indices',{});
for i=1:no %loop each cluster
    idx=find(clusternumbers_of_samples==i);
    ipc(i).sample_indices=idx;
end

%%
dat = data_weekly{:,2:end};
for k=1:no %every cluster
    if isempty(ipc(k).sample_indices) == 0
        %%%%%%%%%%%%% calculate mean weighted intra cluster correlations
        idx=ipc(k).sample_indices;
        c = dat(:,idx);
        [R,P,RL,RU] = corrcoef(c,'Rows','pairwise'); %Omit any rows containing NaN only on a pairwise basis for each two-column correlation coefficient calculation. This option can return a matrix that is not positive semi-definite.
        % extract significant values
        sig = P > 0.05;
        R_sig = R; R_sig(sig) = NaN; %remove non significant relations
        R_sig = R.*(1-P); %use significancy for weighting
        %mean R values
        R_mean = nanmean(R_sig);
        R_mean = R_mean';
        %%%%%%%%%
        [~,sorting]=sort(R_mean,'descend');%
        
        cl=table;
        cl.dates=data_weekly.dates;
        cl_unstacked=table;
        cl_unstacked.dates=data_weekly.dates;
        
        %%%%%%%%%%%%%
        r_sort = R_mean(sorting,1);
        %%%%%%%%%%%%%
        
        %stack the data
        for i=1:length(idx)
            ii=idx(i)+1;
            if z_trans == "No"
                s=1;
            elseif z_trans == "Yes"
                s=nanstd(data_weekly.(ii));
            end
            m=nanmean(data_weekly.(ii));
            cl.(i+1)=((data_weekly.(ii)-m)/s)+2*i; %z-transformed + shift
            ordinate(i,1)=2*i;
            cl_unstacked.(i+1)=((data_weekly.(ii)-m)/s); %z-transformed without shift
        end
        
        %% do plotting
        p_max = ceil(length(idx)/50);
        idx_master=idx;
        for p = 1:p_max
            if p <= p_max
                fig=figure('Position', pos);
                cm = viridis(length(idx_master)*1.1);cm = cm(1:length(idx_master),:); %low contrast area capped
                if p*50 < length(idx_master) && (p+1)*50 <= length(idx_master)%plot large clusters piecewise (steps of 50)                  
                    scaleplus=0;
                    idx=idx_master(p*50-49:p*50); maxi=p*50; mini = p*50-49;
                elseif p*50 <= length(idx_master) && (p+1)*50 > length(idx_master)
                    if p*50+5 > length(idx_master) %if next plot would contain less than 5, include in this plot
                        idx=idx_master(p*50-49:end); maxi=length(idx_master); mini = p*50-49;
                        scaleplus=maxi-p*50;
                        p_max=p;
                    else
                        scaleplus=0;
                        idx=idx_master(p*50-49:p*50); maxi=p*50; mini = p*50-49;
                    end
                elseif p*50 > length(idx_master)
                    idx=idx_master(p*50-49:end); maxi=length(idx_master); mini = p*50-49;
                    scaleplus=0;
                end
                
                subplot(1,20,[1:19])
                for i=p*50-48:maxi+1
                    colorindex = round(i*(size(cm,1)/length(idx_master)));
                    if colorindex == 0
                        colorindex = 1;
                    elseif colorindex > size(cm,1)
                        colorindex = size(cm,1);
                    end
                    %----------------------------------------------------------
                    plot(cl.(1),cl.(i),'Linewidth',1.2,'Color',cm(colorindex,:)) %Plot Groundwater levels with colormap
                    %plot(cl.(1),cl.(i),'Linewidth',1.2) %Plot Groundwater levels withOUT colormap
                    %----------------------------------------------------------
                    hold on
                end
                
                %save figures
                if z_trans == "Yes"
                    if k == merge_cl
                        title(sprintf('Cluster %dX: stacked, z-transf. Groundwater Timeseries',k));
                    else
                        title(sprintf('Cluster %d: stacked, z-transf. Groundwater Timeseries',k));
                    end
                elseif z_trans == "No"
                    if k == merge_cl
                        title(sprintf('Cluster %dX: stacked Groundwater Timeseries',k));
                    else
                        title(sprintf('Cluster %d: stacked Groundwater Timeseries',k));
                    end
                end
                
                xlabel('Date')
                set(gca,'FontSize',16);set(gca,'YTick',[]);
                axis tight
                ylim([2*p*50-106 2*p*(50+scaleplus)+6]) %smaller spacing
                %             ylim([2*p*50-110 2*p*50+10]) %bigger spacing
                lim=get(gca,'ylim');
                
                if xscaling == "Yes"
                    xlim([data_weekly{1,1} data_weekly{end,1}])
                else
                    %nothing
                end
                
                %minimize whitespace for printing/saving
                ax = gca; outerpos = ax.OuterPosition; ti = ax.TightInset;
                left = outerpos(1) + ti(1);
                bottom = outerpos(2) + ti(2);
                ax_width = outerpos(3) - ti(1) - ti(3);
                ax_height = outerpos(4) - ti(2) - ti(4);
                ax.Position = [left bottom ax_width ax_height];
                
                % plot bars at the far right (mean intra cluster
                % correlations)
                subplot(1,20,20)
                ordinate_split=ordinate(mini:maxi);
                dist_sort_split=r_sort(mini:maxi);
                barh(ordinate_split,dist_sort_split,'FaceColor','flat','CData',cm(mini:maxi,:))
                grid on
                set(gca,'FontSize',14,'YTick',[],'ylim',lim);
                xlim([0 1])
                xlabel("$\overline{R_{w}}$",'Interpreter','latex')
                hold on
                
                linx1=max(r_sort);
                liny=get(gca,'ylim');
                plot([linx1 linx1],liny,'r');
                format short
                text(linx1,mean(liny),sprintf('  max = \n  %0.2f\n',linx1));
                hold off
                dim = [0.043626315789474,0.965591397849462,0.080057894736842,0.025172043010753];
                str = sprintf('n = %d (%d to %d)',length(idx_master),mini,maxi);
                annotation('textbox',dim,'String',str,'FitBoxToText','on','Margin',3);
                
                %minimize whitespace for printing/saving
                ax = gca;outerpos = ax.OuterPosition; ti = ax.TightInset;
                left = outerpos(1) + ti(1); ax.Position = [left,bottom,0.1,ax_height];
                
                %% saving
                if savefigures == "Yes"
                    if k == merge_cl
                        print('-dpng','-r300',sprintf('Cluster_%dX_%d_stacked.png',k,p));
                        % savefig(fig,sprintf('Fig_Cluster_%dX_%d_stacked',k,p),'compact')
                    else
                        print('-dpng','-r300',sprintf('Cluster_%d_%d_stacked.png',k,p));
                        % savefig(fig,sprintf('Fig_Cluster_%d_%d_stacked',k,p),'compact')
                    end
                    
                end
                hold off
            end %end while
        end%%
        clear t idx idx2 i ii m s center ordinate dist_sort lawa_cl_position gaps small high
        
    end
end

if savefigures == "Yes"
    close all
end
