re=[];
t1=[];t2=[];
c1=[];c2=[];
ID1=[];
ID2=[];

eps=[2000];
minP=[1000];


for n=1:8%5000:5000:50000%:10000%16:2:20%1:20  %µãÊý
   tic;
   [IDX1, evaluation]=DBSCAN4_modified_bi(a(1:10000*n,:),epsilon,MinPts,gridsSet_10{n});
   toc
end