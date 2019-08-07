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

function [ neighbors ] = gridNeigbors(gridDataStru,points, id,radius)
       [m,dim]=size(points);
        aPoint=points(id,:);
        layers=gridDataStru{1};
        layersNum=length(layers);
        topLayer=layers(layersNum);
        possCells=[1:topLayer.nonEmptyCellNum];
        possCellsCount=topLayer.nonEmptyCellNum;
        neighbors={};
        %neighbors=[];
        neibCount=0;
        for i=layersNum:-1:1
            curLayerId=i;
            curLayer=layers(curLayerId);

            %curChildrenCells=curLayer.childrenCells;
            curPointsInCell=curLayer.pointsInCell;
            curCellCenters=curLayer.centers;            
    
            %Step 1: find points in those cells that can be directly judged as neighbors
            %all farest distances from each cell to aPoint
            farestDistM= getFarestDistance(curCellCenters(possCells,:),curLayer.cellSideLength,aPoint);
            %all those cells whose farest distances to aPoint are smaller than radius, then all points in these cell are definetly neighbors
            %of aPoint.
            neibCells=find(farestDistM<=radius);
               
            for j=1:length(neibCells)
                neibCount=neibCount+1;
                %neighbors=[neighbors tmpNeibs];
                neighbors{neibCount}=curPointsInCell{possCells(neibCells(j))};
            end    

            %all closest distances from each cell to aPoint
            closestDistM= getClosestDistance(curCellCenters(possCells,:),curLayer.cellSideLength,aPoint);

            %there are some points in those cells (s.t.closest distance<=radius<=farest distances) maybe neighbors
            possNeibCells=find(closestDistM<=radius &farestDistM>radius);
            possNeibCells=possCells(possNeibCells);
            
            %Step 2: find neighbors in leaf cells that intersects with the radius-neighborhood of aPoint
            leafPossNeibCellsLoc=find(curLayer.isLeafCell(possNeibCells)==1);
            leafPossNeibCells=possNeibCells(leafPossNeibCellsLoc);
            totalPoints=cell2mat(curPointsInCell(leafPossNeibCells));
            tmpDists=pdist2(points(totalPoints,:),aPoint);

            tmpLoc=find(tmpDists<=radius);
            if ~isempty(tmpLoc)
                neibCount=neibCount+1;
                neighbors{neibCount}=totalPoints(tmpLoc);
            end


            %Step 3: find neighbors in non-leaf cells that intersects with the radius-neighborhood of aPoint
            nonLeafPossNeibCellsLoc=find(curLayer.isLeafCell(possNeibCells)==0);
            nonLeafPossNeibCells=possNeibCells(nonLeafPossNeibCellsLoc);   
            possCells={};
            for j=1:length(nonLeafPossNeibCells)
                possCells{j}=curLayer.childrenCells{nonLeafPossNeibCells(j)};
            end
            possCells=cell2mat(possCells);
            if isempty(possCells)
                break;
            end

            if isempty(possCells)
                break;
            end
        end
        neighbors=cell2mat(neighbors);
        
end

function [neighbors]=test2(gridDataStru,points, id,radius)
        aPoint=points(id,:);
        layers=gridDataStru{1};
        layersNum=length(layers);
        topLayer=layers(layersNum);
        possCells=[1:topLayer.nonEmptyCellNum];
        neighbors={};
        %neighbors=[];
        neibCount=0;
        for i=layersNum:-1:1
            if i==5
                aaa=1;
            end
            curLayerId=i;
            curLayer=layers(curLayerId);
            sideLength=curLayer.cellSideLength

            %curChildrenCells=curLayer.childrenCells;
            curPointsInCell=curLayer.pointsInCell;
            curCellCenters=curLayer.centers;   
            display('step 0');
            tic
            tmpCenters=curCellCenters(possCells,:);
            toc
            display('step 1');
            tic
            
            %Step 1: find points in those cells that can be directly judged as neighbors
            %all farest distances from each cell to aPoint
            
            %farestDistM= getFarestDistance(tmpCenters,curLayer.cellSideLength,aPoint);
            % minus point for each row of geoCenters, each row of this result means the
            % direction from point to a center of a cell
            signD=bsxfun(@minus,tmpCenters,aPoint);
            toc
            tic
            %sign(signD) is to change all positive items as 1, and all negtive items as -1
            %find the farest vertex from point for each cell 
            farestVetex= tmpCenters+  sideLength/2 * sign(signD);
            toc
            tic 
            farestDistM=pdist2(farestVetex,aPoint);
            toc 
            
            %all those cells whose farest distances to aPoint are smaller than radius, then all points in these cell are definetly neighbors
            %of aPoint.
            neibCells=find(farestDistM<=radius);
               
            for j=1:length(neibCells)
                neibCount=neibCount+1;
                %neighbors=[neighbors tmpNeibs];
                neighbors{neibCount}=curPointsInCell{possCells(neibCells(j))};
            end
            toc 

            %all closest distances from each cell to aPoint
            %closestDistM= getClosestDistance(tmpCenters,curLayer.cellSideLength,aPoint);
            signD=signD-sideLength/2;    
            %after the procession above, all dimensions within the neighborhood of
            %a cell will be less than 0.

            tic
            %all those dimensions out of the neighborhood of a cell will be 1
            signD1=(signD>0);
            signD1=signD.*signD1;

            [m,dim]=size(tmpCenters);    
            closestDistM=pdist2(signD1,zeros(1,dim));
            

            %there are some points in those cells (s.t.closest distance<=radius<=farest distances) maybe neighbors
            possNeibCells=find(closestDistM<=radius &farestDistM>radius);
            possNeibCells=possCells(possNeibCells);
            toc
            
            %Step 2: find neighbors in leaf cells that intersects with the radius-neighborhood of aPoint
            display('step 2');
            tic
            display('step find leaf poss neib');
            leafPossNeibCellsLoc=find(curLayer.isLeafCell(possNeibCells)==1);
            leafPossNeibCells=possNeibCells(leafPossNeibCellsLoc);
            toc
            tic
            display('cell2mat');
            totalPoints=cell2mat(curPointsInCell(leafPossNeibCells));
            toc
            tic
            display('pdist');
            tmpDists=pdist2(points(totalPoints,:),aPoint);
            toc
            tic
            display('find real neibs');
            tmpLoc=find(tmpDists<=radius);
            if ~isempty(tmpLoc)
                neibCount=neibCount+1;
                neighbors{neibCount}=totalPoints(tmpLoc);
            end
            toc

            display('step 3');
            tic
            %Step 3: find neighbors in non-leaf cells that intersects with the radius-neighborhood of aPoint
            nonLeafPossNeibCellsLoc=find(curLayer.isLeafCell(possNeibCells)==0);
            nonLeafPossNeibCells=possNeibCells(nonLeafPossNeibCellsLoc);   
            possCells={};
            for j=1:length(nonLeafPossNeibCells)
                possCells{j}=curLayer.childrenCells{nonLeafPossNeibCells(j)};
            end
            possCells=cell2mat(possCells);
            if isempty(possCells)
                break;
            end
            toc
        end
    %end
end

function [neighbors]=test1 (gridDataStru,points, id,radius)
        tic
        aPoint=points(id,:);
        layers=gridDataStru{1};
        layersNum=length(layers);
        topLayer=layers(layersNum);
        possCells=[1:topLayer.nonEmptyCellNum];
        possCellsCount=topLayer.nonEmptyCellNum;
        neighbors={};
        %neighbors=[];
        neibCount=0;
        for i=layersNum:-1:1
            curLayerId=i;
            curLayer=layers(curLayerId);

            %curChildrenCells=curLayer.childrenCells;
            curPointsInCell=curLayer.pointsInCell;
            curCellCenters=curLayer.centers;            
    
            %Step 1: find points in those cells that can be directly judged as neighbors
            %all farest distances from each cell to aPoint
            farestDistM= getFarestDistance(curCellCenters(possCells,:),curLayer.cellSideLength,aPoint);
            %all those cells whose farest distances to aPoint are smaller than radius, then all points in these cell are definetly neighbors
            %of aPoint.
            neibCells=find(farestDistM<=radius);
               
            for j=1:length(neibCells)
                neibCount=neibCount+1;
                %neighbors=[neighbors tmpNeibs];
                neighbors{neibCount}=curPointsInCell{possCells(neibCells(j))};
            end    

            %all closest distances from each cell to aPoint
            closestDistM= getClosestDistance(curCellCenters(possCells,:),curLayer.cellSideLength,aPoint);

            %there are some points in those cells (s.t.closest distance<=radius<=farest distances) maybe neighbors
            possNeibCells=find(closestDistM<=radius &farestDistM>radius);
            possNeibCells=possCells(possNeibCells);
            
            %Step 2: find neighbors in leaf cells that intersects with the radius-neighborhood of aPoint
            leafPossNeibCellsLoc=find(curLayer.isLeafCell(possNeibCells)==1);
            leafPossNeibCells=possNeibCells(leafPossNeibCellsLoc);
            totalPoints=cell2mat(curPointsInCell(leafPossNeibCells));
            tmpDists=pdist2(points(totalPoints,:),aPoint);

            tmpLoc=find(tmpDists<=radius);
            if ~isempty(tmpLoc)
                neibCount=neibCount+1;
                neighbors{neibCount}=totalPoints(tmpLoc);
            end


            %Step 3: find neighbors in non-leaf cells that intersects with the radius-neighborhood of aPoint
            nonLeafPossNeibCellsLoc=find(curLayer.isLeafCell(possNeibCells)==0);
            nonLeafPossNeibCells=possNeibCells(nonLeafPossNeibCellsLoc);   
            possCells={};
            for j=1:length(nonLeafPossNeibCells)
                possCells{j}=curLayer.childrenCells{nonLeafPossNeibCells(j)};
            end
            possCells=cell2mat(possCells);
            if isempty(possCells)
                break;
            end

            if isempty(possCells)
                break;
            end
        end
        neighbors=cell2mat(neighbors);
        toc
end



%this function is to find the farest distance of each cell in grid from a point. 
%the farest position of a cell from point must be a vertex of the cell.
%
%geoCenters: is a matrix save the coordinates of all cells
function [farestDistM]= getFarestDistance(geoCenters,sideLength,point)
    % minus point for each row of geoCenters, each row of this result means the
    % direction from point to a center of a cell
    signD=bsxfun(@minus,geoCenters,point);
    
    %sign(signD) is to change all positive items as 1, and all negtive items as -1
    %find the farest vertex from point for each cell 
    farestVetex= geoCenters+  sideLength/2 * sign(signD);
    farestDistM=pdist2(farestVetex,point);
end


%this function is to find the cloest distance of each cell in grid from a point.
%it is different from the farest distance, the closest position of a cell from point p 
%may be not a vertex:
%    case (1): if ther is only one dimension of p is out of the neigborhood
%              of cell c, the closest position from p locates in one face of the cell
%    case (2): if all dimensions of p is out of the neigborhood
%              of cell c, the closest position from p must be a vertex of the cell.
%    case (3): if their are some dimensions of p are out of the neigborhood,
%              and the rest dimensions are not, the closest position from p
%              locates in the edge of the cell.              
%
%geoCenters: is a matrix save the coordinates of all cells
function [closestDistM]= getClosestDistance(geoCenters,sideLength,point)
    % minus point for each row of geoCenters, each row of this result means the
    % direction from point to a center of a cell.
    signD=abs(bsxfun(@minus,geoCenters,point))-sideLength/2;    
    %after the procession above, all dimensions within the neighborhood of
    %a cell will be less than 0.
    
    %all those dimensions out of the neighborhood of a cell will be 1
    signD1=(signD>0);
    signD1=signD.*signD1;
    
    [m,dim]=size(geoCenters);    
    closestDistM=pdist2(signD1,zeros(1,dim));
end



%this function is used to plot the order label of each cell 
function drawGridLabel(grids,geoCenter,indice)
   [len,dim]=size(grids);
   for i=1:len
       text(geoCenter(i,1),geoCenter(i,2),num2str(indice(i)));
   end
end

%this function is used to plot cell in figure
function drawLine(data,sideLength)
    xmax=max(data(:,1))+1;
    xmin=min(data(:,1))-1;
    ymax=max(data(:,2))+1;
    ymin=min(data(:,2))-1;    
    for (i=xmin:xmax)
        line([i*sideLength,i*sideLength],[ymin*sideLength,ymax*sideLength]);
    end
    for (i=ymin:ymax)
        line([xmin*sideLength,xmax*sideLength],[i*sideLength,i*sideLength]);
    end
end

%is used to emphasize  a cell only.
function drawACell(gridDataStru,layerId,cellId,color)
    if nargin<4
        color=0;
    end
    tmpGridDataStru=gridDataStru(layerId);
    center=tmpGridDataStru.centers(cellId,:);
    sideLength=gridDataStru(layerId).cellSideLength;
    startPos=center-sideLength/2;
    loc= [startPos sideLength sideLength];
    if color==0
        rectangle('position',loc,'EdgeColor','r','linewidth',2 );
    elseif color==1
        rectangle('position',loc,'EdgeColor','g','linewidth',2 );
    else
        rectangle('position',loc,'EdgeColor','y','linewidth',2 );
    end        
end

