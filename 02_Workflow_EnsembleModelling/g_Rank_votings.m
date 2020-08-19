clear
% clc
close all
tic
%%
filename = 'C:\Users\Andreas Wunsch\Workspace\01_Matlab\R_ClusterVal_stats_votingEnsemble.txt';
eva = importR_ClusterVal_stats2(filename);


load f_voting_bestFeatureConfig_resampled

%%
ranking = table;

%CH (maximise)
R = tiedrank(eva{:,1}); 
ranking{:,1} = size(eva,1)+1-R;

%MR (minimise)
ranking{:,2}=tiedrank(eva{:,2});

%PBM (maximise)
R = tiedrank(eva{:,3}); 
ranking{:,3} = size(eva,1)+1-R;

%RL (maximise)
R = tiedrank(eva{:,4}); 
ranking{:,4} = size(eva,1)+1-R;

%C(minimise)
ranking{:,5}=tiedrank(eva{:,5});

%overall ranking(minimise sum of rankings)
ranking.sum = sum(ranking{:,:},2);
ranking{:,end+1}=tiedrank(ranking{:,6});
ranking.Properties.VariableNames = {'CH','MR','PBM','RL','C','Sum','Overall_Ranking'};

%%
bestvoting_stats = eva(1,:);
ranks = ranking(1,:);

[~,I] = sort(ranking.Overall_Ranking);
ranks{1:size(I,1),1:7} = ranking{I,:};
bestvoting_stats{1:size(I,1),1:5} = eva{I,:};
ranks.order = I;

writetable(bestvoting_stats,'03_voting_stats_ordered.txt');
writetable(ranks,'03_voting_ranks_ordered.txt');

save g_workspaceEnsemble_votings_ranks
finalClustering = VoteConsensus_ensemble(:,ranks{1,end});
save('g_finalClustering','finalClustering')

toc

%%

% pause
% %%
% configs = bestconfiguration{:,:} > 0;
% AnzahlFeatures = sum(configs,2);
% figure, semilogx(AnzahlFeatures)
% grid on
% xlabel('Rang'),ylabel('Anzahl Features')
% % xlim([1 10^4])
% % print('-dpng','-r600','AnzahlFeatures_vs_Rang.png')
% %%
% figure
% spec = {'+--','-.o',':*','--s','-.d',':^','--v','-.p',':h'};
% subplot(2,1,1)
% for i = 1:size(bestconfiguration,2)
%     configs = bestconfiguration{:,:} == i;
%     y = cumsum(sum(configs,2));
%     x = 1:size(y);
%     plot(x,y,spec{i},'MarkerIndices',randi(4):2:length(y),'LineWidth',1.5)
%     hold on
%     set(gca,'FontSize',12)
%     xlim([0 10]),ylim([0 10])
%     grid on
%     xlabel('Rang'),ylabel('Kumulative Häufigkeit')
% end
% legend('Feature1','Feature2','Feature3','Feature4','Feature5','Feature6','Feature7','Feature8','Feature9','Feature10')
% legend('Location','northwest')
% hold off
% subplot(2,1,2)
% for i = 1:size(bestconfiguration,2)
%     configs = bestconfiguration{:,:} == i;
%     y = cumsum(sum(configs,2));
%     x = 1:size(y);
%     plot(x,y,spec{i},'MarkerIndices',randi(5):5:length(y),'LineWidth',1.5)
%     hold on
%     xlim([0 100]),ylim([0 100])
%     grid on
%     xlabel('Rang'),ylabel('Kumulative Häufigkeit')
%     set(gca,'FontSize',12)
%     %     legend('Feature1','Feature2','Feature3','Feature4','Feature5','Feature6','Feature7','Feature8','Feature9','Feature10')
%     %     legend('Location','northwest')
% end
% hold off
% % print('-dpng','-r600','Auftreten_Features_nach_Rang.png')
% 
% %%
% 
% figure
% t = {'CH','MR','PBM','RL','C'};
% for i = 1:5
%     subplot(2,3,i)
%     scatter(ranks{:,8},ranks{:,i},5,'x')
%     ylabel('Index Rank'), xlabel('Overall Rank')
%     axis tight, grid on
%     hline = refline; hline.Color = 'r'; hline.LineWidth = 2;
%     hline = refline(1,1); hline.Color = 'k';  hline.LineStyle = '--'; hline.LineWidth = 1.5;
%     title(t(i))
%     set(gca,'FontSize',12)
%     
%     r = corrcoef(ranks{:,8}, ranks{:,i});
%     str = sprintf(' r = %.2f',r(1,2));
%     T = text(min(get(gca, 'xlim')), max(get(gca, 'ylim')), str);
%     set(T, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'left');
% end
% % print('-dpng','-r600','IndexRang_GesamtRang.png')
% %%
% figure
% t = {'CH','DB','MR','PBM','RL','C'};
% for i = 1:6
%     subplot(2,3,i)
%     scatter(ranks{1:100,8},ranks{1:100,i},'x')
%     ylabel('Index Rank'), xlabel('Overall Rank')
%     axis tight, grid on
%     hline = refline; hline.Color = 'r'; hline.LineWidth = 2;
%     hline = refline(1,1); hline.Color = 'k';  hline.LineStyle = '--'; hline.LineWidth = 1.5;
%     title(t(i))
%     set(gca,'FontSize',12)
%     
%     r = corrcoef(ranks{1:100,8}, ranks{1:100,i});
%     str = sprintf(' r = %.2f',r(1,2));
%     T = text(min(get(gca, 'xlim')), max(get(gca, 'ylim')), str);
%     set(T, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'left');
% end
% % print('-dpng','-r600','IndexRang_GesamtRang_100.png')
%%


