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
function grids=createGridsSets(points,segs,basicEps,basicPointsNumInACell)
    if nargin<3
        basicEps=200;
        basicPointsNumInACell=200;
    end
    grids={};
    [len,dim]=size(points);
    pointsSet={};

    for i=1:segs
        tic
        tmpLen= floor(i*len/segs);       
        tmpPoints=points(1:tmpLen,:);
        grids{i}=createDataIndexing(tmpPoints,basicEps,basicPointsNumInACell);
        toc
    end

end

