%{
/*  
 *                     Copyright (C) 2016 XFastMining Lab@Huaqiao university.
 *  
 *  This source code is free to use, distribute and modify only for personal
 *  use or research. Commercial application isn't allowed without permission.
 *
 *                                      Created by Yewang Chen, Shengyu Tang,
 *                                                           XFastMining Lab,
 *                                        @Huaqiao university, Xiamen, China.
 *                                                               Nov.18,2016
 */ 
%}

function [IDX, evaluation,totalNei,countlowBound,countnoise]=DBSCAN4_modified_bi(X,radius,MinPts,disTh)
%profile on
n=size(X,1);
IDX=zeros(n,1);
C=0;
totalNei=0;countlowBound=0;countnoise=0;
visited=false(n,1);%????
isnoise=false(n,1);%????
%disTh=radius;%%%%%%%%%%%%
if nargin==3
    disTh=2;
end
filteredNoise=zeros(n,1);
normNoise=zeros(n,1);

MdlES = ExhaustiveSearcher(X);
%MdlES = KDTreeSearcher(X);
evaluation=zeros(1,2);
for i=1:n
    if visited(i)
        continue
    else
        Q=X(i,:);
        [sortLoc, sortDists] = rangesearch(MdlES,Q,radius*disTh);
        evaluation(1)=evaluation(1)+1;%%%%%%%%%%%%%%%%%%%        
        sortLoc=sortLoc{1};
        sortDists=sortDists{1};        
        if(numel(sortLoc)>MinPts)
            if(sortDists(MinPts)<radius)
                C=C+1;IDX(i)=C;
                visited(i)=true;
                clusterMember=ExpandCluster(sortLoc,sortDists,radius);
                IDX(clusterMember)=C;
                %PlotClusterinResult(X, IDX)
            else
                tmp_id= sortDists<(sortDists(MinPts)-radius);
                isnoise(sortLoc(tmp_id))=true;
                visited(sortLoc(tmp_id))=true;
                filteredNoise(sortLoc(tmp_id))=1;
                %countnoise=countnoise+length(sum(tmp_id));
            end
        else
            isnoise(i)=true;  
            normNoise(i)=true;
        end
    end
end
    normNoiseLoc=find(normNoise==1);
    filteredNoise(normNoiseLoc)=0;
    countnoise=sum(filteredNoise)
    disp( evaluation);
    sum(evaluation)+countnoise
    
    function [Neighbors]=ExpandCluster(sortLoc,sortDists,radius)
        tmp=find_halfspace_mex3(sortDists,radius);
        Neighbors=sortLoc(1:tmp-1);
        count=2;%基准点邻近点计数
        while count<length(sortLoc)
            current_p=sortLoc(count);
            if ~visited(current_p)
                visited(current_p)=true;
                current_dist=sortDists(count);
                if(current_dist<radius)%0.5*radius)%找邻居点%%%%设置的阈值？？？？？？
                    realPosOfNeib=NeighborsQuery(current_p,sortDists,sortLoc,current_dist,radius);
                    totalNei=totalNei+length(realPosOfNeib);
                     evaluation(2)=evaluation(2)+1;%%%%%%%%%%%%%%%%%%%%%%%
                    tmp=setdiff(realPosOfNeib,Neighbors);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    Neighbors=[Neighbors,tmp];
                else %从Neighbors中选出新的基准点
                    not_vis_nei= visited(Neighbors)==0;%找出Neighbors中还没被访问的点在Neighbors中的索引
                    not_vis_nei=Neighbors(not_vis_nei);%得到点的编号
                    if(isempty(not_vis_nei))
                        return
                    else                        
                        for loop=1:length(not_vis_nei)
                            Q2=X(not_vis_nei(loop),:);
                            [sortLoc, sortDists] = rangesearch(MdlES,Q2,radius*disTh);
                            evaluation(1)=evaluation(1)+1;%%%%%%%%%%%%%%%%%%%%%%%
                            sortLoc=sortLoc{1};
                            sortDists=sortDists{1};
                            count=1;%基准点邻近点计数
                            %if(sum(visited(sortLoc))~=length(not_vis_nei))%防止候选点的所有邻居点都已经被访问
                            visited(not_vis_nei(loop))=true;
                            break
                            %end
                        end
                    end
                end
            end
            count=count+1;%count>sortLoc长度？
            if(count==length(sortLoc))
                not_vis_nei= visited(Neighbors)==0;%找出Neighbors中还没被访问的点在Neighbors中的索引
                not_vis_nei=Neighbors(not_vis_nei);%得到点的编号               
                if(isempty(not_vis_nei))
                    return
                else                    
                    for loop=1:length(not_vis_nei)
                        Q2=X(not_vis_nei(loop),:);
                        [sortLoc, sortDists] = rangesearch(MdlES,Q2,radius*disTh);
                        evaluation(1)=evaluation(1)+1;%%%%%%%%%%%%%%%%%%%%%%
                        sortLoc=sortLoc{1};
                        sortDists=sortDists{1};
                        count=2;%基准点邻近点计数
                       % if(sum(visited(sortLoc))~=length(not_vis_nei))%防止候选点的所有邻居点都已经被访问
                       visited(not_vis_nei(loop))=true;
                       break
                       %end
                    end
                end
            end
            
        end
    end
    function [realPosOfNeib]=NeighborsQuery(current_p,sortDists,sortLoc,dist,radius)
        lowBound=find_halfspace_mex3(sortDists,dist-radius);%%%此时已经加入Neighbors
        countlowBound=countlowBound+1;
        upBound=find_halfspace_mex3(sortDists,dist+radius);
        possiblePointsSortedLocs=[lowBound:upBound];
        possiblePointsLoc=sortLoc(possiblePointsSortedLocs);
        possiblePoints=X(possiblePointsLoc,:) ;
        tmpDistans=pdist2(X(current_p,:),possiblePoints);
        neibors= tmpDistans<=radius;
        realPosOfNeib=possiblePointsLoc(neibors);
    end

    

%profile viewer
end

