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
function [IDX, evaluation]=DBSCAN4_modified_bi(X,radius,MinPts,tree,disTh)
%profile on
n=size(X,1);
IDX=zeros(n,1);
C=0;
visited=false(n,1);%????
isnoise=false(n,1);%????
filteredNoise=zeros(n,1);
%disTh=radius;%%%%%%%%%%%%
if nargin==4
    disTh=2;
end

%MdlES = ExhaustiveSearcher(X);
%MdlES = KDTreeSearcher(X);




points=X;
distMetric='Euclidean';
[x,dim]=size(points);

evaluation=zeros(1,2);
for i=1:n
    if visited(i)
        continue
    else
        nei=gridNeigbors(tree,X,i,radius); 
        nei=cell2mat(nei);

        tmpdist=pdist2(X(i,:),X(nei,:));
        [sortDists,tmpLoc]=sort(tmpdist);
        sortLoc=nei(tmpLoc);

        if(numel(sortLoc)>MinPts)
            if(sortDists(MinPts)<radius)
                C=C+1;IDX(i)=C;
                visited(i)=true;
                clusterMember=ExpandCluster(sortLoc,sortDists,radius);
                IDX(clusterMember)=C;
                %PlotClusterinResult(X, IDX)
            else
                tmp_id= sortDists<sortDists(MinPts)-radius;
                isnoise(sortLoc(tmp_id))=true;
            end
        else
            isnoise(i)=true;
        end
    end
end
    function [Neighbors]=ExpandCluster(sortLoc,sortDists,radius)
        tmp=find_halfspace_mex3(sortDists,radius);
        Neighbors=sortLoc(1:tmp-1);
        count=2;%��׼���ڽ������
        while count<length(sortLoc)
            current_p=sortLoc(count);
            if ~visited(current_p)
                visited(current_p)=true;
                current_dist=sortDists(count);
                if(current_dist<0.5*radius)%���ھӵ�%%%%���õ���ֵ������������
                    realPosOfNeib=NeighborsQuery(current_p,sortDists,sortLoc,current_dist,radius);
                    evaluation(2)=evaluation(2)+1;%%%%%%%%%%%%%%%%%%%%%%%
                    tmp=setdiff(realPosOfNeib,Neighbors);
                          
                    Neighbors=[Neighbors,tmp];
                else %��Neighbors��ѡ���µĻ�׼��
                    not_vis_nei= visited(Neighbors)==0;%�ҳ�Neighbors�л�û�����ʵĵ���Neighbors�е�����
                    not_vis_nei=Neighbors(not_vis_nei);%�õ���ı��
                    if(isempty(not_vis_nei))
                        return
                    else                        
                        for loop=1:length(not_vis_nei)
                            nei=gridNeigbors(tree,X,not_vis_nei(loop),radius*disTh); 
                            nei=cell2mat(nei);
                            tmpdist=pdist2(X(not_vis_nei(loop),:),X(nei,:));
                            [sortDists,tmpLoc]=sort(tmpdist);
                            sortLoc=nei(tmpLoc);
                            
                            count=1;%��׼���ڽ������
                            %if(sum(visited(sortLoc))~=length(not_vis_nei))%��ֹ��ѡ��������ھӵ㶼�Ѿ�������
                            visited(not_vis_nei(loop))=true;
                            break
                            %end
                        end
                    end
                end
            end
            count=count+1;%count>sortLoc���ȣ�
            if(count==length(sortLoc))
                not_vis_nei= visited(Neighbors)==0;%�ҳ�Neighbors�л�û�����ʵĵ���Neighbors�е�����
                not_vis_nei=Neighbors(not_vis_nei);%�õ���ı��               
                if(isempty(not_vis_nei))
                    return
                else                    
                    for loop=1:length(not_vis_nei)
                            nei=gridNeigbors(tree,X,not_vis_nei(loop),radius*disTh); 
                            %nei=cell2mat(nei);
                            tmpdist=pdist2(X(not_vis_nei(loop),:),X(nei,:));
                            [sortDists,tmpLoc]=sort(tmpdist);
                            sortLoc=nei(tmpLoc);


                        count=2;%��׼���ڽ������
                       % if(sum(visited(sortLoc))~=length(not_vis_nei))%��ֹ��ѡ��������ھӵ㶼�Ѿ�������
                       visited(not_vis_nei(loop))=true;
                       break
                       %end
                    end
                end
            end
            
        end
    end
    function [realPosOfNeib]=NeighborsQuery(current_p,sortDists,sortLoc,dist,radius)
        lowBound=find_halfspace_mex3(sortDists,dist-radius);%%%��ʱ�Ѿ�����Neighbors
        upBound=find_halfspace_mex3(sortDists,dist+radius);
        possiblePointsSortedLocs=[lowBound:upBound];
        possiblePointsLoc=sortLoc(possiblePointsSortedLocs);
        possiblePoints=X(possiblePointsLoc,:) ;
        tmpDistans=pdist2(X(current_p,:),possiblePoints);
        neibors= tmpDistans<=radius;
        realPosOfNeib=possiblePointsLoc(neibors);
    end

    
disp( evaluation)
%profile viewer
end
function [possibleNeibors,num]=findPossibleNeibsByRecorder(points,i,dim,radius,sortedLocs,LowRecorder,HighRecorder,MinDimRecorder,possibleNeibors,distMetric)
    %��mindimά���ϵ����п��ܵ���ΪpossibleNeibors
    %begin:�ҳ�������ά���Ͼ���С��radius�ĵ�
    %end:�ҳ�������ά���Ͼ���С��radius�ĵ�
    mindim=MinDimRecorder(i,1);
    minnum=MinDimRecorder(i,2);
    elowLoc=LowRecorder(i,mindim);
    ehighLoc=HighRecorder(i,mindim);
    possNeibs1=sortedLocs(elowLoc:ehighLoc,mindim);
    
%     dists=pdist2(points(i,:),points(possNeibs1,:),'chebychev');
%     possNeibs2=find (dists<=radius);
%     possNeibs1=possNeibs1(possNeibs2);
    for (j=1:dim)
        if (j~=mindim) 
            cv=points(i,j);
            possNeibs2=find ((cv-radius<=points(possNeibs1,j))& (cv+radius>=points(possNeibs1,j)));
            possNeibs1=possNeibs1(possNeibs2);
        end
    end
     if (strcmp(distMetric,'Euclidean'))
        dists=pdist2(points(i,:), points(possNeibs1,:));
        poss=find(dists<=radius);
        possNeibs1=possNeibs1(poss);
    end
    num=length(possNeibs1);
    possibleNeibors(1:num)=possNeibs1;
end
