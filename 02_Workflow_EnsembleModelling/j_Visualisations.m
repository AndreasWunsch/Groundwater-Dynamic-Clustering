clear
% clc
close all

%% load data
load d_workspace_SOM_featuredata_member.mat
load g_finalClustering.mat

%% Bar Plot: hits per Cluster
no = max(finalClustering);
for i = 1:no
   hit_counts(i) = sum(finalClustering == i); 
end

fig = figure('Position', [300 300 1300 500]);
b=bar(hit_counts); b.FaceColor = 'flat';
grid on, title('Cluster sizes'); xlabel('Cluster'), ylabel('Size')
barvalues;
set(gca,'FontSize',14);
print('-dpng','-r500','0_1_Cluster_hits.png')

%% boxplots
fig = figure('Position', [10 10 1900 980]);
f_no = size(features,2);

for i=1:f_no %loop each feature
    
    M=nan(max(hit_counts),no);
    for ii=1:no %loop each cluster
        idx= finalClustering == ii;
        cluster_boxdata=features(idx,i);
        M(1:length(cluster_boxdata),ii)=cluster_boxdata;
    end
    
    %deterine subplot number and layout
    if no <= 40
        if f_no <= 3
            subplot(1,f_no,i)
        elseif f_no == 4
            subplot(2,2,i)
        elseif f_no <= 6
            subplot(2,3,i)
        elseif f_no <= 8
            subplot(2,4,i)
        elseif f_no == 9
            subplot(3,3,i)
        elseif f_no <= 10
            subplot(2,5,i)
        elseif f_no <= 12
            subplot(3,4,i)
        end
    else
        fig = figure('Position', [13,349,1895,615]);
    end
    
    %-----------------
    bp=boxplot(M);
    %-----------------
    set(bp,'Linewidth',1);
    
    xlabels = get(gca,'xticklabel');
    if no>15 && no < 30
        for iii = 2:2:no
            xlabels{iii}='';
        end
        set(gca,'xticklabels',xlabels);
        grid on
    elseif no > 30
        for iii = 1:no
            xlabels{iii}='';
        end
        xlabels{1}='1';
        for iii = 10:10:no
            xlabels{iii}=string(iii);
        end
        set(gca,'xticklabels',xlabels);
        grid on        
    end
    
    set(gca,'FontSize',12)
    xlabel('Cluster')
    %     ylabel(boxplotylabels(i))
    title(feature_names(i))
    axis tight
    
    if no > 40
        print('-dpng','-r300',sprintf('0_21_Feature box plots_F%d',i)) %save boxplot graphics
        savefig(fig,sprintf('0_22_Feature box plots_F%d',i),'compact')
    end
    
end
if no <= 40
    print('-dpng','-r300','0_2_Feature box plots') %save boxplot graphics
    savefig(fig,'0_2_Feature box plots','compact')
end
clear boxplotylabels bp M idx i ii text
