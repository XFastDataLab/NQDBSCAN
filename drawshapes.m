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
function drawshapes(points,class,ND)
    %��ɫ�任����
    colorindent = 100/7;
    %��״
    shapes='*o^+sx<d.^ph>dv';
    hold on;
    for i=1:ND        
        if (class(i)>0)
            %colr,colg,colb�ǻ�ͼ��RGB��ɫֵ
            col=colorindent*(class(i)-1);
            colr= mod(col,10);
            col=fix(col/10);
            colg=mod(col,10);
            col=fix(col/10);
            colb=mod(col,10);
            v=0.1*[colr,colg,colb];
            %ѡ��ͼ��״
            shapeindex= mod(class(i),14)+1;
            plot(points(i,1),points(i,2),shapes(shapeindex),'MarkerSize',5,'MarkerFaceColor',v,'MarkerEdgeColor',v); 
            %plot(points(i,1),points(i,2),shapes(shapeindex),'MarkerSize',5,'MarkerFaceColor','k','MarkerEdgeColor','k'); 
        else
            %��Ⱥ���ú�ɫo����
            plot(points(i,1),points(i,2),'o','MarkerSize',5,'MarkerEdgeColor','r');  
        end
    end
end
