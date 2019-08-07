function [points_norm]=normlizeData(points)
   [x,dim]=size(points);
   points_norm=zeros(x,dim);
   minv=min(min(points));
   tmpM= minv*ones(x,dim);
   points= points- tmpM;
   for (i=1:dim)
       maxv=max(points(:,i));
       points_norm(:,i)= points(:,i)/maxv *(10^5);
   end
end