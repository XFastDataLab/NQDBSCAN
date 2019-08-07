
for i=1:5
    count=1;
    for j=1:3
        t1=clock;
        DBSCAN4_modified_bi(a,i*1000,j*10,tree);
        t2=etime(clock,t1);
        timer(i,count)=t2;
        count=count+1;
    end
    
    for j=1:3
        t1=clock;
        DBSCAN4_modified_bi(a,i*1000,j*100,tree);
        t2=etime(clock,t1);
        timer(i,count)=t2;
        count=count+1;
    end
    
end
