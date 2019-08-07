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

%
% Create a tree structure for input data
% Input: 
%       points: normalized input data with each dimension has domain [0,100000]
% Output:
%       gridDataStru: 

function [gridDataStruWrapper] = createDataIndexing_add( points,basicSideLength,baseTimes,basicPointsNumInACell,maxCellsNum)
    if (nargin<2)
        basicSideLength=1000;
    end
    if (nargin<4)
        basicPointsNumInACell=100;
    end
    if (nargin<5)
        maxCellsNum=200;
    end
    
    [n,dim]=size(points);
    grids=zeros(n,dim);  
    %recorder of running time 
    timeRecorder=zeros(10,1); 
    disp('Step 1: preparing data and generating grids...');
    %calculate grids
    t1=clock;
    offside=min(min(points));
    if offside<0
        points=points+abs(offside);
    end
    grids=floor(points/basicSideLength);
    timeRecorder(1)=etime(clock,t1);    

    disp('Step 2:mapping and statistic grids...');
    %{
    %map grids(i) to a string. e.g., [1 2 3] is mapped to 'id#1#2#3';
    %map2str is written by C, becasue matlab is slow to process char 
    %        1) mapKeys:a unique array of string mapped from points.
    %           For example [1 2 3;1 2 3; 3 2 1]-> 'id#1#2#3; id#3#2#1'
    %        2) gridIndexOfEachPoint:a vector 'gridIndex' that saves the grid index to which each point belongs 
    %           For example, if gridIndex[i]=2 means the i^th point is included in the 2nd grid.
    %        3) nonEmptyCell: the matrix of the mapped coordinates of each unique non-empty grid.
    %        4) pointsInCell: e.g. pointsInCell{i}=[1,2,3] means the i^th cell includes point 1,2 and 3 .
    %        5) nonEmptyCellNum: the number of the non-empty cell.
    %        6) pointsInCellNumArr: the number of points in each cell. e.g.
    %           pointsInCellNumArr[i]=5 means the i^th cell includes 5
    %           points, in fact pointsInCellNumArr[i]= length(pointsInCell{i)
    %}
    t1=clock;    
    [mapKeys,gridIndexOfEachPoint,nonEmptyCell,pointsInCell,nonEmptyCellNum,pointsInCellNumArr]=map2str(grids);
    timeRecorder(2)=etime(clock,t1);   
        
     
    disp('     layer :1');
          %gridDataStruWrapper=layers;
          layers(1)=getLayer(points,basicSideLength,basicPointsNumInACell,[],1,gridIndexOfEachPoint,nonEmptyCell,nonEmptyCellNum,pointsInCell,0);
    %return;
    count=1;
    
    while 1        
        grids=floor(nonEmptyCell/(baseTimes+count));
        [mapKeys,gridIndexOfEachPoint,nonEmptyCell,pointsInCell,nonEmptyCellNum,pointsInCellNumArr]=map2str(grids);
        if  nonEmptyCellNum>maxCellsNum
            count=count+1;
            disp(strcat('     layer :',num2str(count)));
            aLayer=getLayer(points,basicSideLength,basicPointsNumInACell,layers(count-1),count,gridIndexOfEachPoint,nonEmptyCell,nonEmptyCellNum,pointsInCell,baseTimes);
            layers(count)=aLayer;
        else
            break;
        end
    end
    
    %[leafCellsWrapper,nonLeafCellsWrapper]=extractStatisticInfo(layers);
    %gridDataStruWrapper={layers,leafCellsWrapper,nonLeafCellsWrapper};
    gridDataStruWrapper={layers};
end

%create a layer structure
function [layerStruct]= getLayer(points,basicSideLength,basicPointsNumInACell,childLayerStruct,layerId,gridIndexOfEachCell,nonEmptyCell,nonEmptyCellNum,childrenCells,baseTimes)
        %Layer structure 
    layerStruct.layer=layerId;
    layerStruct.cellSideLength=basicSideLength*(baseTimes+layerId-1);
    layerStruct.gridIndexOfEachCell=gridIndexOfEachCell;
    layerStruct.nonEmptyCell=nonEmptyCell;
    %save children cells
    layerStruct.childrenCells=childrenCells;
    for i=1:length(childrenCells)
        childrednCellsNumArr(i)=length(childrenCells{i});  
    end
    layerStruct.childrednCellsNumArr=childrednCellsNumArr;  
    layerStruct.nonEmptyCellNum=nonEmptyCellNum;
    pointsInCellNumArr=zeros(nonEmptyCellNum,1);
    if ~isempty(childLayerStruct)
        for i=1: nonEmptyCellNum
            tmpChildrenCells=childrenCells{i};
            pointsIncluded=[];
            for j=1:length(tmpChildrenCells)
                tmpPoints=childLayerStruct.pointsInCell{tmpChildrenCells(j)};
                pointsIncluded=[pointsIncluded tmpPoints];
            end    
            pointsInCell{i}=pointsIncluded;            
            pointsInCellNumArr(i)=length(pointsIncluded);
            cellSum{i}=sum(points(pointsIncluded,:));
        end
        
        %save real points indice
        layerStruct.pointsInCell=pointsInCell;
        layerStruct.pointsSumInCell=cellSum;
    else
        %in the first layer, the cell is the points itself.i
        layerStruct.pointsInCell=childrenCells;         
        pointsInCellNumArr=childrednCellsNumArr;
        for i=1:length(childrenCells)
            cellSum{i}=sum(points(childrenCells{i},:));
        end
        layerStruct.pointsSumInCell=cellSum;
    end
    layerStruct.pointsInCellNumArr=pointsInCellNumArr;    
    
    %the geometric center of each cell
    layerStruct.centers=(nonEmptyCell+0.5)*basicSideLength*2^(layerId-1);
    
    leaf=ones(nonEmptyCellNum,1);
    %if in the first layer, all cell is leaf, else 
    if layerId>1
       indice=find(pointsInCellNumArr>basicPointsNumInACell);
       leaf(indice)=0;
    end
    layerStruct.isLeafCell=leaf;
    %layerStruct.isBorderCell=zeros(nonEmptyCellNum,1);
end

%do statistical works to count leaf cells and non-leaf cells, and save info
%in leafCellsWrapper,nonLeafCellsWrapper
function [leafCellsWrapper,nonLeafCellsWrapper]=extractStatisticInfo(gridDataStru)
    topLayerId=length(gridDataStru);
    leafCellsWrapper={};
    nonLeafCellsWrapper={};
    statisticalInfo={};
    for i=1:topLayerId
        curLayer=gridDataStru(i);
        cellNum=curLayer.nonEmptyCellNum;
        processedSign=zeros(cellNum,1);
        processedSignWrapper{i}=processedSign;
    end
    
    for i=topLayerId:-1:1
        curLayer=gridDataStru(i);
        indice=find(curLayer.isLeafCell==1&(processedSignWrapper{i}==0));
        leafCellsWrapper{i}=indice';
        cellNum=curLayer.nonEmptyCellNum;
        nonLeafCellsWrapper{i}=(1:cellNum);
        nonLeafCellsWrapper{i}(indice)=[];
        if (isempty(indice))
            continue;
        end        
        for j=1:length(indice)
            processedSignWrapper=setAllChildrenProcessed(gridDataStru,i,indice(j),processedSignWrapper)
        end        
    end
end

function [processedSignWrapper]=setAllChildrenProcessed(gridDataStru,curLayerId,cellId,processedSignWrapper)
       curLayer=gridDataStru(curLayerId);
       processedSignWrapper{curLayerId}(cellId)=1;
       childrenCells=curLayer.childrenCells{cellId};
       if (curLayerId>1)
           for i=1:length(childrenCells)
              processedSignWrapper= setAllChildrenProcessed(gridDataStru,curLayerId-1,childrenCells(i),processedSignWrapper);
           end
       end
end