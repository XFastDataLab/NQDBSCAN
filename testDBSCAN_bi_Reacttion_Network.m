timer1=0;
for i=1:10 
    tic;
    tmpLen=floor(i*length(reaction_network_norm_int)/10);
    [IDX1, evaluation]=DBSCAN4_modified_bi(tmp3(1:tmpLen,:),1000,100,gridSets_tmp_10{i});
    tim=toc;
    timer1(i)=tim
end

% timer2=0;
% for i=1:10 
%     tic;
%     tmpLen=floor(i*length(reaction_network_norm_int)/10);
%     [IDX1, evaluation]=DBSCAN4_modified_bi_V3(tmp3(1:tmpLen,:),3000,100);
%     tim=toc
%     timer2(i)=tim;
% end